function TOI = readTOI( filename )
%MJG: read saved VSCAN_####.toi file 
%   reads a .toi file saved in Labview

% open file for read-only
fid = fopen(filename, 'r');

% read file 
d = fscanf(fid, '%f');

% close file
fclose(fid);

% compile TOI
TOI = reshape(d, 4, 4)';

end