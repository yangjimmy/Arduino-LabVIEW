% 2021-09-07 MJG 
% > Process the vscan knowing it's a scan of the ACh
% > Find corneal endothelium (endo) and iris/pupil
% > For the ACh scan, we use a trained model to segment the anatomy. 
% Note: Since this script is directly called in processVSCAN_v2, 
% many of the path directories, etc. are already in memory  

% build paths... 
filename_toi = [DDIR 'Model3D_' num2str(SCAN_NO_ACh, '%04i') '.toi'];
filename_srm = [DDIR 'Model3D_' num2str(SCAN_NO_ACh, '%04i') '.srm'];

% Load OCTz and TOI vals from the SRM and TOI files 
[OCTz_ACh, TOI_ACh] = readScanData(filename_toi, filename_srm);

% build path to segmentation file 
segfile = [SDIR 'segim' num2str(SCAN_NO_ACh,'%04i') '.mat'];

% check if this vscan has already been segmented---if so, just load the
% results; if not, then need to segment the data using the trained model
if exist(segfile, 'file')
    disp('segim.mat file found; using segim.mat file');
    load(segfile, 'segim'); 
else
    disp('No segim.mat file detected; Starting segmentation.');
    % load the trained model
    load(model_filename, 'net');
    % convert the vscan to the format the model expects (model was trained on actual images)
    cscan = uint8(255 * vscan);
    % convert 3d matrix to 4d; in prep for the segmentation
    cscan = permute(cscan, [1 2 4 3]);
    % Perform the actual inference/segmentation (takes awhile).
    % Note: you should be able to crank up the minibatchsize some more
    segim = semanticseg(cscan, net, 'OutputType', 'uint8', 'MiniBatchSize', 8); 
    disp('Finished segmentation!');
    % Save the results so we don't have to do this again
    save(segfile, 'segim'); 
end

% process the cornea to get endothelium (endo) pts [px] {O}
[endo_pts_px, corn_pts_px, lowestEndoPt, corneaThickness] = postprocess_cornea(segim == 2, corneaCapRadius_mm);

% process the iris to get iris data and pupil pts [px] {O} 
[iris_pts_px, pupil_pts_px] = postprocess_iris(segim == 3, lowestEndoPt, PATH2SLICES);

% ---

% convert all points to [mm] {O} and scale Z by refIndex 
endo_pts_mm = scale2mm(endo_pts_px, ratio_mm, refIndex);
corn_pts_mm = scale2mm(corn_pts_px, ratio_mm, refIndex);
iris_pts_mm = scale2mm(iris_pts_px, ratio_mm, refIndex);
pupil_pts_mm = scale2mm(pupil_pts_px, ratio_mm, refIndex);
% UPDATED 2021-09-13 YKL: covert corneaThickness from [px] {C} to [mm] {O}
corneaThickness = corneaThickness / 40;

% 3D circle fit to pupil points --- UPDATED 2021-09-13 MJG 
% Both the plotting code and Martin's code needs this, so we do it here
% and save the results 
[pupilCenter, opticalCenter, pupilRadius, ~] = fit3Dcircle(pupil_pts_mm);

% save all this data to a .mat file
save([SDIR 'params_ACh_' num2str(SCAN_NO_ACh,'%04i') '.mat'], ...
    'endo_pts_mm', 'corn_pts_mm', 'iris_pts_mm', 'pupil_pts_mm', ...
    'refIndex', 'OCTz_ACh', 'TOI_ACh', 'corneaThickness', ...
    'pupilCenter', 'opticalCenter', 'pupilRadius');

