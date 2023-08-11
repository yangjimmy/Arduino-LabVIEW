function [xc, yc, zc] = findEyeCenter(vscan)
%FINDEYECENTER 2021-09-06 MJG; 
% input: 3d binary array of points; this code attempts to find a rough
% measure of "eye center" in order to better target later steps 

% DEV
% vscan = cornLabels

% bounds; in [px] for isolating a ROI around the {OCT} center (200,200)
% that's expected to include the actual center (xc,yc) that we're searching
% for 
lb = 101;
rb = 300;
ww = rb - lb + 1; % width of ROI

% get xyz pts of the top of the cornea data near the center (ROI)
topp = logical(cumsum(vscan(:, lb:rb, lb:rb)));
topp = topp(1:end-1,:,:) - topp(2:end,:,:);
[ztop, xtop, ytop] = ind2sub(size(topp), find(topp));

% fit 3d surface; we're doing this rather than a more low-level data
% processing approach because this type of (least-squares) method is more
% robust towards a few outliers
roughCornFit = fit([xtop,ytop], ztop, 'poly22'); 

% create x and y pts 
xitop = repmat((1:1:ww)', ww, 1);
yitop = repelem((1:1:ww)', ww);

% eval surf model at each value of xi and yi 
zitop = roughCornFit(xitop, yitop);

% the min val of z is going to be the peak 
zc = min(zitop);

% get idx of that val
idx = find(zitop==zc);

% and pull vals of x,y, adding back on the cropped value (to return to full
% {OCT} coords
xc = xitop(idx) + lb;
yc = yitop(idx) + lb;

% p1 = pbin3(vscan);

% NOTE: I didn't actually check if the crop/pad is exactly correct; with
% matlab's 1-indexing, it may be +/- 1 px off---not important for our
% purposes at all since we just need a rough estimate of center
% NOTE 2: The x/y might actually be reversed... 

end