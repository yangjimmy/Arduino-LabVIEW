function scanType = processVSCAN_v2(SCAN_NO)
% 2021-09-09 MJG Build Anatomical Model - version 2
% This code is the entry point to processing a vscan
% > Reads a vscan .raw into memory, det if ACh or PC, then runs img proc

% Get string SCAN_NO from Labview
SCAN_NO = str2double(SCAN_NO);

% 1/2 the dist b/t the "purple marks" = radius of "clean cornea"
corneaCapRadius_mm = 2.5; % [mm]

% directory with .raw, .toi, and .srm files
DDIR = 'D:\IRISSoft LV2016 beta\Host Demo\OCTData';
% directory to save the .mat models for Martin's code
MDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\modelFiles';
% catch-all save diretory 
SDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\savedData';
% path to the constant .mat data file for pupil processing 
PATH2SLICES = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\supportFiles\sliceCoords.mat';
% path to the trained model (.mat file); this is version 2
model_filename = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\supportFiles\dockingNET_v20210903002411377.mat';
% add all functions to search path 
addpath('D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\functions');

% ---

% refractive index inside eye (from Harrison's experiment)
refIndex = 0.88; 

% by definition (see loadvscan.m), xyz (all three) mm/px is this ratio
ratio_mm = 0.025;

% Add trailing slash to all directories if they weren't specified by user
if DDIR(end) ~= filesep; DDIR(end+1) = filesep; end 
if MDIR(end) ~= filesep; MDIR(end+1) = filesep; end 
if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end 

% build paths to vscan .raw data 
filename_raw = [DDIR 'Model3D_' num2str(SCAN_NO, '%04i') '.raw'];

% Open vscan, normalize, and scale 
vscan = loadvscan(filename_raw);

% Determine if it's a scan of the ACh or PC 
clear determineAChPC;
scanType = determineAChPC(vscan);

% run code depending on the case
switch scanType 
    case 1
        clc; disp('Code says: This is ANTERIOR CHAMBER (ACh)');
        SCAN_NO_ACh = SCAN_NO;
        save([SDIR 'SCAN_NO_ACh.mat'], 'SCAN_NO_ACh');
        clear process_ACh_v2;
        run('process_ACh_v2.m');
        trajGenConverter_ACh(SDIR, MDIR, SCAN_NO_ACh); % <<<MIA
    case 0
        clc; disp('Code says: This is POSTERIOR CAPSULE (PC)');
        SCAN_NO_PC = SCAN_NO; 
        save([SDIR 'SCAN_NO_PC.mat'], 'SCAN_NO_PC');
        clear process_PC_v2;
        run('process_PC_v2.m');
        % 3. convert this data/params into code that Martin's traj gen expects;
        trajGenConverter_PC(SDIR, MDIR, SCAN_NO_PC); % <<<MIA
    otherwise
        disp('something seriously wrong...');
end % switch 


end % fx