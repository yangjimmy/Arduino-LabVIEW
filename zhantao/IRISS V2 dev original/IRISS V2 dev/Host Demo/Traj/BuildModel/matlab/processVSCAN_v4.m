function processVSCAN_v4(SCAN_NO_ACh)
% 2021-10-11 MJG Build Anatomical Model - version 4
%   Reads an ACh vscan into memory, segments it, models the PC, then plots
%   the full model into a GUI allowing the user to edit the params
%   ---- 
%   Updated 2021-09-23 MJG: Code now properly scales z depth by refIndex 
%   Updated 2021-11-11 MJG: Added GUI functionality 


% Get string SCAN_NO from Labview and change the variable name
SCAN_NO_ACh = str2double(SCAN_NO_ACh);

% add all functions to search path 
addpath('D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\functions');
addpath('D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\helperFunctions'); % for GUI

% Directory containing the .raw, .toi, and .srm files saved by LabView
DDIR = 'D:\IRISSoft LV2016 beta\Host Demo\PreOpVscans\';

% The save directory; location to read/write files
SDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\allSaves\';

% Specify the segmentation model to use
model_filename = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\supportFiles\dockingNET_v20210903002411377.mat';

% number of iris data points to save/display; orig val 40000
nIris = 40000/4;
% number of cornea data points to save/display; orig val 50000
nCorn = 50000/4;

% ---

% refractive index inside eye, from experiment 
refIndex = 0.74; 

% Ratio mm/px in OCT vscan, by definition = 0.025; see loadvscan.m
ratio_mm = 0.025;

% Open and process the vscan
vscan = loadvscan_v5(DDIR, SCAN_NO_ACh);

% Load OCTz and TOI vals from the SRM and TOI files 
[OCTz_ACh, TOI_ACh] = readScanData(SCAN_NO_ACh, DDIR);

% run the segmentation, or load previously derived segmentation
segim = runSegmentation(SDIR, SCAN_NO_ACh, model_filename, vscan);

% Process the cornea; get data {O} [px] 
% 2022-02-15 MJG: Added nCorn
[endo_pts_px, corn_pts_px, lowestEndoPt, corneaThickness_px, corn_epi_px] = ...
    postprocess_cornea(segim == 2, 2.5, nCorn);

% Process the iris; get iris and pupil data pts {O} [px] 
% 2022-02-15 MJG: Added nIris
[iris_pts_px, pupil_pts_px] = postprocess_iris(segim == 3, lowestEndoPt, SDIR, nIris);

% --- Everything above this point is {O} [px] --- % 

% Convert all points to [mm] {O} and scale Z by refIndex 
% 2021-09-23 MJG: This now scales the refIndex correctly (see link to paper 
% in function description.) 
endo_pts_mm  = scale2mmRefInt(endo_pts_px,  refIndex, ratio_mm, corn_epi_px);
corn_pts_mm  = scale2mmRefInt(corn_pts_px,  refIndex, ratio_mm, corn_epi_px);
iris_pts_mm  = scale2mmRefInt(iris_pts_px,  refIndex, ratio_mm, corn_epi_px);
pupil_pts_mm = scale2mmRefInt(pupil_pts_px, refIndex, ratio_mm, corn_epi_px);

% figure(4); clf;
% scatter3(iris_pts_px(:,1), iris_pts_px(:,2), iris_pts_px(:,3),'Marker', '.');
% grid on; grid minor; hold on; 
% xlim([0 400]); ylim([0 400]); zlim([0 1024]);

% UPDATED 2021-09-13 YKL: covert corneaThickness from [px] {C} to [mm] {O}
% 2021-09-23 MJG: added refIndex scaling 
corneaThickness_mm = refIndex * corneaThickness_px / 40;

%--- Perform modeling --- % 

% Pupil circle fit 
[pupilCenter, opticalCenter, pupilRadius, pupilCurvePts] = fit3Dcircle(pupil_pts_mm);

% Corneal endothelium surface fit 
surffit_endo = fit([endo_pts_mm(:,1), endo_pts_mm(:,2)], endo_pts_mm(:,3), 'poly22');

% Generate the PC model 
[p_bc, eqpts, Xdata, Ydata, Zdata, pcfitpts_mm] = ...
    generatePCmodel(pupilCenter, opticalCenter, pupilRadius);

% --- Convert params to Mia's data format --- %
% https://docs.google.com/spreadsheets/d/1t4bfVIIaAbXP61JEGQKT-zpibm8xWG-xJs_fPByoPyg/edit?usp=sharing
[PolyCoef_cornea_mm_IRISSframe, PolyCoef_post_mm_IRISSframe, SurfacePolyOrd] = ...
    convert4mia(TOI_ACh, endo_pts_mm, pcfitpts_mm);

% save all this data to a .mat file
if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end 
paramfilename = [SDIR 'allParams_' num2str(SCAN_NO_ACh,'%04i') '.mat'];
save(paramfilename, ...
    'SCAN_NO_ACh', ... 
    'PolyCoef_cornea_mm_IRISSframe', ...
    'SurfacePolyOrd', ...
    'pupil_pts_mm', ...
    'PolyCoef_post_mm_IRISSframe', ...
    'TOI_ACh', ...
    'corn_pts_mm', ...
    'endo_pts_mm', ...
    'iris_pts_mm', ...
    'refIndex', ...
    'OCTz_ACh', ...
    'corneaThickness_mm', ...
    'pupilCenter', ...
    'opticalCenter', ...
    'pupilRadius', ...
    'p_bc', ...
    'eqpts', ...
    'Xdata', ...
    'Ydata', ...
    'Zdata', ...
    'pupilCurvePts', ...
    'surffit_endo', ...
    'pcfitpts_mm'); % Added pc fit points as an output (09-20-21 Mia)

% Run the model GUI; allow user to modify model params
run('mainGUI_v1.m')


end % fx