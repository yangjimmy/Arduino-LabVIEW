% 2021-09-07 MJG 
% process the PC data to attempt to find the PC 
% OUTPUT: PC_xyz_px points 

% depth in [mm] below which the PC does not exist. 
% note: due to eye dimensions, it's better if this is within the top 3 mm
% (previously told Kevin 4.5 mm) 
maskDepth = 3; % [mm]; 

% n-highest intensity points to choose from the vscan 
% this is an important value without a good way of choosing it. 
% > if too small and there's not enough PC pts detected 
% > if too large, then too much noise is detected 
pts2retain = 5000;


% --- 
% calc mask depth in [px] 
depth_px = floor(maskDepth/ratio_mm);

% build paths to required files (PC) 
% filename_raw = [DDIR 'Model3D_' num2str(SCAN_NO_PC, '%04i') '.raw'];
filename_toi = [DDIR 'Model3D_' num2str(SCAN_NO_PC, '%04i') '.toi'];
filename_srm = [DDIR 'Model3D_' num2str(SCAN_NO_PC, '%04i') '.srm'];



% Open vscan, normalize, and scale 
% vscan = loadvscan(filename_raw); % have this from main.m

% Load OCTz and TOI vals from the SRM and TOI files 
[OCTz_PC, TOI_PC] = readScanData(filename_toi, filename_srm);

% brute-force remove the top ~X px or so
vscan(1:15, :, :) = 0;

% get the corresponding ACh scan number:
load([SDIR 'SCAN_NO_ACh.mat'], 'SCAN_NO_ACh');

% load pupil parameters from the ACh segmentation
load([SDIR 'params_ACh_' num2str(SCAN_NO_ACh,'%04i') '.mat'], ...
    'pupil_pts_mm'); 
%     'OCTz_ACh', 'pupilCenter', 'pupilRadius', 'pupil_pts_mm'); 

% get a mask to remove the iris, leaving only the pupillary area 
% NOTE: it's much easier and accurate to just use the camera image... v3! 
irisMask = getPupilMask(pupil_pts_mm);

% extrude mask into 3d; 
% we want to keep everything within the pupilary area (the only place the
% PC could possible be located)
irisMask3D = permute(repmat(irisMask, 1, 1, 376), [3 1 2]);

% apply 3d mask to orig data; NOT binary 
vscanMasked = irisMask3D .* vscan;

% remove everything beneath maskDepth; 
dscan = vscanMasked(1:depth_px,:,:);

% remove reflection line, if one exists 
pcscan = removeRefLinePC(dscan, maskDepth);

% sum nearest neighbors
ascan = zeros(size(pcscan));
for yy = 2:399
    ascan(:,:,yy) = pcscan(:,:,yy-1) + pcscan(:,:,yy) + pcscan(:,:,yy+1);
end

% --- attempt to isolate PC data from BG noise

% get list of intensities in the whole cropped vscan
[~, sortedInds] = sort(ascan(:), 'descend');

% get those values 
brightestPixels = sortedInds(1:pts2retain);

% get the idxs
[zd, xd, yd] = ind2sub(size(ascan), brightestPixels);

% notation
pcpts_px = [xd yd zd];

% 0. convert all points to [mm] {O} and scale Z by refIndex 
pc_pts_mm = scale2mm(pcpts_px, ratio_mm, refIndex);

% 1. fit a surface to the [mm] {O} points 
% surffit_PC = fit([pc_pts_mm(:,1), pc_pts_mm(:,2)], pc_pts_mm(:,3), 'poly22');

% 2. save all data to a .mat file
save([SDIR 'params_PC_' num2str(SCAN_NO_PC,'%04i') '.mat'], ...
    'pc_pts_mm', 'OCTz_PC', 'TOI_PC');


