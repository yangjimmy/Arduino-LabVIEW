function [OCTz, TOI] = readScanData(SCAN_NO, DDIR)
% READSCANDATA ~ Reads .srm and .toi files to retrieve OCTz and TOI
% 2021-08-24 MJG 
% NOTE: If a file is not found, this code will output OCTz = 0 and/or TOI =
% eye(4) rather than crash on an error 

% Add trailing slash to all directories if they weren't specified by user
if DDIR(end) ~= filesep; DDIR(end+1) = filesep; end 

% build path names
filename_toi = [DDIR 'Model3D_' num2str(SCAN_NO, '%04i') '.toi'];
filename_srm = [DDIR 'Model3D_' num2str(SCAN_NO, '%04i') '.srm'];

% check if the file exists to avoid the hard error
if isfile(filename_srm)
    % open SRM file 
    fid = fopen(filename_srm);
    % move the cursor 24 characters from the end
    fseek(fid, -24, 'eof');
    % scan the text for the pattern STRING STRING FLOAT
    config = textscan(fid,'%s %s %f');
    % get the number (OCTz) 
    OCTz = config{1,3};
    % close access to the file
    fclose(fid);
else
    OCTz = 0;
end

% check if the file exists to avoid the hard error
if isfile(filename_toi)
    % Can just read the file into the variable 
    TOI = load(filename_toi, '-ASCII');
else
    TOI = eye(4);
end

end