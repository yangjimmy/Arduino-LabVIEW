function corneaCapFilled = fillCorneaCap(corneaCap)
% fillCorneaCap 2021-09-09 MJG fills up the cornea cap based on the binary
% cross sections. 
% this namely fixes an issue of sparsely populated cornea data in the case
% of lower intensity scans. it shouldn't have much effect on full
% (non-sparse) cornea labels from good, high-intensity scans. 

% get a 2d matrix of the top-most points 
[~, tmostpts] = max(corneaCap, [], 1);
tmostpts = squeeze(tmostpts);
figure; imagesc(tmostpts)

% same for the bottom-most points 
[~, bmostpts] = max(flipud(corneaCap), [], 1);
bmostpts = 376 - squeeze(bmostpts); % undo the flip
figure; imagesc(bmostpts);

% calculate the distnace (difference) [px]
diffpts = bmostpts - tmostpts;
figure; imagesc(diffpts)



corneaCapFilled = false(size(corneaCap));
for yy = 1:400
    % only do something if there's some data to look at 
    if nnz(corneaCap(:,:,yy)) > 0
        corneaCapFilled(:,:,yy) = bwconvhull(corneaCap(:,:,yy));
    end
end

% DEV: look through it 
for yy = 1:2:400
    
   slice = corneaCapFilled(:,:,yy);
   figure(2); clf; imshow(slice); pause(0.0001);
end

