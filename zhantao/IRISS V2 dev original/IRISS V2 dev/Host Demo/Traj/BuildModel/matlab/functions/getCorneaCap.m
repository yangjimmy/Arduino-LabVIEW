function corneaCap = getCorneaCap(xc, yc, corneaCapRadius_mm, cornLabels)
%getCorneaCap 2021-09-06 MJG 
% this reduces the not-so-clean cornea Labels to just the topmost "cap"---a
% 3d pt cloud of data that's guaranteed to be the cornea, near the top and
% center of the scan

% Build a 3d mask to retain only "good" data near the top/center 
% make XY slice of zeros
maskFlat = zeros(400,400);
% add its center as 1
maskFlat(xc,yc) = 1;
% calc pixel dist to that center point
% then binarize into a mask based on some desired radius
% convert  to [px]
maskFlat = bwdist(maskFlat) < floor(corneaCapRadius_mm/0.025);
% this is just a bw 2d circle 
% repmat it into the full size
% and permute so the dimensions/order is correct
mask3d = permute(repmat(maskFlat, 1, 1, 376), [3 1 2]);
% pbin3(mask3d)

% % now use the mask to get candidate pts for cornea_top; ensure binary 
maskedLabels = mask3d .* cornLabels > 0;





% extract just the largest 3d blob, which is assumed to be the cornea
% if there's a ton of stuff in the center of the scan, near the bottom, and
% for some reason the model thinks it's corean (and not iris/AC/lens), then
% this will fail... but so far it seems like a reasonable assumption 
props = regionprops3(maskedLabels, 'Volume');
sortedVolumes = sort([props.Volume], 'descend');
corneaCap = bwareaopen(maskedLabels, sortedVolumes(1));
% pbin3(corneaCap)

end

