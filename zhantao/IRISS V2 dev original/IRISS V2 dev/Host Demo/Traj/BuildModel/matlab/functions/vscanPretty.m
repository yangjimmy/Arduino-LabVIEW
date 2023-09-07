function vscan = vscanPretty(vscan)
%vscanPretty 2021-09-07 MJG 
% take a vscan, scale/normalize the intensities and then resize

% constant saturation limits
    minint = 20;
    maxint = 70;

    % saturate intensity across the whole VSCAN
    vscan(vscan<minint) = minint;
    vscan(vscan>maxint) = maxint;

    % before we scale the vscan to [0,1], we must ensure the bounds will remain
    % the same, so we force two of the pixels to be 0 and 1 so that the min/max
    % limits actually exist. I choose two pixels on the bottom of the first 
    % BSCAN for this, since we know those will be out of the way and unimportant
    vscan(end,1,end) = minint;
    vscan(end,2,end) = maxint;

    % norm [0,1] (convert to grayscale), MJG custom function (req. mjglib)
    vscan = unorm(vscan);

    % I made a decision here that's open to debate
    % In the interest of speed---but at the sacrifice of accuracy---the VSCAN
    % is resized down to 1:1 pixel ratio NOW. This makes the image size smaller
    % (and the model inference faster), but at the loss of image information
    % (lost during the resizing).
    % the new size is (note the ZXY order)
    vscan_zxy = [376 400 400];
    % then the resize is performed: 
    vscan = imresize3(vscan, vscan_zxy);


end

