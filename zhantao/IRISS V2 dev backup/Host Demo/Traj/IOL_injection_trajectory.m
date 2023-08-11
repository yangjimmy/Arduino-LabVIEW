
%{
Modified at 08/31/2022
startPtOCT = [8;19;-2.5];middlePtOCT = [8;16;0];endPtOCT = [8;14;0];
IRIS_filename = '2022_09_01\eye3\VSCAN_0018.raw';
PC_filename = '2022_09_01\eye3\VSCAN_0018.raw';
OCT_offset = 0;
[tts,traj2]=IOL_injection_trajectory(startPtOCT,middlePtOCT,endPtOCT,IRIS_filename,PC_filename,OCT_offset);
%}
%clc; clear; close all;
% function [xyz,tts,traj2] = genIOL_Insertion(totalTime)
% if nargin < 1
%    totalTime = 60; 
% end
function [tts,traj2]=IOL_injection_trajectory(startPtOCT,middlePtOCT,endPtOCT,IRIS_filename,PC_filename,OCT_offset)
    %% converting images to .png
    % Location of scan .data files 

    % VSCAN_DIR = '2022_09_01\eye3\';
    % filename = [VSCAN_DIR 'VSCAN_0018.raw'];
    filename = IRIS_filename;

    % Parameters
    size_xyz = [400 400 1024];
    size_xyz_mm = [16 16 9.3972];
    size_xz = [400, 1024]; 
    size_xz_mm = [16, 9.3972]; %size_xz_mm = [10, 9.3972]; 
    ratio_mm = size_xyz_mm ./ size_xyz;
    %px2mm = size_xz_mm./size_xz;
    % grid for calculating centroid
    [ygrid, xgrid] = ndgrid(1:size_xyz(3), 1:size_xyz(1));
    % Open intensity file for read access    
    disp('Loading vscan...');
    fid = fopen(filename);
    % Read the intensity values (n x 1) vector (takes some time)
    vscan = fread(fid, prod(size_xyz), 'float32');
    vscan = reshape(vscan, flip(size_xyz));
    disp('vscan loaded!');
    % nicely scale the vscan
    vscan = vscan2nice(vscan);
    vscan = uint8(vscan);

    % change direction
    vscan2 = uint8(zeros([size(vscan,1) size(vscan,3) size(vscan,2)]));
    for i=1:size(vscan,3)
        vscan2(:,i,:) = vscan(:,:,i);
    end

    % remove ugly top data
    % vscan(1:10, :, :) = 0;

    % Preallocate: (x,y,z) points of rough centerpoints (centroids)
    centerpts = zeros(size_xyz(2), 3);

    % Preallocate: Largest blob size; Method to detect tool tip
    toolPresent = false(size_xyz(2), 1);

    % Preallocate: Point cloud for cylinder fit
    point_cloud = zeros(flip(size_xyz));

    % Initialize: For stopping volume scan once off tool
    blank_count = 0;

    refresh = 0;

    if refresh
        if ~exist([VSCAN_DIR '\images0'], 'dir')
           mkdir([VSCAN_DIR '\images0']);
        end
        if ~exist([VSCAN_DIR '\images1'], 'dir')
           mkdir([VSCAN_DIR '\images1']);
        end

        ratio_mm_bscan = flip(ratio_mm(2:3));

        % loop through scans; note, for IRISS v2, we loop backwards thru y
        for yy = size_xyz(2):-1:1

            h = figure(1);
            RI = imref2d(size(vscan(:,:,yy)));
            RI.XWorldLimits = [1 size_xyz_mm(1)];
            RI.YWorldLimits = [1 size_xyz_mm(3)];
            imshow(vscan(:,:,yy), RI);
            xlabel('X [mm]'); ylabel('Y [mm]')
            % extract bscan and convert to binary
            % bw = vscan(:,:,yy);
            origin = vscan(:,:,yy);
            bw = vscan(:,:,yy) > 0.5;

            % Add binary slice to to point cloud
            point_cloud(:,:,yy) = bw;

            % add this slice to the on-tool tracker 
            toolPresent(yy) = 1;

            filename = [VSCAN_DIR '\images0\' num2str(yy, '%04d'), '.png'];
            % saveas(h, filename);
            imwrite(vscan(:,:,yy),filename);

            h = figure(2);
            RI = imref2d(size(vscan2(:,:,yy)));
            RI.XWorldLimits = [1 size_xyz_mm(2)];
            RI.YWorldLimits = [1 size_xyz_mm(3)];
            imshow(vscan2(:,:,yy), RI);
            xlabel('X [mm]'); ylabel('Y [mm]')
            % extract bscan and convert to binary
            %     bw = vscan(:,:,yy);
            origin = vscan2(:,:,yy);
            bw = vscan2(:,:,yy) > 0.5;

            % Add binary slice to to point cloud
            point_cloud(:,:,yy) = bw;

            % add this slice to the on-tool tracker 
            toolPresent(yy) = 1;

            filename = [VSCAN_DIR '\images1\' num2str(yy, '%04d'), '.png'];
            imwrite(vscan2(:,:,yy),filename);
        end % End: y loop
    end

    %% detect iris points by vscan
    total_frames = 400;

    file_range = 1:400;

    frame = 0;
    size_yz_mm = [16 9.4];
    y_size = 512;
    dx = 16/total_frames;

    %{
    frame = 1;
    size_yz_mm = [16 9.4];
    y_size = 512;
    dx = 16/total_frames;
    %}

    whole_result = {};
    for f=1:length(file_range)
        number = file_range(f);
        %{
        if number<10
            filename = [VSCAN_DIR 'images' num2str(frame) '\000' num2str(number) '.png'];
        elseif number<100
            filename = [VSCAN_DIR 'images' num2str(frame) '\00' num2str(number) '.png'];
        else
            filename = [VSCAN_DIR 'images' num2str(frame) '\0' num2str(number) '.png'];
        end
        raw_img = imread(filename);
        %}
        if frame==0
            raw_img = vscan(:,:,number);
        else
            raw_img = vscan2(:,:,number);
        end

        % center_trade_off = number/(total_frames/2)*(number<total_frames/2)+(1-(number-total_frames/2)/(total_frames/2))*(number>=total_frames/2)
        % center_trade_off = sin(number*pi/total_frames);
        center_trade_off = 0.2;
        standard_rate = 0.16;
        %standard_rate2 = 0.16;
        standard_rate2 = 0.06;
        %standard_rate = 0.08;
        [left_point,right_point,img_,img,img2,img3]=find_iris(raw_img,size_yz_mm,y_size,standard_rate,standard_rate2,center_trade_off);
        figure(1);imshow(img);title(['Index: ' num2str(number)]);drawnow;
        %figure(2);imshow(img2);
        %figure(3);imshow(img3);
        figure(10);imshow(img_);title(['Index: ' num2str(number)]);drawnow;
        whole_result{f}.left_point = [dx*f left_point];
        whole_result{f}.right_point = [dx*f right_point];

        if ~isempty(left_point) && ~isempty(right_point)
            whole_result{f}.distance = norm(left_point-right_point);
        else
            whole_result{f}.distance = -1;
        end
    end
    %% get iris center
    [C1,C,normal] = getCenter(whole_result,frame,size_yz_mm,dx);
    %middlePt2 in IRISS frame
    %DeposPt in IRISS frame
    %% PC detection images
    % VSCAN_DIR = '2022_09_01\eye3\';
    % filename = [VSCAN_DIR 'VSCAN_0018.raw'];
    filename = PC_filename;

    % Parameters
    size_xyz = [400 400 1024];
    size_xyz_mm = [16 16 9.3972];
    size_xz = [400, 1024]; 
    size_xz_mm = [16, 9.3972];
    ratio_mm = size_xyz_mm ./ size_xyz;
    % grid for calculating centroid
    [ygrid, xgrid] = ndgrid(1:size_xyz(3), 1:size_xyz(1));
    % Open intensity file for read access    
    disp('Loading vscan...');
    fid = fopen(filename);
    % Read the intensity values (n x 1) vector (takes some time)
    vscan = fread(fid, prod(size_xyz), 'float32');
    vscan = reshape(vscan, flip(size_xyz));
    disp('vscan loaded!');
    % nicely scale the vscan
    vscan = vscan2nice(vscan);
    vscan = uint8(vscan);

    % change direction
    vscan2 = uint8(zeros([size(vscan,1) size(vscan,3) size(vscan,2)]));
    for i=1:size(vscan,3)
        vscan2(:,i,:) = vscan(:,:,i);
    end
    %% PC detection
    frame = 0;
    range = 20;
    PC_numbers = int32(C(1)/dx)-range:int32(C(1)/dx)+range;
    PC_pts = zeros(length(PC_numbers));
    for p = 1:length(PC_numbers)
        PC_number = PC_numbers(p);
        %{
        if PC_number<10
            filename = [foldername 'images' num2str(frame) '\000' num2str(PC_number) '.png'];
        elseif PC_number<100
            filename = [foldername 'images' num2str(frame) '\00' num2str(PC_number) '.png'];
        else
            filename = [foldername 'images' num2str(frame) '\0' num2str(PC_number) '.png'];
        end
        raw_img = imread(filename);
        %}
        if frame==0
            raw_img = vscan(:,:,PC_number);
        else
            raw_img = vscan2(:,:,PC_number);
        end

        resize_size = [int32(y_size*size_yz_mm(2)/size_yz_mm(1)) y_size];
        img = imresize(raw_img,resize_size);
        img_ = cat(3,img,img,img);
        [rows,cols] = size(img);

        w=fspecial('gaussian',[3 3],1);
        img=imfilter(img,w);

        img1 = zeros(size(img));
        threshold = 40;
        img1(img>threshold) = 255;img1(img<=threshold) = 0;
        counter = 0;
        avg_z = 0;
        for i=1:rows
            for j=1:cols
                if img1(i,j)>0
                    counter = counter+1;
                    avg_z = avg_z+i;
                end
            end
        end
        avg_z = avg_z/counter;

        % mm
        offset_z_mm = 2;
        % percentage
        cut_cols = 0.1;
        offset_z = int32(avg_z+rows/size_yz_mm(2)*offset_z_mm);

        threshold = 34;
        img2 = zeros(size(img));
        img2(img>threshold) = 255;img2(img<=threshold) = 0;
        img2(1:offset_z,:)=0;

        pts = [];
        for i=offset_z:rows
            for j=int32(cut_cols*cols):int32((1-cut_cols)*cols)
                if img2(i,j)>0
                    pts = [pts;i,j];
                end
            end
        end
        epochs = 100;
        max_dist = .2*rows;
        decay_rate = 0.7;
        min_remain_rate = 0.7;

        min_remain = min_remain_rate*size(pts,1);
        for e=1:epochs
            old_len = size(pts,1);
            X = double([ones(size(pts,1),1) pts(:,2) pts(:,2).^2]);
            Y = double(pts(:,1));
            a = pinv(X)*Y;
            YY = X*a;
            error = abs(YY-Y);
            new_pts = [];
            for i=1:old_len
                if error(i)<max_dist
                    new_pts = [new_pts;pts(i,:)];
                end
            end
            if size(new_pts,1)==old_len || size(new_pts,1)<min_remain
                break
            else
                pts = new_pts;
            end

            max_dist = max_dist*decay_rate;
        end

        xx = [ones(cols,1) (1:cols)' (1:cols)'.^2];
        yy = xx*a;
        img_ = insertShape(img_,'line',reshape([1:cols;yy'],[1 cols*2]),'linewidth',3,'color','y');
        figure(21);imshow(img_);
        figure(22);imshow(img2);
        if a(end)<0
            PC_pts(p) = max(yy);
        end
    end
    %
    cut_persentage = 0.1;
    if length(PC_pts)>10
        PC_pts = sort(PC_pts(PC_pts~=0));
        PC_pts_ = PC_pts(int32(length(PC_pts)*cut_persentage):int32(length(PC_pts)*(1-cut_persentage)));
        PC_depth = mean(PC_pts_)/rows*size_yz_mm(2);
    else
        PC_depth = mean(PC_pts(PC_pts~=0))/rows*size_yz_mm(2);
    end
    
    raw_PC_depth = PC_depth;
    %%
    % OCT_offset = 0; % mm
    PC_depth = PC_depth + OCT_offset;

    C_ = C;
    C_(3) = C(3)*.7+PC_depth*.3;

    l_dp = 2.;u_dp = 6.5;
    if C_(3)-C(3)>u_dp
        C_(3) = C(3)+u_dp;
    elseif C_(3)-C(3)<l_dp
        C_(3) = C(3)+l_dp;
    end

   global pts;
    global n;n = length(pts)-1;
    global m;m = size(pts,2);
    global gamma;gamma = 0;
    global VC;global AC;global JC;
    middlePt1 = middlePtOCT(1:3);
    %middlePt1(1) = (startPtOCT(1)+endPtOCT(1))/2;
    %middlePt2 = C;middlePt2(1) = C(1)*.5+endPtOCT(1)*.5;middlePt2(2) = middlePt2(2)+iris_offset_y;middlePt2(3) = endPtOCT(3);
    middlePt2 = C;middlePt2(1) = C(1)*.3+endPtOCT(1)*.7;
    %y_offset = 2.8;middlePt2(2) = C(2)+y_offset;
    middlePt2(2) = C(2)*.5+endPtOCT(2)*.5;
    middlePt2(3) = endPtOCT(3);
    pts = [startPtOCT(1:3), middlePt1, endPtOCT(1:3), middlePt2', C_']';
    middlePt3 = middlePt2;
    middlePt3(1) = middlePt2(1)*.5+C(1)*.5;
    middlePt3(2) = middlePt2(2)*.7+C(2)*.3;
    middlePt3(3) = middlePt2(3)*.85+C(3)*.15;

    pts = [startPtOCT(1:3), middlePtOCT(1:3), endPtOCT(1:3), middlePt2', middlePt3', C_']';
    
    % slowest parameters
    VC = 6;AC = 20;JC = 35;
    % speed constraint
    global vi_vf;vi_vf = [0 0 0;0 0 0];
    constant_speed = 4.;
    global spd_pts;
    spd_pts = constant_speed*ones(length(pts),1);spd_pts(1)=0;spd_pts(end)=0;
    spd_pts(2) = 4.2;
    spd_pts(3) = 4.;
    spd_pts(4) = 3.5;
    spd_pts(5) = 3.5;
    
    %{
    % most stable parameters
    VC = 10;AC = 25;JC = 45;
    % speed constraint
    global vi_vf;vi_vf = [0 0 0;0 0 0];
    constant_speed = 5.;
    global spd_pts;
    spd_pts = constant_speed*ones(length(pts),1);spd_pts(1)=0;spd_pts(end)=0;
    spd_pts(2) = 5.2;
    spd_pts(3) = 5.;
    spd_pts(4) = 4.5;
    spd_pts(5) = 4.5;
    %}
    %{
    % second stable parameters
    VC = 20;AC = 70;JC = 200;
    % speed constraint
    global vi_vf;vi_vf = [0 0 0;0 0 0];
    constant_speed = 5.5;
    global spd_pts;
    spd_pts = constant_speed*ones(length(pts),1);spd_pts(1)=0;spd_pts(end)=0;
    spd_pts(2) = 6.2;
    spd_pts(3) = 6.;
    %spd_pts(3) = 5.7;
    spd_pts(4) = 5.6;
    spd_pts(5) = 5.6;
    %}
    %{
    % fatest parameters
    VC = 12;AC = 45;JC = 150;
    % speed constraint
    global vi_vf;vi_vf = [0 0 0;0 0 0];
    constant_speed = 6.5;
    global spd_pts;
    spd_pts = constant_speed*ones(length(pts),1);spd_pts(1)=0;spd_pts(end)=0;
    spd_pts(2) = 6.5;spd_pts(4) = 6;
    spd_pts(5) = 6;
    % iris_offset_y = 3;spd_pts(2) = 6.3;(decrease)
    %}

    [tts,traj2,x]=optimal_trajectory(pts,vi_vf,spd_pts,VC,AC,JC,gamma);
    traj2(:,3) = -traj2(:,3);
    pts(:,3) = -pts(:,3);

    %% plotting
    velocity = differential(tts,traj2);
    acc = differential2(tts,traj2);
    jerk = diff(acc)./(tts(2)-tts(1));

    figure;plot3(traj2(:,1),traj2(:,2),traj2(:,3));hold on
    plot3(pts(:,1), pts(:,2), pts(:,3), 'rx');
    plot3(C(1), C(2), -C(3), 'm.', 'markersize', 10);hold off
    title('Trajectory');xlabel('X-axis (mm)');ylabel('Y-axis (mm)');
    axis equal
    %figure;plot(tts,traj2);
    %title('Position with time');xlabel('Time (sec)');ylabel('Position (mm)');legend({'X position','Y position','Z position'});
    %figure;plot(tts,velocity(:,1),tts,velocity(:,2),tts,velocity(:,3),tts,sqrt(sum(velocity.^2,2)));
    %title('Velocity with time');xlabel('Time (sec)');ylabel('Velocity (mm/s)');legend({'X velocity','Y velocity','Z velocity','Speed'});
    %figure;plot(tts,acc(:,1),tts,acc(:,2),tts,acc(:,3),tts,sqrt(sum(acc.^2,2)));
    %title('Acceleration with time');xlabel('Time (sec)');ylabel('Acceleration (mm/s^2)');legend({'X acceleration','Y acceleration','Z acceleration','Acceleration'});
    %figure;plot(tts(2:end),jerk(:,1),tts(2:end),jerk(:,2),tts(2:end),jerk(:,3),tts(2:end),sqrt(sum(jerk.^2,2)));
    %title('Jerk with time');xlabel('Time (sec)');ylabel('Jerk (mm/s^3)');legend({'X jerk','Y jerk','Z jerk','Jerk'});

    figure;
    speed = sqrt(sum(velocity.^2,2));
    plot(tts,speed);hold on
    tts2 = cumsum(x(4*m*n+1:end));speed2 = speed(min(round(tts2/(tts(2)-tts(1)),0)+1,length(speed)));
    plot(tts2,speed2,'rx');hold off
    title('Speed with time');xlabel('Time (sec)');ylabel('Speed (mm/s)');
    
    traj2(:,3) = -traj2(:,3);
    traj2 = traj2';
end
%% Traj: Position and Speed Only
%% Functions for iris center
function [C1,C,normal] = getCenter(whole_result,frame,size_yz_mm,dx)
    %% delete points of connecting iris
    pts = [];
    index_diff = 20;
    max_diff = 3;
    start_index = 1;
    for i=1:int32(length(whole_result)/2)
        if whole_result{i+index_diff}.distance~=-1 && whole_result{i}.distance~=-1
            if (whole_result{i+index_diff}.distance-whole_result{i}.distance) > max_diff
                start_index = i;
                break
            end
        end
    end
    
    end_index = length(whole_result);
    for i=length(whole_result):-1:int32(length(whole_result)/2)
        if whole_result{i-index_diff}.distance~=-1 && whole_result{i}.distance~=-1
            if (whole_result{i-index_diff}.distance-whole_result{i}.distance) > max_diff
                end_index = i;
                break
            end
        end
    end

    pts = [];
    for i=start_index:end_index
        left = whole_result{i}.left_point;
        if length(left)==3
            pts = [pts;left];
        end
        right = whole_result{i}.right_point;
        if length(right)==3
            pts = [pts;right];
        end
    end
    
    if frame==0
        pts(:,2) = size_yz_mm(1)-pts(:,2);
    else
        pts(:,[1,2]) = pts(:,[2,1]);
        pts(:,2) = size_yz_mm(1)-pts(:,2);
    end

    %figure(6);
    %plot3(pts(:,1),pts(:,2),pts(:,3),'b.');hold on
    center = mean(pts,1);
    %plot3(center(1),center(2),center(3),'r.','markersize',10);hold off
    %axis([0 dx*400 0 size_yz_mm(1) 0 size_yz_mm(2)]);
    %title('Iris points in 3D space');
    %subtitle(['Iris center: (' num2str(center(1)) ',' num2str(center(2)) ',' num2str(center(3)) ')']);
    C1 = [center(1),center(2),center(3)];
    %xlabel('x (mm)');
    %ylabel('y (mm)');
    %zlabel('z (mm)');
    %axis equal;
    %%
    points = pts';
    % save([foldername '\iris_position_frame' num2str(frame) '.mat'],'points');
    %% fitting circle in space
    % P = load('2022_08_25\eye2\iris_position_frame0.mat').points;
    P = points;

    % (1) Fitting plane by SVD for the mean-centered data
    % Eq. of plane is <p,n> + d = 0, where p is a point on plane and n is normal vector.
    P_mean = mean(P,2);
    P_centered = P-P_mean;
    [U,S,V] = svd(P_centered');
    % Normal vector of fitting plane is given by 3rd column in V
    normal = V(:,end);
    if normal(3)<0
        normal = -normal;
    end
    d = -dot(P_mean,normal);

    % (2) Project points to coords X-Y in 2D plane
    P_xy = rodrigues_rotation(P_centered, normal, [0;0;1]);

    % (3) Fit circle in new 2D coords
    [xc, yc, r] = fit_circle_2d(P_xy(1,:)', P_xy(2,:)');

    % (4) Transform circle center back to 3D coords
    C = rodrigues_rotation([xc;yc;0], [0;0;1], normal) + P_mean;

    % (5) fitting circle
    t = linspace(0,2*pi,100);
    % u = P(:,100)-C;
    syms a
    a = eval(solve(normal(1)+normal(2)+normal(3)*a==0,a));
    u = [1;1;a];
    P_fitcircle = generate_circle_by_vectors(t, C, r, normal, u);

    %% plot
    figure(7);
    plot3(P(1,:),P(2,:),P(3,:),'g.');hold on
    plot3(P_fitcircle(1,:),P_fitcircle(2,:),P_fitcircle(3,:),'r-');
    plot3(C(1),C(2),C(3),'r.');
    plot3([C(1) C(1)+normal(1)],[C(2) C(2)+normal(2)],[C(3) C(3)+normal(3)],'r-');
    title('Fitting result');
    subtitle(['Iris center: (' num2str(C(1)) ',' num2str(C(2)) ',' num2str(C(3)) '), Normal: ('  num2str(normal(1)) ',' num2str(normal(2)) ',' num2str(normal(3)) ')'])
    xlabel('x (mm)');
    ylabel('y (mm)');
    zlabel('z (mm)');
    axis equal;hold off
    %%
    C = C';
end

%% functions of iris detection
function [left_point,right_point,img_,img,img2,img3]=find_iris(raw_img,size_yz_mm,y_size,standard_rate,standard_rate2,center_trade_off)
    resize_size = [int32(y_size*size_yz_mm(2)/size_yz_mm(1)) y_size];
    img = imresize(raw_img,resize_size);
    img_ = cat(3,img,img,img);
    [rows,cols] = size(img);
    
    w=fspecial('gaussian',[3 3],3);
    img=imfilter(img,w);
    
    threshold = 40; % threshold for binary image
    img(img<=threshold) = 0;img(img>threshold) = 255;
    
    % percentage
    avg_z = 0;
    counter = 0;
    for i=1:rows
        for j=1:cols
            if img(i,j)==255 && j<cols*(1-standard_rate) && j>cols*standard_rate
                avg_z = avg_z+i;
                counter = counter+1;
            end
        end
    end
    avg_z = avg_z/counter;
    
    lower_to_avg = 0;
    lower_to_avg = int32(lower_to_avg/size_yz_mm(2)*rows);
    avg_y = [];
    for i=int32(avg_z-lower_to_avg):rows
        for j=1:cols
            if img(i,j)==255 && j<cols*(1-standard_rate) && j>cols*standard_rate
                if sum(avg_y==j)==0
                    avg_y = [avg_y j];
                end
            end
        end
    end
    avg_y = mean(avg_y);
        
    avg_z_l = 0;
    avg_z_r = 0;
    counter1 = 0;
    counter2 = 0;
    for i=1:rows
        for j=1:cols
            if img(i,j)==255 && j<cols*standard_rate 
                avg_z_l = avg_z_l+i;
                counter1 = counter1+1;
            end
            if img(i,j)==255 && j>cols*(1-standard_rate)
                avg_z_r = avg_z_r+i;
                counter2 = counter2+1;
            end
        end
    end
    avg_z_l = avg_z_l/counter1;
    avg_z_r = avg_z_r/counter2;
    
    % mm
    upper = 3.3;
    % lower = .3;
    lower = 0.1;
    upper = int32(upper/size_yz_mm(2)*rows);
    lower = int32(lower/size_yz_mm(2)*rows);
    left_pts = [];
    right_pts = [];
    imin_l = max(int32(avg_z_l-lower),1);
    imax_l = min(int32(avg_z_l+upper),rows);
    imin_r = max(int32(avg_z_r-lower),1);
    imax_r = min(int32(avg_z_r+upper),rows);
    standard_line = center_trade_off*cols/2+(1-center_trade_off)*avg_y;
    
    for i=1:rows
        for j=max(int32(cols*standard_rate2),1):min(int32(cols*(1-standard_rate2)),cols)
            if img(i,j)==255
                if j<standard_line && i>imin_l && i<imax_l
                    left_pts = [left_pts;[i,j]];
                elseif j>=standard_line && i>imin_r && i<imax_r
                    right_pts = [right_pts;[i,j]];
                end
            end
        end
    end
    
    % percentage
    lower_close_to_center = .8;
    upper_close_to_center = .9;
    top_bottom = .05;
    
    sorted_left = sort(left_pts,1);
    n_l = size(left_pts,1);
    left_pts_ = [];
    if n_l > 10
        lower = sorted_left(int32(lower_close_to_center*n_l),2);
        upper = sorted_left(int32(upper_close_to_center*n_l),2);
        top = sorted_left(int32((1-top_bottom)*n_l),1);
        bottom = sorted_left(int32(top_bottom*n_l),1);
        for i=1:n_l
            if left_pts(i,2)>lower && left_pts(i,2)<upper && left_pts(i,1)>bottom && left_pts(i,1)<top
                left_pts_ = [left_pts_;left_pts(i,:)];
            end
        end
    else
        left_pts_ = sorted_left;
    end
    
    sorted_right = sort(right_pts,1);
    n_r = size(right_pts,1);
    right_pts_ = [];
    if n_r > 10
        lower = sorted_right(int32((1-upper_close_to_center)*n_r),2);
        upper = sorted_right(int32((1-lower_close_to_center)*n_r),2);
        top = sorted_right(int32((1-top_bottom)*n_r),1);
        bottom = sorted_right(int32(top_bottom*n_r),1);
        for i=1:n_r
            if right_pts(i,2)>lower && right_pts(i,2)<upper && right_pts(i,1)>bottom && right_pts(i,1)<top
                right_pts_ = [right_pts_;right_pts(i,:)];
            end
        end
    else
        right_pts_ = sorted_right;
    end
    
    img2 = uint8(zeros(rows,cols));
    for i=1:size(left_pts,1)
        img2(left_pts(i,1),left_pts(i,2)) = 255;
    end
    for i=1:size(right_pts,1)
        img2(right_pts(i,1),right_pts(i,2)) = 255;
    end
    
    img3 = uint8(zeros(rows,cols));
    for i=1:size(left_pts_,1)
        img3(left_pts_(i,1),left_pts_(i,2)) = 255;
    end
    for i=1:size(right_pts_,1)
        img3(right_pts_(i,1),right_pts_(i,2)) = 255;
    end
    
    if ~isempty(left_pts_)
        left_point = int32(mean(left_pts_,1));
        img_ = insertShape(img_,'FilledCircle',[left_point(2) left_point(1) 5],'color','r');
        left_point = flip(double(left_point)./size(img)).*size_yz_mm;
    else
        left_point = [];
    end
    if ~isempty(right_pts_)
        right_point = int32(mean(right_pts_,1));
        img_ = insertShape(img_,'FilledCircle',[right_point(2) right_point(1) 5],'color','r');
        right_point = flip(double(right_point)./size(img)).*size_yz_mm;
    else
        right_point = [];
    end
end

%% functions for circle fitting
% P(t) = r*cos(t)*u + r*sin(t)*(n x u) + C
function P_circle=generate_circle_by_vectors(t,C,r,n,u)
    n = n/norm(n);
    u = u/norm(u);
    P_circle = r*cos(t).*u+r*sin(t).*cross(n,u)+C;
end

function P_circle=generate_circle_by_angles(t,C,r,theta,phi)
    n = [cos(phi)*sin(theta);sin(phi)*sin(theta);cos(theta)];
    u = [-sin(phi);cos(phi);0];
    P_circle=generate_circle_by_vectors(t,C,r,n,u);
end

% Implicit circle function:
% (x-xc)^2 + (y-yc)^2 = r^2
% =(2*xc)*x + (2*yc)*y + (r^2-xc^2-yc^2) = x^2+y^2
% =c(0)*x + c(1)*y + c(2) = x^2+y^2
% Solution by method of least squares:
% A*c = b, c' = argmin(||A*c - b||^2)
% A = [x y 1], b = [x^2+y^2]
function [xc,yc,r]=fit_circle_2d(x,y)
    A = [2*x 2*y ones(length(x),1)];
    b = x.^2+y.^2;
    c = pinv(A)*b;
    xc = c(1);
    yc = c(2);
    r = sqrt(c(3)+xc^2+yc^2);
end

% RODRIGUES ROTATION
% Rotate given points based on a starting and ending vector
% Axis k and angle of rotation theta given by vectors n0,n1
% P_rot = P*cos(theta) + (k x P)*sin(theta) + k*<k,P>*(1-cos(theta))
% k = n0 x n1 = normal x [0 0 0]'
% P is a point [xc;yc;0]
function P_rot=rodrigues_rotation(P,n0,n1)
    n0 = n0/norm(n0);
    n1 = n1/norm(n1);
    k = cross(n0,n1);
    k = k/norm(k);
    theta = acos(dot(n0,n1));
    
    P_rot = zeros(size(P));
    for i=1:size(P,2)
        P_rot(:,i) = P(:,i)*cos(theta)+cross(k,P(:,i))*sin(theta)+k.*dot(k,P(:,i))*(1-cos(theta));
    end
end



%% functions for vscan
function output = vscan2nice(vscan)
%RAW2NICE takes a 2d matrix of OCT raw data acquired from the Thorlabs OCT 
% system and converts it to nicely scaled grayscale
% MJG 2021-08-01; v1

    % scaling limits
    % these are fixed/constant and based on experience and the assumption
    % that we always set the reference arm length to be the same when
    % acquiring OCT data from the Thorlabs system 
    minint = 20;
    maxint = 70;

    % saturate the intensity
    vscan(vscan<minint) = minint;
    vscan(vscan>maxint) = maxint;

    % before we scale the image to [0,1], 
    % we need to ensure the bounds will remain the same, so we force two of
    % the pixels to be 0 and 1 so the min/max limits act exist
    % choose the bottom of the data for this, since those pixels are out of
    % hte way and unimportant 
    vscan(end,end,1) = minint;
    vscan(end,end,2) = maxint;
    
    % norm [0,1] (convert to grayscale)
    % vscan = unorm(vscan);
    
    % now reset those two points
    vscan(end,end,1) = 0;
    vscan(end,end,2) = 0;

    output = vscan;
end

function [tts,traj2,x]=optimal_trajectory(pts,vi_vf,spd_pts,VC,AC,JC,gamma)
    global pts;
    global vi_vf
    global n;n = length(pts)-1;
    global m;m = size(pts,2);
    global gamma;
    global VC;global AC;global JC;
    global spd_pts;
    A = [];
    b = [];
    Aeq = [];
    beq = [];
    lb = [];
    ub = [];
    x0 = .5*ones(1,(4*m+1)*n);
    x0(end-n+1:end) = sqrt(sum(diff(pts).^2,2))./max(spd_pts)*.8;
    %x0(end-1) = .1;
    % interior-point sqp sqp-legacy trust-region-reflective active-set
    option = optimoptions(@fmincon,'Algorithm','sqp','MaxIterations',10000,'ConstraintTolerance',1e-6,'MaxFunctionEvaluations',100000);
    [x,fval] = fmincon(@objfun,x0,A,b,Aeq,beq,lb,ub,@confuneq,option);
    
    dtt = 0.001;
    tts = 0:dtt:sum(x(4*m*n+1:end));
    dt_ = tts(2)-tts(1);
    acc_ts = zeros([1,n]);
    for i=1:n
        acc_ts(i+1) = acc_ts(i)+x(4*m*n+i);
    end

    dt = tts-acc_ts(1:end-1)';
    for i=1:length(tts)
        temp_t = tts(i);
        temp = zeros([n 1]);
        for j=1:length(acc_ts)-1
            if temp_t>acc_ts(j) && temp_t<=acc_ts(j+1)
                temp(j) = 1;
            end
        end
        dt(:,i) = dt(:,i).*temp;
    end

    for i=1:m
        As{i} = reshape(x(4*n*(i-1)+1:4*n*i),[4 n])';
    end

    traj2 = zeros([size(dt,2) 2]);
    for i=1:size(traj2,1)
        temp = [ones([n,1]).*(dt(:,i)>0) dt(:,i) dt(:,i).^2 dt(:,i).^3];
        for j=1:m
            traj2(i,j) = sum(sum(temp.*As{j}));
        end
    end
    traj2(1,:) = pts(1,:);
end

%%
function f=objfun(x)
    global n;
    global gamma;
    global m;
    tt = x(4*m*n+1:end);
    for i=2:m
        tt = [tt x(4*m*n+1:end)];
    end
    f = sum(x(4*m*n+1:end))+gamma*sum(x([4*(1:m*n)]).^2.*tt);
    %f = sum(x(4*m*n+1:end))+gamma*sum(x([4*(1:m*n)]).^2);
end

function [c,ceq] = confuneq(x)
    global pts;global VC;global AC;global JC;
    global vi_vf
    n = length(pts)-1;
    m = size(pts,2);
    T = zeros([4*n 4*n]);
    Y = zeros([4*n m]);
    for i=1:n
        T(2*i-1:2*i,4*i-3:4*i) = [1 0 0 0;1 x(4*m*n+i) x(4*m*n+i)^2 x(4*m*n+i)^3];
        Y(2*i-1:2*i,:) = [pts(i,:);pts(i+1,:)];
    end
    T(2*n+1,2) = 1;
    T(2*n+2,4*n-3:4*n) = [0 1 2*x(end) 3*x(end)^2];
    Y(2*n+1:2*n+2,:) = vi_vf;
    for i=1:n-1
        T(2*n+2*i+1:2*n+2*i+2,4*i-3:4*i+4) = [0 1 2*x(4*m*n+i) 3*x(4*m*n+i)^2 0 -1 0 0;0 0 1 3*x(4*m*n+i) 0 0 -1 0];
    end
    A = x(1:4*m*n)';
    Y = reshape(Y,[4*m*n,1]);
    T_ = T;
    tt = x(4*m*n+1:end);
    for i=2:m
        T_ = blkdiag(T_,T);
        % tt = [tt x(4*m*n+1:end)];
    end
    ceq = T_*A-Y;
    
    % speed assignments (start and end speed=0)
    global spd_pts;
    for i=2:length(spd_pts)-1
        temp = 0;
        for j=1:m
            temp = temp+x(4*(i-1)+2+4*n*(j-1))^2;
        end
        ceq = [ceq;sqrt(temp)-spd_pts(i)];
    end
    
    % robot constraints
    vel_con1 = (x(4*(1:n)-2))';
    vel_con2 = x(4*(1:n)-2)'+2*x(4*(1:n)-1)'.*tt'+3*x(4*(1:n))'.*tt'.^2;
    vel_con3_a3 = x(4*(1:n))';vel_con3_a2 = x(4*(1:n)-1)';vel_con3_a1 = x(4*(1:n)-2)';
    acc_con = [(2*x(4*(1:n)-1))';(2*x(4*(1:n)-1)+6*x(4*(1:n)).*tt)'];
    jerk_con = [(6*x(4*(1:n)))'];
    for i=2:m
        a1 = x(4*((i-1)*n+1:i*n)-2);
        a2 = x(4*((i-1)*n+1:i*n)-1);
        a3 = x(4*((i-1)*n+1:i*n));
        vel_con3_a3 = [vel_con3_a3 a3'];vel_con3_a2 = [vel_con3_a2 a2'];vel_con3_a1 = [vel_con3_a1 a1'];
        vel_con1 = [vel_con1 a1'];
        vel_con2 = [vel_con2 a1'+2*a2'.*tt'+3*a3'.*tt'.^2];
        acc_con = [acc_con [2*a2';(2*a2+6*a3.*tt)']];
        jerk_con = [jerk_con 6*a3'];
    end
    
    % a0+a1*t+a2*t^2+a3*t^3 x1=a3^2 x2=a2^2 x3=a1^2 x4=a2*a3 x5=a1*a3 x6=a2*a1
    x1 = sum(vel_con3_a3.^2,2);x2 = sum(vel_con3_a2.^2,2);x3 = sum(vel_con3_a1.^2,2);
    x4 = sum(vel_con3_a3.*vel_con3_a2,2);x5 = sum(vel_con3_a3.*vel_con3_a1,2);x6 = sum(vel_con3_a1.*vel_con3_a2,2);
    vel_con3 = zeros(n,1);
    % speed = (3*a3*t^2+2*a2*t+a1)^2 = 9*a3^2*t^4+12*a2*a3*t^3+(4*a2^2+6*a1*a3)*t^2+4*a1*a2*t+a1^2
    % optimal time at => derivative: 36*a3^2*t^3+36*a2*a3*t^2+(8*a2^2+12*a1*a3)*t+4*a1*a2=0
    for i=1:n
        opt_t = roots([9*x1(i) 9*x4(i) (3*x5(i)+2*x2(i)) x6(i)]);
        for j=1:length(opt_t)
            if opt_t(j)>0 && opt_t(j)<x(m*n+i)
                opt_v = sqrt(9*x1(i)*opt_t(j)^4+12*x4(i)*opt_t(j)^3+(4*x2(i)+6*x5(i))*opt_t(j)^2+4*x6(i)*opt_t(j)+x3(i));
                if vel_con3(i)<opt_v
                    vel_con3(i)=opt_v;
                end
            end
        end
    end
    vel_con = max([sqrt(sum(vel_con1.^2,2)) sqrt(sum(vel_con2.^2,2)) vel_con3],[],2)-VC;
    % vel_con = max([sqrt(sum(vel_con1.^2,2)) sqrt(sum(vel_con2.^2,2))],[],2)-VC;
    acc_con = sqrt(sum(acc_con.^2,2))-AC;
    jerk_con = sqrt(sum(jerk_con.^2,2))-JC;
    t_con = -x(4*m*n+1:end)';
    %t_con = max(max(abs(diff(pts)/VC)))-x(8*n+1:end)';
    c = [vel_con;acc_con;jerk_con;t_con];
end

%% differential
function df=differential(x,y)
    h = x(2)-x(1);
    n = length(x);
    if size(y,1)~=n
        y_ = y';
    else
        y_ = y;
    end
    D = -diag(ones(1,n-1),-1)/(2*h)+diag(ones(1,n-1),1)/(2*h);
    D(1,1) = -3/(2*h);
    D(1,2) = 4/(2*h);
    D(1,3) = -1/(2*h);
    D(n,n) = -3/(2*h);
    D(n,n-1) = 4/(2*h);
    D(n,n-2) = -1/(2*h);
    
    df = D*y_;
    if size(y,1)~=n
        df = df';
    end
end

function ddf=differential2(x,y)
    h = x(2)-x(1);
    n = length(x);
    if size(y,1)~=n
        y_ = y';
    else
        y_ = y;
    end
    D = diag(ones(1,n-1),-1)/(h^2)-2*diag(ones(1,n))/(h^2)+diag(ones(1,n-1),1)/(h^2);
    D(1,1) = 1/(h^2);
    D(1,2) = -2/(h^2);
    D(1,3) = 1/(h^2);
    D(n,n) = 1/(h^2);
    D(n,n-1) = -2/(h^2);
    D(n,n-2) = 1/(h^2);
    
    ddf = D*y_;
    if size(y,1)~=n
        ddf = ddf';
    end
end