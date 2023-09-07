function vscan = getvscan(filename)
%GETVSCAN 2021-10-31 MJG
%   Load vscan into memory from filename; 
%   Assumes standard 400x400x1024 px size 

    fid = fopen(filename);
    vscan = fread(fid, 163840000, 'float32');
    vscan = reshape(vscan, [1024 400 400]);
    fclose(fid);

end