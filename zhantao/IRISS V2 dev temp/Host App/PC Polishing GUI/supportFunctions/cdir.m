function directory = cdir(directory)
%CDIR "check directory" 2021-10-30 MJG 
%   Checks if directory exists; if not, errors out 
%   If directory does exist, then adds a trailing slash if the path doesn't
%   already have one 

% error out if does not exist 
if ~exist(directory, 'dir')
    error(['Directory does not exist: ' directory]);
end

% add trailing slash if does not exist 
if directory(end) ~= filesep
    directory(end+1) = filesep;
end 

end