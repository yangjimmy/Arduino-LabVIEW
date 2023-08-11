function xyz_mm = scale2mm(xyz_px, ratio_mm, refIndex)
%scale2mm 2021-09-07 MJG 
% scale [px] pts to [mm] and scaling in z by refractive index 
% Updated 2021-09-18 MJG; the refIndex wasn't being applied correctly. 

% convert to [mm]
xyz_mm = ratio_mm * xyz_px;

% scale Z by refractive index..
xyz_mm(:,3) = refIndex * xyz_mm(:,3);

end

