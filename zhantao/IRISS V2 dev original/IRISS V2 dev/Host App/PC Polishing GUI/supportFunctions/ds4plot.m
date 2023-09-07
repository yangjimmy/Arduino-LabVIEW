function xyz = ds4plot(pcloud)
%DS4PLOT 2021-10-31 MJG
%   Reduce the number of points in a pcloud for use in plotting 

% convert to xyz coordinates 
[z, x, y] = ind2sub(size(pcloud), find(pcloud));

% if size is large, then calc n; else no downsample is done
if size(x,1) > 100000
    n = round(size(x,1) / 100000);
    xyz = downsample([x y z], n);
else
    xyz = [x y z];
end

