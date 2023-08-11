function xyz = bin3toxyz(bin3)
%bin3toxyz 2021-09-07 MJG 
%   Convert a 3D binary to a listing (nx3) of xyz_px cordinates 

% ensure binary 
bin3 = bin3 > 0;

% find coordindates; note the order 
[z, x, y] = ind2sub(size(bin3), find(bin3));

% compile into single array for notation
xyz = [x y z];



end

