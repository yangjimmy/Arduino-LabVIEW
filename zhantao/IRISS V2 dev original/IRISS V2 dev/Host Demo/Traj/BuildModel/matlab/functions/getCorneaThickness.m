function [corneaCapDense, corneaThickness] = getCorneaThickness(corneaCap)
%getCorneaThickness 2021-09-06 MJG 
% updated 2021-09-09 MJG to include some code to ensure the cornea data is
% not sparsely populated (happens in low-intensity scans) 
% from the cornea cap (a 3d pt cloud), get a statistical estimate of the
% thickness of the cornea; obviously the corneal thickness changes as a
% function of x,y (and anatomy, etc.) but we ignore that here; it's just an estimate  

% make a convex hull of each bscan slice
% this will give us a full (non-sparse) epithelium, but completely destroy
% the shape of the endothelium
fullCorneaCap = false(size(corneaCap));
for yy = 1:400
    if nnz(corneaCap(:,:,yy)) > 0
        fullCorneaCap(:,:,yy) = bwconvhull(corneaCap(:,:,yy));
    end
end
% % we slice it both directions... does this matter?
% for xx = 1:400
%     if nnz(corneaCap(:,xx,:)) > 0
%         fullCorneaCap(:,xx,:) = bwconvhull(squeeze(corneaCap(:,xx,:)));
%     end
% end
% pbin3(fullCorneaCap)

% get a 2d matrix of the top-most points --- from the EPITHELIUM
[~, tmostpts] = max(fullCorneaCap, [], 1);
tmostpts = squeeze(tmostpts);
% figure; imagesc(tmostpts);

% now we find the bottom-most points --- in the orig. cornea cap input
[~, bmostpts] = max(flipud(corneaCap), [], 1);
bmostpts = 376 - squeeze(bmostpts); % undo the flip
% figure; imagesc(bmostpts);

% nota
bpts = bmostpts(:);
bpts(bpts <= 0) = [];
bpts(bpts > 160) = [];

% get a statistical metric on the thickness
roughThickness = floor(mean(bpts) + std(bpts));

% now add this to the topmostpts 
% endog = tmostpts + roughThickness; 

corneaCapDense = false(size(corneaCap));
for xx = 1:400
    for yy = 1:400
        val = tmostpts(yy,xx);
        if val > 1
            corneaCapDense(val:val+roughThickness,xx,yy) = true;
        end
    end
end
% pbin3(corneaCapDense)

% --- leave the rest as is for now, since that seemed to be working from
% before... TODO: is it actually still being used??

% calculate the distnace (difference) [px]
diffpts = bmostpts - tmostpts;

% anything thicker than 160 px (4 mm) is definitely NOT cornea, there's some issue
% with that A-scan, so let's both eliminate the artifacts from the above
% operation (pts==376) as well as enforce this <200 px assumption 
% also remove all values of zero and negative numbers
% all these things don't make sense and we can safely remove them 
diffpts = diffpts(:);
diffpts(diffpts <= 0 | diffpts > 160) = [];



% set corneaThickness = average height [px] + 1*std  
corneaThickness = mean(diffpts) + std(diffpts); 

% NOTE: the std() is padding to ensure we really capture most/all of the
% cornea in this thickness measurement; i.e., we're fudging the number a
% little here, to be safe 

% figure; histogram(diffpts)


end

