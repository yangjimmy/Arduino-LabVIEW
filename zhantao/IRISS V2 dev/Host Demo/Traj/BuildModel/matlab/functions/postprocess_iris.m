function [iris_pts_px, pupil_pts_px] = postprocess_iris(irisLabels, lowestEndoPt, SDIR, nIris)
%postprocess_iris 2021-09-07 MJG
%   This code processes the iris data in ACh scan to find the iris xyz [px]
%   {O} pts for the purpose of plotting + the pupil pts to use in pupil
%   fitting; it must be run AFTER postprocess_corn

% add trailing slash if not specified 
if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end 

% build path to the slice file
PATH2SLICES = [SDIR 'sliceCoords.mat'];

% DEV
% irisLabels = segim == 3;

% remove top slab 
irisLabels(1:lowestEndoPt, :, :) = 0;

% compress in Z... 
topIrisView = ~squeeze(sum(irisLabels,1)) > 0;

% retain largest blob 
pupilBlob = bwareafilt(topIrisView, 1);

% find the maximum inscribed circle within this blob
% 2021-09-24 MJG; updated with v2, cleaner and faster code 
[cx, cy, r] = max_inscribed_circle_v2(pupilBlob);

% reduce the radius a bit and then create a positive mask with the found circle 
bmask = zeros(400);
bmask(cx,cy) = 1;
bmask = bwdist(bmask) < (r - 1/0.025);

% add the positive mask to the orig data; ensure binary
pupilBlobCircled = (pupilBlob + bmask) > 0;

% fill the holes; 
% this works great unless the docking is really covering the iris
% invert it here (slightly faster)
holesFilled = ~imfill(pupilBlobCircled, 'holes');

% repmat and permute it into 3D (extrude the 2D shape); and invert
pupilMask = permute(repmat(holesFilled, 1, 1, 376), [3 1 2]);
% pbin3(pupilMask)

% % now use the mask to get candidate pts for cornea_top; ensure binary 
finalIrisLabels = pupilMask .* irisLabels > 0;
% pbin3(finalIrisLabels)

% OUTPUT: convert 3d binary of iris pts to a nIrisx3 listing of xyz_px pts 
% and downsample to a reasonable amount... 
iris_pts_px = bin3toxyzPlusDown(finalIrisLabels, nIris);

% OUTPUT: pupil pts 
pupil_pts_px = getPupilPerimeter(finalIrisLabels, PATH2SLICES);



end