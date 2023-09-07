function vscan = removeRefLinePC(vscan, maskDepth)
%removeRefLinePC 2021-09-09 MJG 
% Attempt to detect and remove a single reflection line from the PC vscan

% sum everything in Z direction;
% Note: we blur it a little to work out some noise; we're only interested
% in an approximate location of the peak intensity
cs = imgaussfilt(squeeze(sum(vscan)), 0.8);
% figure(2); clf; imagesc(cs); hold on;

% we assume there will only be one reflection point/line
% so get the max intensity in the image... 
allints = cs(:);
maxint = max(allints);

% if that max is "large" (some statistical defn), the we assume it's a
% reflection line... 
% TODO: better to use established method, eg, isoutlier with IQR 
if maxint > mean(allints(allints>20)) + 5*std(allints(allints>20))
    % get x,y coord
    [idxi, idxj] = ind2sub(size(cs), find(cs==maxint));
    % DEV: check 
%     figure(2); plot(idxj, idxi, 'ko');

    % make 3d mask
    refLineMask = zeros(400);
    refLineMask(idxi, idxj) = 1;
    refLineMask = bwdist(refLineMask) > 20; % ensure it'll mask everything
%         figure; imshow(refLineMask)
    refLineMask3d = permute(repmat(refLineMask, 1, 1, floor(maskDepth/0.025)), [3 1 2]);

    % apply mask
    vscan = refLineMask3d .* vscan;
end


end

