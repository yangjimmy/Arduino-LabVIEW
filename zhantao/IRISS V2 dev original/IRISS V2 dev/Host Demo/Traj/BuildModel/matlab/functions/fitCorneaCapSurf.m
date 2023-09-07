function corn_epi_px = fitCorneaCapSurf(corneaCap)
%fitCorneaCapSurf 2021-09-06 MJG 
% fit pts to the top of the cornea cap

% create x and y pts 
xi = repmat((1:1:400)', 400, 1);
yi = repelem((1:1:400)', 400);

% find topmost points (all)
[~, topmostPoints] = max(corneaCap, [], 1);

% nota: xyz for cap pts 
capPts = [xi yi topmostPoints(:)];

% remove all rows (xyz pts) where z == 1
capPts(capPts(:,3)==1, :) = [];

% fit surface to cap points; these are good pts (by assumption)
surffit_cap = fit([capPts(:,1), capPts(:,2)], capPts(:,3), 'poly22'); %, 'normalize', 'on');

% eval surf model at each value of xi and yi 
fit_cornCap_Top = surffit_cap(xi,yi);

% reshape back into 2D; round to nearest integer and convert to uint8 to
% reduce the size
corn_epi_px = uint8(round(reshape(fit_cornCap_Top, 400, 400)));

end

