function scanType = determineAChPC(vscan)
%determineAChPC 2021-09-09 MJG 
% Not a robust way of doing this, but should work for now; this code
% attempts to determine if a vscan is of the ACh or the PC based on the
% intensity of the middle slices near the top 
% the assumption is that the cornea+docking is very bright compared to the
% PC 

    % average together 3 nearest neighbors... and blur each... 
    ascan = imgaussfilt(vscan(1:120,:,199)) + imgaussfilt(vscan(1:120,:,200)) + imgaussfilt(vscan(1:120,:,201));
    % for an intensity metric, the number of pixels with int > 1 
    intMetric = sum(ascan(:) > 1);
    % from previous results, intMetric > 3000 is ACh 

    if intMetric > 3000
        scanType = 1;
    else
        scanType = 0;
    end
    
end

