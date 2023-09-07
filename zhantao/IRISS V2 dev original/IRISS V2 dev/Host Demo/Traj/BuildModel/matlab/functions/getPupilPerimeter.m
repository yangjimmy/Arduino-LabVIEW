function pupil_xyz = getPupilPerimeter(iris3d_px, PATH2SLICES)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


% load number of slices (constant) and their coordinates;
% this is generated in the playWithIrisPlotting_v#.m file, but only needs
% to be made once, depending on the desired density of pupil-fitting points
load(PATH2SLICES, 'sliceCoords', 'desiredSlices');

% preallocate found pupil xyz points 
pupil_xyz = zeros(desiredSlices*2, 3);

% loop through each radial slice
% tic
for ii = 1:desiredSlices 

    % notation
    xy = sliceCoords(ii*400-399:ii*400,:);
    
    % generate slice from A-scan pts 
    slice = zeros(376,400);
    for jj = 1:400
        slice(:,jj) = iris3d_px(:, xy(jj,1), xy(jj,2));
    end

    % compress; this is which cols have data
    cols = sum(slice) > 0;
    % split into left/right halves:
    lcols = flip(cols(1:200));
    rcols = cols(201:400);
    
    % check if iris is actually present; if not set to NaN for later
    % removal
    if nnz(lcols) > 0
        % search for true px 
        [~, idxl] = max(lcols, [], 2);
        % unflip and adjust 
        idxl = 200-idxl+1;
        % now find z for each...; we find its vertical idx then mean whatever
        % we find (maybe not a good anatomical assumption)... since it finds
        % the middle of the iris, but fine for now until we can re-consider 
        pzl = mean(find(slice(:,idxl)));
        % get the actual X and Y values (global)---not the local slice coords!
        pxl = xy(idxl, 1);
        pyl = xy(idxl, 2);
    else
        pxl = NaN;
        pyl = NaN;
        pzl = NaN; 
    end
    if nnz(rcols) > 0
        % search for true px 
        [~, idxr] = max(rcols, [], 2);
        % unflip and adjust 
        idxr = idxr + 200;
        % find z 
        pzr = mean(find(slice(:,idxr)));
        % get the actual X and Y values (global)---not the local slice coords!
        pxr = xy(idxr, 1);
        pyr = xy(idxr, 2);
    else
        pxr = NaN;
        pyr = NaN;
        pzr = NaN;
    end
    
    % add detected pupil edges to data...
    pupil_xyz(ii*2-1:ii*2,:) = [pxl pyl pzl; pxr pyr pzr];
    
end
% toc 

% remove rows of all NaN
pupil_xyz(all(isnan(pupil_xyz),2), :) = [];

% detect and remove outliers  based on z depth/height 
TF = isoutlier(pupil_xyz(:,3), 'quartiles');
pupil_xyz(TF, :) = [];

end

