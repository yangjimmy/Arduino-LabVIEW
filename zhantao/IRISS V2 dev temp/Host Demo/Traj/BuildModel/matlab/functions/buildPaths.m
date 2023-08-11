function [DDIR, SDIR] = buildPaths(ROOT_DIR, DDIR)
%buildPaths 2021-09-20 MJG; 
%     Just build path/file names; very specific to this project 

% add trailing slash if wasn't specified 
if ROOT_DIR(end) ~= filesep; ROOT_DIR(end+1) = filesep; end 

% Add trailing slash to all directories if they weren't specified by user
if DDIR(end) ~= filesep; DDIR(end+1) = filesep; end 

[] = buildPaths(ROOT_DIR, DDIR);
strrep(filename_raw, '.raw', '.roi')


% Directory to save data (allParams.mat and segim.mat)
SDIR = 'C:\Users\stein\Desktop\2021-09-16 Bag Fitting\allSaves';
% path to the constant .mat data file for pupil processing 
PATH2SLICES = 'C:\Users\stein\Desktop\2021-09-16 Bag Fitting\supportFiles\sliceCoords.mat';
% path to the trained model (.mat file); this is version 2
model_filename = 'C:\Users\stein\Desktop\2021-09-16 Bag Fitting\supportFiles\dockingNET_v20210903002411377.mat';

if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end 

% Build the path to the vscan .raw data 
filename_raw = [DDIR 'Model3D_' num2str(SCAN_NO_ACh, '%04i') '.raw'];
filename_toi = [DDIR 'Model3D_' num2str(SCAN_NO_ACh, '%04i') '.toi'];
filename_srm = [DDIR 'Model3D_' num2str(SCAN_NO_ACh, '%04i') '.srm'];


end

