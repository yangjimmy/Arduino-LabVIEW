function INJECTloc_OCT = IOLSEG(VSCAN_DIR, manual, size_xyz, size_xz_mm, px2mm)
if manual == 1
    %% Locating Injection by hand for testing purposes    
    %BSCAN_DIR = [VSCAN_DIR num2str(64, '%04i') '.raw']; % scan halfway through
%     bscan = raw2bscan(BSCAN_DIR);
filename= [VSCAN_DIR,'.raw'];
fid= fopen(filename);
vscan=fread(fid, prod(size_xyz),'float32');
vscan=reshape(vscan,flip(size_xyz));
vscan = vscan/255; 
%% Only to look at the center scan plan
bscan=vscan(:,200,:);

    bscan = reshape(bscan, [1024, 400]); 
    figure(1); clf; 
    imshow(bscan); hold on;
%% Scannig through all the VSCAN data
% for ii = 1:400 
%     bscan = vscan(:,ii,:); 
%     bscan = reshape(bscan, [1024, 400]); 
%     figure(1); clf; 
%     imshow(bscan); 
% end

%     figure(1); clf; 
%     imshow(bscan); hold on;
    
    % Collect two user clicks of Injection location 
    [input1, Zinput1] = ginput(1);
    plot(input1, Zinput1, 'rx', 'MarkerSize', 20, 'LineWidth', 3); 
    [input2, Zinput2] = ginput(1); % Collect two user clicks 
    plot(input2, Zinput2, 'rx', 'MarkerSize', 20, 'LineWidth', 3); 
    
    Yinput1 = size_xyz(2) - input1; 
    Yinput2 = size_xyz(2) - input2;
    
    INJECTloc_px = [Yinput1, Zinput1; ... 
        Yinput2, Zinput2]; % [px] 
    INJECTloc_px_mid=[(INJECTloc_px(1,1)+INJECTloc_px(2,1))/2,(INJECTloc_px(2,1)+INJECTloc_px(2,2))/2];
    close(1); % close figure
    
    % Convert these two locations from pixels to {OCT} frame  
    xloc_OCT = 0.5*size_xz_mm(1); % B-scan is halfway through the image
    INJECTloc_OCT = [xloc_OCT*ones(1,1), INJECTloc_px_mid(1,1)*px2mm(1),  INJECTloc_px_mid(1,2)*px2mm(2)]; 

elseif manual == 2
filename= [VSCAN_DIR,'.raw'];
fid= fopen(filename);
vscan=fread(fid, prod(size_xyz),'float32');
vscan=reshape(vscan,flip(size_xyz));
vscan = vscan/255; 
%% Only to look at the center scan plan
% bscan=vscan(:,200,:);
% 
%     bscan = reshape(bscan, [1024, 400]); 
%     figure(1); clf; 
%     imshow(bscan); 
%% Scannig through all the VSCAN data
for ii = 1:400 
    bscan = vscan(:,ii,:); 
    bscan = reshape(bscan, [1024, 400]); 
    figure(1); clf; 
    imshow(bscan); 
end
    %% Image Processing
   
    for ii = 1:128
        BSCAN_DIR = [VSCAN_DIR num2str(ii-1, '%04i') '.raw'];
        bscan = raw2gray(BSCAN_DIR);
        
        % Display volume scan
        figure(1);
        imshow(bscan);       
    end

elseif manual == 3 
    %% Testing image processing 
    BSCAN_DIR = [VSCAN_DIR num2str(64, '%04i') '.raw']; % scan halfway through
    bscan = raw2gray(BSCAN_DIR);
    
    % imbin = imbinarize(bscan);

    % Spur and Clean (2x)
%     imspur = bwmorph(imbin, 'spur', Inf);  
%     imclean = bwmorph(imspur, 'clean', Inf);
% %     imspur2 = bwmorph(imclean, 'spur'); 
% %    imclean2 = bwmorph(imspur2, 'clean');
%     im = bwmorph(imclean, 'majority'); 
    
%     edges = edge(bscan, 'Sobel'); % edge detection 

%     % Show results 
%     figure(1); clf; 
%     subplot(121); 
%     imshow(bscan); 
%     subplot(122); 
%     imshow(im); 
    
end