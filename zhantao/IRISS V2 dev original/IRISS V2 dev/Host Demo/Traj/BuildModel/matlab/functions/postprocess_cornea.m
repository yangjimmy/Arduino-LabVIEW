function [endo_pts_px, corn_pts_px, lowestEndoPt, corneaThickness, corn_epi_px] = postprocess_cornea(cornLabels, corneaCapRadius_mm, nCorn)
%process_cornea 2021-09-07 MJG 
%   post-Process the segmentation results to extract the endothelium
%   the 'corneaCapRadius_mm' is the distance b/t the purple marks in the
%   B-scans slides 

% DEV
% cornLabels = segim == 2;

% --- 

% shave off the top ~z px (common noise, not useful data) 
cornLabels(1:10,:,:) = 0;

% --- remove reflection line ---
cornLabels = removeReflectionLine(cornLabels);

% find rough center (corneal apex)
[xc, yc, ~] = findEyeCenter(cornLabels);

% get "cornea cap"
% the "cap" is a small section (diameter = 2*corneaCapRadius_mm) of data
% that is nearly guaranteed to be clean cornea data 
corneaCap = getCorneaCap(xc, yc, corneaCapRadius_mm, cornLabels);
% pbin3(corneaCap)

% get the average thickness of the cornea from the cap
% AND fill it to make it non-sparse (helps against low-int scans)
[corneaCapDense, corneaThickness]= getCorneaThickness(corneaCap);

% fit poly22 to the corneaCap and extract corneal epithelium pts
corn_epi_px = fitCorneaCapSurf(corneaCapDense);
% h1 = pbin3(corneaCapDense);

% shift curve down; maintain uint8 (to keep datasize small)
ccbot = corn_epi_px + uint8(round(corneaThickness));

    % calculate the lowest endo pt; post-processing iris requires this
    lowestEndoPt = ceil(max(ccbot(:)));

% get cornea mask
clabelMask = getCorneaMask(corn_epi_px,ccbot);

% mask with the original; maintain binary
corn_pts_px = clabelMask .* cornLabels > 0;

% OUTPUT: convert 3d binary of cornea pts to a nx3 listing of xyz_px pts 
% and downsample them to a reasonable number
% 2022-02-15 MJG Added nCorn 
corn_pts_px = bin3toxyzPlusDown(corn_pts_px, nCorn);

% OUTPUT: get xyz of endo pts 
endo_pts_px = getEndoPts(corneaCapDense);


end