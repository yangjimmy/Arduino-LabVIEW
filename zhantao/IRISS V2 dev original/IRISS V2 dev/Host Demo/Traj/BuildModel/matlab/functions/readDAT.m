function OCTz = readDAT( filename_dat )
% MJG: reads the VSCAN_####.dat file and outputs DBL OCTz value 

% open
fid = fopen(filename_dat);

% read
OCTz = fscanf(fid, '%f');

% close 
fclose(fid);

