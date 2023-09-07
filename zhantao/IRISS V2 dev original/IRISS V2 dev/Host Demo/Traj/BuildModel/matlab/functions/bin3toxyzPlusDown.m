function xyz = bin3toxyzPlusDown(bin3, numpts)
%bin3toxyz 2021-09-07 MJG 
%   Convert a 3D binary to a listing (nx3) of xyz_px cordinates 
%   Then downsample those pts to the amount specified in numpts

% ensure binary 
bin3 = bin3 > 0;

% find coordindates; note the order 
[z, x, y] = ind2sub(size(bin3), find(bin3));

% compile into single array for notation
xyz = [x y z];

% ensure number of points we want to downsample to actually exist; if so, then
% downsample as intended; else just use however many points are actually
% available... 
if size(xyz,1) > numpts
    xyz = xyz(randperm(size(xyz,1), numpts)',:);
end


end

