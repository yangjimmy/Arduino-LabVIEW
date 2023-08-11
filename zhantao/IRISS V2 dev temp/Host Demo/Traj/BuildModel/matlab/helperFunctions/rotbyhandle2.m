function rotbyhandle2(h, R, p)
% 2021-10-05 MJG 
% same thing as rotbyhandle(), but 
    % rotate the XYZ data in plot handle h by rotation matrix R, using
    % point p as the origin

    % get the xyz data from the handle and center it to the origin p 
    ph = [h.XData; h.YData; h.ZData] - p;

    % apply the rotation and add back the shift p 
    ph = R * ph + p;

    % update the handle's xyz data 
    h.XData = ph(1);
    h.YData = ph(2); 
    h.ZData = ph(3);
    

end