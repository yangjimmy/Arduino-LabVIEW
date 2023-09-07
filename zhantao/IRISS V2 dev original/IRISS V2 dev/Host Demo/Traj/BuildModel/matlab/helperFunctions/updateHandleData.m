function  updateHandleData(handle, newpts)
%2021-10-06 MJG 
% Update a handles XYZData with newpts (3xn) where n >= 1 

    % update OC line 
    handle.XData = newpts(1,:);
    handle.YData = newpts(2,:);
    handle.ZData = newpts(3,:);
    


end