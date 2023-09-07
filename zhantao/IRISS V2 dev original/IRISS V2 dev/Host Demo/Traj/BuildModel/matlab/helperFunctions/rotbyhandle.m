function rotbyhandle(h, R, p, a)
% 2021-10-05 MJG 
    % rotate the XYZ data in plot handle h by rotation matrix R, using
    % point p as the origin
    % the value 'a' (usually = 1 or 2) represents which element (col) of XYZData you want to
    % apply it to; so for a single XYZ point, a = 1

    % get the xyz data from the handle and center it to the origin p 
    ph = [h.XData(a); h.YData(a); h.ZData(a)] - p;

    % apply the rotation and add back the shift p 
    ph = R * ph + p;

    % update the handle's xyz data 
    h.XData(a) = ph(1);
    h.YData(a) = ph(2); 
    h.ZData(a) = ph(3);
    

end