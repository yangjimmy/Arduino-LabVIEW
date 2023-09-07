function scanType = processVSCAN(SCAN_NO)
% 2021-08-25 MJG 
% Loads a vscan, normalizes it, and determines the type (ACh or PC)
% 
% directory where the vscans and their .toi and .srm files are located
DDIR = 'D:\IRISSoft LV2016 beta\Host Demo\OCTData';
% directory to save the models for Martin's code
MDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\modelFiles';
% save diretory for plotting params, etc. 
SDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\savedData';
% 
% % --- statics the code uses 
% path to the constant .mat data file for processing iris/pupil scans
PATH2SLICES = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\supportFiles\sliceCoords.mat';
% path to the trained model (.mat file); constant, once I have good one...
model_filename = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\supportFiles\dockingNET_v20210823170052555.mat';
% subfunctions folder; add to path... unorm, natsort, etc. 
addpath('D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\functions');

% % refractive index inside eye (from Harrison experiment)
refIndex = 0.88; 
% 
% % Add trailing slash to all directories if they weren't specified
if DDIR(end) ~= filesep; DDIR(end+1) = filesep; end 
if MDIR(end) ~= filesep; MDIR(end+1) = filesep; end 
if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end 
% 
% % build path to needed files
filename_raw = [DDIR 'Model3D_' SCAN_NO '.raw'];
filename_toi = [DDIR 'Model3D_' SCAN_NO '.toi'];
filename_srm = [DDIR 'Model3D_' SCAN_NO '.srm'];
% 
% % VSCAN size (constant)
size_xyz = [400 400 1024];
% 
% % mm2px ratio (constant across all xyz dims, by design);
ratio_mm = 0.025;
% 
% 
% Open volume scan and read in 
fid = fopen(filename_raw);
vscan = fread(fid, prod([400 400 1024]), 'float32');
vscan = reshape(vscan, flip(size_xyz));
fclose(fid);
% 
% % --- Scale/normalize VSCAN intensities 
% 
% % constant saturation limits
minint = 20;
maxint = 70;
% 
% % saturate intensity across the whole VSCAN
vscan(vscan<minint) = minint;
vscan(vscan>maxint) = maxint;
% 
% % before we scale the vscan to [0,1], we must ensure the bounds will remain
% % the same, so we force two of the pixels to be 0 and 1 so that the min/max
% % limits actually exist. I choose two pixels on the bottom of the first 
% % BSCAN for this, since we know those will be out of the way and unimportant
vscan(end,1,end) = minint;
vscan(end,2,end) = maxint;
%     
% % norm [0,1] (convert to grayscale), MJG custom function (req. mjglib)
vscan = unorm(vscan);
% 
% % I made a decision here that's open to debate
% % In the interest of speed---but at the sacrifice of accuracy---the VSCAN
% % is resized down to 1:1 pixel ratio NOW. This makes the image size smaller
% % (and the model inference faster), but at the loss of image information
% % (lost during the resizing).
% % the new size is (note the ZXY order)
vscan_zxy = [376 400 400];
% % then the resize is performed: 
vscan = imresize3(vscan, vscan_zxy);
% 
% % --- Determine if it's a scan of the ACh or PC 
% 
% % The assumption is that for a ACh vscan, the top ~3 mm will be filled with
% % cornea/docking and be high intensity; cf. PC vscan which will be
% % comparatively low intensity; only need to look at a single scan here,
% % somewhere in the middle (yy~=200)
% % scanType == 1 ACh; scanType == 0 PC
% Note: LV requires this value to be a double (DBL, float)
scanType = double(mean2(vscan(1:120, :, 200)) > 0.25);


% % run different code depending on the value of intMetric
if scanType == 1    
    run('process_ACh.m');
else
    run('process_PC.m');
end

end % fx



