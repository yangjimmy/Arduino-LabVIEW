function output = removeReflectionLine(input)
%removeReflectionLine Determines if OCT reflection is present at the cornea
%apex, and---if so---does a brute-force removal of it
% 2021-08-31 MJG 

% sum in z
zsum = squeeze(sum(input));
% figure(1); clf; imagesc(zsum); hold on;

% by definition, the reflection line should resonate through the entire
% depth of the scan, so assume any line with num of elements > some amount 
% is a reflection line and not actual data; okay to be aggressive here; we
% really want to ensure we remove it all. 
refLineCands = zsum > 100;
% figure(2); clf; imshow(refLineCands); hold on; 

% if ref line detected, then there's at least one A-scan that's a
% reflection line, so let's work on removing it from the 3d vol scan
if sum(refLineCands(:)) > 0

    % dilate the refline candidates; okay to be aggressive here with the
    % diamater of the disk strel 
    se = strel('disk', 6, 4);
    dilatedref = imdilate(refLineCands, se);
%     figure(2); clf; imshow(dilatedref); hold on;
    
%     % just for plotting 
%     B = bwboundaries(dilatedref);
%     for k = 1:length(B)
%         boundary = B{k};
%         figure(1); plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 1);
%     end
    
    % extend the 2d mask into 3d space 
    % repmat it into the full size
    % and permute so the dimensions/order is correct
    refmask3d = permute(repmat(dilatedref, 1, 1, 376), [3 1 2]);

    % now use the mask to mask out reflection lines in the input; ensure binary 
    output = ~refmask3d .* input > 0;
%     pbin3(output)
    
    
else
    % no change necessary 
    output = input; 
    
end % if reflection line exists



end % fx 