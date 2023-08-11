% This function reads *.srm file which records OCT scan configuration
% Cheng-Wei Chen | 2017-02-22

function [size_xyz ratio_mm OCTprobeZ TOI] = readSRM(filename)

fid = fopen([filename '.srm']);
config = textscan(fid,'%s %s %f',6);
size_xyz = [config{1,3}(4) config{1,3}(6) config{1,3}(2);];
ratio_mm = [config{1,3}(3) config{1,3}(5) config{1,3}(1);];

fseek(fid, -30, 'eof');
config2 = textscan(fid,'%s %s %f');
OCTprobeZ = config2{1,3};

fclose(fid);

if exist([filename '.toi'], 'file')
    TOI = load([filename '.toi'],'-ASCII');
else
    TOI = NaN;
end

end