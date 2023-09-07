function xyz = getxyzfromhandle(h)
%2021-10-06 MJG 
%   just get XYZData from a figure handle; easy notation

xyz = [h.XData; h.YData; h.ZData];

end