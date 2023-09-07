function vscan = scalevscan(vscan)
%SCALEVSCAN 2021-13-31 MJG 
%   Scale and normalize the intensity of a vscan by usual ranges 

    % constant saturation limits
    minint = 20;
    maxint = 70;

    % saturate intensity across the entire vscan 
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

end