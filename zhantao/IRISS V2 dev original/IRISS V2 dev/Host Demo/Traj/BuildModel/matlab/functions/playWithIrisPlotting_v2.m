% 2021-08-19 MJG just focusing on modeling the pupil...

% input: full [px] iris pts (not downsampled...
iris_xyz = [iris_xx iris_yy iris_zz];

%% det where radially slices should be

% the number of slices we want 
desiredSlices =  50;

% we assume the center of the pupil is roughly the scan center 
ac_px = [200 200];

% the angle b/t slice planes, determined by the number of desired slices 
psi = 360/desiredSlices/2; % [deg]

% angle of each slice... [rad]
alpha = deg2rad(180-psi:-psi:0);

% unit directions, initialize
na = [ones(1,desiredSlices); zeros(1,desiredSlices)];

% loop through each col of n and rotate by alpha
for ii = 1:desiredSlices
    R = [cos(alpha(ii)) -sin(alpha(ii)); sin(alpha(ii)) cos(alpha(ii))];
    na(:,ii) = R*na(:,ii);
end

% to append: the other side of slices
nb = -na;
% 
% % % check so far; looks good. 
% % % these are just unit directions, centered at the origin...
% figure(1); clf;
% plot(0,0,'k.'); hold on; grid on; axis equal; 
% xlabel('y OCT'); ylabel('x OCT');
% xlim([-1 1]); ylim([-1 1]);
% for ii = 1:desiredSlices
%     plot([na(1,ii) nb(1,ii)], [na(2,ii) nb(2,ii)], 'r-');
%     text(na(1,ii), na(2,ii), num2str(ii));
% end
% title('testing of generated unit directions');



% preallo our slice coordinates... 
sliceCoords = zeros(desiredSlices * 400, 2);

tic
for ii = 1:desiredSlices

%     ii
    
    if alpha(ii) <= deg2rad(45) 
        % fit line... 
        cf = fit([ac_px(1)+nb(1,ii); ac_px(1)+na(1,ii)], ...
                 [ac_px(2)+nb(2,ii); ac_px(2)+na(2,ii)], fittype('poly1'));

        % get A-scans
        x = (1:400)';
        y = round(cf(x));

        % peg ones to remove (out of bounds)
        to_remove = y < 1 | y > 400;
%         x(to_remove) = [];
%         y(to_remove) = [];

%         stored_data = [stored_data; x y];

    % if we're "near 90°", the fit won't be well-conditioned, so we flip
    % things, fit the line, then flip back... 
    elseif alpha(ii) > deg2rad(45) && alpha(ii) < deg2rad(135)
    
        % FLIP X and Y
        cf = fit([ac_px(2)+nb(2,ii); ac_px(2)+na(2,ii)],...
                 [ac_px(1)+nb(1,ii); ac_px(1)+na(1,ii)], fittype('poly1'));
        
        % get A-scans
        y = (1:400)'; % flip because of direction of Bscan build
        x = round(cf(y));
        
        % peg ones to remove (out of bounds)
        to_remove = x < 1 | x > 400;
%         x(to_remove) = [];
%         y(to_remove) = [];
        
%         stored_data = [stored_data; x y];
        
%         figure(2); plot(x, y, 'b.');
    
    elseif alpha(ii) >= deg2rad(135) 
        % fit line... 
        cf = fit([ac_px(1)+nb(1,ii); ac_px(1)+na(1,ii)], ...
                 [ac_px(2)+nb(2,ii); ac_px(2)+na(2,ii)], fittype('poly1'));

        % get A-scans
        x = flip((1:400)'); % need to flip so that the 
%         progression LOOKS okay, even though the idea of left-to-right direction doesn't apply anymore
        y = round(cf(x));

        % peg ones to remove (out of bounds)
        to_remove = y < 1 | y > 400;
%         x(to_remove) = [];
%         y(to_remove) = [];
%         
%         stored_data = [stored_data; x y];
    end

    % don't just remove, edit them to maintain data size...
    if to_remove(1) == 1
        x(1) = x(2);
        y(1) = y(2);
    end
    if to_remove(end) == 1
        x(end) = x(end-1);
        y(end) = y(end-1);
    end
%     
%     
%     x(to_remove) = [];
%     y(to_remove) = [];

    
    % update stored data... 
%     stored_data = [stored_data; x y];
    sliceCoords(ii*400-399:ii*400,:) = [x y];
    

    
end
toc

save('sliceCoords.mat', 'sliceCoords', 'desiredSlices');

% % intiialize plot
% figure(2); clf;
% plot(sliceCoords(:,1), sliceCoords(:,2), 'k.'); hold on; grid on; axis equal; 
% xlabel('x [px]'); ylabel('y [px]');
% % title('{OCT} [px] frame');
% 




%%

% okay, so now just loop through the slices, looking at the slice from the
% binary data... 

% load number of slices and their coordinates 
load('sliceCoords.mat');

% preallocate found pupil xyz points 
pupil_xyz = zeros(desiredSlices*2,3);

% loop through each radial slice
tic
for ii = 1:desiredSlices 

    % notation
    xy = sliceCoords(ii*400-399:ii*400,:);
    
    % generate slice from A-scan pts 
    slice = zeros(376,400);
    for jj = 1:400
        slice(:,jj) = iris3d_px(:, xy(jj,1), xy(jj,2));
    end

    % compress; this is which cols have data
    cols = sum(slice) > 0;
    % split into left/right halves:
    lcols = flip(cols(1:200));
    rcols = cols(201:400);
    
    % check if iris is actually present; if not set to NaN for later
    % removal
    if nnz(lcols) > 0
        % search for true px 
        [~, idxl] = max(lcols, [], 2);
        % unflip and adjust 
        idxl = 200-idxl+1;
        % now find z for each...; we find its vertical idx then mean whatever
        % we find (maybe not a good anatomical assumption)... since it finds
        % the middle of the iris, but fine for now until we can re-consider 
        pzl = mean(find(slice(:,idxl)));
        % get the actual X and Y values (global)---not the local slice coords!
        pxl = xy(idxl, 1);
        pyl = xy(idxl, 2);
    else
        pxl = NaN;
        pyl = NaN;
        pzl = NaN; 
    end
    if nnz(rcols) > 0
        % search for true px 
        [~, idxr] = max(rcols, [], 2);
        % unflip and adjust 
        idxr = idxr + 200;
        % find z 
        pzr = mean(find(slice(:,idxr)));
        % get the actual X and Y values (global)---not the local slice coords!
        pxr = xy(idxr, 1);
        pyr = xy(idxr, 2);
    else
        pxr = NaN;
        pyr = NaN;
        pzr = NaN;
    end
    
    % add detected pupil edges to data...
    pupil_xyz(ii*2-1:ii*2,:) = [pxl pyl pzl; pxr pyr pzr];
    
end
toc 

% remove rows of all NaN
pupil_xyz(all(isnan(pupil_xyz),2), :) = [];

% 3D circle fit to pupil points 
[centerLoc, circleNormal, radius] = CircFit3D(pupil_xyz);


%%

figure(1); clf;
% plot iris data 
hs = scatter3(iris_xyz(:,1), iris_xyz(:,2), iris_xyz(:,3), 1, [0.8 0.2 0.1]);
set(hs, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);
% plot params
hold on; grid on; axis equal; 
set(gca, 'zdir', 'reverse'); 
% plot pupil points used in circle fit 
hs = scatter3(pupil_xyz(:,1), pupil_xyz(:,2), pupil_xyz(:,3), 10, [0.2 0.2 1]);
set(hs, 'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', 0);

% plot pupil (center, normal, and circular edge)
plot3(centerLoc(1), centerLoc(2), centerLoc(3), 'g+');
plot3([centerLoc(1) centerLoc(1)+100*circleNormal(1)], ...
      [centerLoc(2) centerLoc(2)+100*circleNormal(2)], ...
      [centerLoc(3) centerLoc(3)+100*circleNormal(3)], 'g-', 'LineWidth', 2); 
plot3([centerLoc(1) centerLoc(1)-100*circleNormal(1)], ...
      [centerLoc(2) centerLoc(2)-100*circleNormal(2)], ...
      [centerLoc(3) centerLoc(3)-100*circleNormal(3)], 'g-', 'LineWidth', 2); 

% use 3rd party function to plot
circle_3D(radius, centerLoc, circleNormal);


