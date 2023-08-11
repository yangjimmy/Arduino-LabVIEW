% 2021-08-23 MJG 
% > Process the vscan knowing that it's a scan of the ACh. Find Cornea,
% iris, and output metrics/data that will later be used to generate the eye
% model 

% for the ACh scan, we use a trained model to segment the anatomy. 

% Load OCTz and TOI vals from the SRM and TOI files 
[OCTz, TOI] = readScanData(filename_toi, filename_srm);

%tooltip_offset = -3.2; % 2021-09-02 Kevin

% load the trained model
load(model_filename, 'net');


%%

% convert the vscan to the format the model expects (model was trained on actual images)
cscan = uint8(255 * vscan);

% convert 3d matrix to 4d; in prep for the segmentation
cscan = permute(cscan, [1 2 4 3]);

% segment all the slices in the vscan; this is takes a lot of time! 
% disp('Performing segmentation...');
% tic;
segim = semanticseg(cscan, net, 'OutputType', 'uint8', 'MiniBatchSize', 4);
% disp(['Time to segment full vscan: ' num2str(toc) ' s']);


%% post processing

% Cutoff line: all iris below this line; all cornea above it
cutoff = 5; % [mm] 

% dilation use in post-processing 
se = strel('line', 5, 90); % height, deg

% ---

% convert cutoff to [px]
cutoff = round(cutoff/.025);

% get 3d vol labels 
cornLabels = segim == 2;
irisLabels = segim == 3;

% remove any labels above/below the cutoff
% this is a pretty hard assumption...
cornLabels(cutoff:end,:,:) = 0;
irisLabels(1:cutoff,:,:) = 0;

% tic
for yy = 1:size_xyz(2)
    
    % get slice of orig vscan; depth of 200 px 
    cornSlice = vscan(1:cutoff,:,yy);
%     figure(1); clf; imshow(imslice);
    
    % find large gradients in image
    [~, Gy] = imgradientxy(cornSlice);
%     figure(2); clf; imagesc(Gy); 
    
    % convert to binary
    bw = Gy > 0.5;
%     figure(3); clf; imshow(bw);
    
    % retain two largest blobs
    largeBlobs = bwareafilt(bw, 2);
%     figure(4); clf; imshow(largeBlobs); 

    % vertically dilate the blobs
    dockingMask = imdilate(largeBlobs, se);
%     figure(5); clf; imshow(dockingMask);
    
    % shift the mask down by a few pixels
    shiftAmount = 3;
    dmaskShifted = zeros(size(dockingMask));
    dmaskShifted(shiftAmount:end,:) = dockingMask(1:end-shiftAmount+1,:);
    
    % get cornea labels
    clabel = cornLabels(1:cutoff,:,yy);
%     figure(6); clf; imshow(clabel);

    % apply dockingMask to the cornea label and ensure it remains binary
    cmasked = (clabel - dmaskShifted) > 0;
%     figure(7); clf; imshow(cmasked);

    % retain only the largest blob
    cornBlob = bwareafilt(cmasked, 1);
%     figure(8); clf; imshow(cornBlob); 

    % fill holes 
    cornea = imfill(cornBlob, 'holes');
%     figure(9); clf; imshow(cornea);
    
    % update the cornea labels
    cornLabels(1:cutoff,:,yy) = cornea;
    
    % get iris segim slice
    irisSlice = irisLabels(cutoff:end,:,yy);
%     figure(10); clf; imshow(irisSlice);
    
    % remove all blobs NOT touching a side 
    irisSides = irisSlice - imclearborder(irisSlice);
%     figure(11); clf; imshow(irisSides);

    % fill holes 
    iris = imfill(irisSides, 'holes');
%     figure(12); clf; imshow(iris);
    
    % update the iris labels
    irisLabels(cutoff:end, :, yy) = iris; 
    
    
end

% disp(['Time to post-process vscan: ' num2str(toc) ' s']);

% for ii = 1:400
%     slice = irisLabels(:,:,ii);
%     figure(3); clf; imagesc(slice); pause(0.00001);
% end






%% 

% now, we want to clean up the cornea and iris points so that the later surface fit
% is improved. An easy way to do this is to use basic binary operations
% (and strong assumptions!) on the 3d inference labels 

% convert to 3d binaries
% corn_init3d = segim==2;
% iris_initd3 = segim==3;

% tic 

% maintain previous notation.. 
corn_init3d = cornLabels;
iris_initd3 = irisLabels;

% find largest 3d blob and extract [cornea]
props = regionprops3(corn_init3d, 'Volume');
sortedVolumes = sort([props.Volume], 'descend');
corn3d_px = bwareaopen(corn_init3d, sortedVolumes(1));

% find largest 3d blob and extract [iris]
% Note: issue if the iris is divided/separated from itself in the 3D 
props = regionprops3(iris_initd3, 'Volume');
sortedVolumes = sort([props.Volume], 'descend');
iris3d_px = bwareaopen(iris_initd3, sortedVolumes(1));

% get px idx's of labels 
[corn_zz, corn_xx, corn_yy] = ind2sub(vscan_zxy, find(corn3d_px));
[iris_zz, iris_xx, iris_yy] = ind2sub(vscan_zxy, find(iris3d_px));

% change the nota and scale
corn_xyz_mm = ratio_mm * [corn_xx corn_yy corn_zz];
iris_xyz_mm = ratio_mm * [iris_xx iris_yy iris_zz];


% scale the points in Z by the refractive index... 
corn_xyz_mm(:,3) = refIndex * corn_xyz_mm(:,3);
iris_xyz_mm(:,3) = refIndex * iris_xyz_mm(:,3);

% disp(['Time to clean-up and scale labels: ' num2str(toc) ' s']);


%% find corneal endothelium

% for the cornea, we're interested in the inside surface (endothelium)
% specifically, we want the xyz [px] coordinates of these points 

% tic

% flipup the 3d vol; cumsum these and find where it's one
% these are the endothelium pts, with some artifacts of this operation
origb = cumsum(flipud(corn3d_px))==1;

% there's sometimes large cols of 1's
% so shift the data down one plane then subtract it from the first to leave
% only the points on the edge 
% add a single layer (ZY) to the top of the vol... 
fattyb = cat(1, zeros(1,400,400), origb);
% then remove the bottom plane, which we don't care about (to get the dim
% correct) 
mask = fattyb(1:376, :, :);
% then subtract them and only take the pixels == 1
% these will be used for plotting
endo_cleaned = (origb - mask) == 1;

% okay, so this is a little weird, but the idea is to remove all the pixels
% from endo_cleaned that are outsie of some XY circle. ...
% make XY slice of zeros
M = zeros(400,400);
% add its center as 1
M(200,200) = 1;
% calc pixel dist to that center point
R = bwdist(M);
% then binarize into a mask based on some desired radius
T = R <= 240;
% repmat it into the full size
b = repmat(T, 1, 1, 376);
% and permute so the dimensions/order is correct
c = permute(b, [3 1 2]);
%then mask it with the original set of points... removing all of them.
% endo_red_px will be used for the endo surface fit
endo_red_px = endo_cleaned .* c;

% now convert to XYZ pts for notation
endo_ind_org = find(endo_cleaned); % all pts
endo_ind_red = find(endo_red_px); % pts just for surface fit

% want them in pixel coordinates
[zzorg, xxorg, yyorg] = ind2sub(vscan_zxy, endo_ind_org);
[zzred, xxred, yyred] = ind2sub(vscan_zxy, endo_ind_red);

% change notation so easier to work with 
endo_xyz_org = [xxorg yyorg 376-zzorg];
endo_xyz_red = [xxred yyred 376-zzred];

% scale to [mm]
endo_xyz_org_mm = ratio_mm * endo_xyz_org;
endo_xyz_red_mm = ratio_mm * endo_xyz_red;

% and scale the points in Z by the refractive index... 
endo_xyz_org_mm(:,3) = refIndex * endo_xyz_org_mm(:,3);
endo_xyz_red_mm(:,3) = refIndex * endo_xyz_red_mm(:,3);



% Surface fit the cornEndo pts 
surffit = fit([endo_xyz_red_mm(:,1), endo_xyz_red_mm(:,2)], endo_xyz_red_mm(:,3), 'poly22', 'normalize', 'on');

% disp(['Find and fit corn. endothelium: ' num2str(toc) ' s']);





%% iris model

% i'm doing radially slicing of the vscan here, to ensure the center of the
% slices all pass through the optical center of the eye and that any iris
% that appears is ALWAYS on the left/right (and not in the center). this
% allows us to simplify the assumptions regarding the appearance of the
% iris in the slices for img proc purposes 

% tic 

% load number of slices (constant) and their coordinates;
% this is generated in the playWithIrisPlotting_v#.m file, but only needs
% to be made once, depending on the desired density of pupil-fitting points
load(PATH2SLICES);

% preallocate found pupil xyz points 
pupil_xyz = zeros(desiredSlices*2,3);

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

% convert to [mm]
pupil_mm = ratio_mm * pupil_xyz;

% scale Z by refractive index..
pupil_mm(:,3) = refIndex * pupil_mm(:,3);

% 3D circle fit to pupil points; 3rd party function 
[centerLoc, circleNormal, pupilRadius] = CircFit3D(pupil_mm);

% disp(['Find and fit pupil/iris: ' num2str(toc) ' s']);


%%


% tic

% save the following to a .mat file: data_plotACh.mat 
% ---save data for plotting {OCT} frame; just for plotting
% this has nothing to do with Martin's code 
OCTz_ACh = OCTz; % nota
save([SDIR 'data_plotACh.mat'], ...
    'corn_xyz_mm', 'iris_xyz_mm', 'endo_xyz_org_mm', ...
    'surffit', 'pupil_mm', 'centerLoc', 'circleNormal', 'pupilRadius', ...
    'OCTz_ACh');


% --- adjust notation, etc. to get everything into the format that Matin's
% code expects 
% TODO: A lot of stuff is being saved here that Martin's code might not
% actually be using; maybe can save some computation/saving time here by
% not including them

% > Center_cornea_IRISSframe
% a 3x1 array of doubles; indicates the intersection of the pupil circle
% fit with the optical path line; == center of pupil
% Center_cornea_IRISSframe = TOI * [centerLoc'; 1]; % transform to {I} 
%Center_cornea_IRISSframe = transpose([centerLoc'; 1]'*inv(TOI)'); % transform to {I} 2021-09-08 Mia
Center_cornea_IRISSframe = inv(TOI) * [centerLoc'; 1]; % transform to {I} (2021-09-08 Mia)
Center_cornea_IRISSframe = Center_cornea_IRISSframe(1:3); % strip off xyz


% > IrisEllipseAxis_cornea_IRISSframe
% a 2x2 defined as:
% IrisEllipseAxis_cornea_IRISSframe = [1/Radius_IRISSframe^2 0; 0 1/Radius_IRISSframe^2]
% where Radius_IRISSframe = rn * 0.88*scale_OCT2IRISS;
% and rn is the pupil radius (in {OCT})
% the 0.88 is refIndex scaling and scale_OCT2IRISS is always ~= 1 (so we
% ignore it)
IrisEllipseAxis_cornea_IRISSframe = diag([1 1]) * 1/(refIndex*pupilRadius)^2;

% > PolyCoef_cornea_mm_IRISSframe
% PolyCoef_cornea_mm_IRISSframe = PolyCoef_mm_IRISSframe;
% PolyCoef_mm_IRISSframe = [fit_IRISS.p00 fit_IRISS.p10 fit_IRISS.p01 fit_IRISS.p20 fit_IRISS.p11 fit_IRISS.p02];
% where fit_IRISS are the coefficients of the poly22 surface fit (to the
% cornea), in the {IRISS} frame
% Note: the surface fit will produce different results depending on which
% frame it is done in; so we have to convert the orig pts and redo the fit
% in the {IRISS} frame. 
% transform from {OCT} into {IRISS}
endoXYZ_IRISS = [endo_xyz_red_mm ones(size(endo_xyz_red_mm,1),1)] * inv(TOI)';
% shift tooltip_offset
endoXYZ_IRISS(:,2) = endoXYZ_IRISS(:,2);% + tooltip_offset;
% redo the fit in the {I} frame 
sfIRISS = fit([endoXYZ_IRISS(:,1), endoXYZ_IRISS(:,2)], endoXYZ_IRISS(:,3), 'poly22', 'normalize', 'on');
% now feed it what it wants...
PolyCoef_cornea_mm_IRISSframe = [sfIRISS.p00 sfIRISS.p10 sfIRISS.p01 sfIRISS.p20 sfIRISS.p11 sfIRISS.p02];


% > IrisPlane_cornea_mm_IRISSframe = IrisPlane_IRISSframe;
% this one is easy: it's a 4x1 where the first 3 elems are [0 0 1]' and the
% fourth element is the "iris_depth"; CW used the average of all the iris
% fitting points, but we can do much better and use the actual found
% center as a measure of "iris depth"; this value was already calculated,
% above as Center_cornea_IRISSframe(3), so:
IrisPlane_cornea_mm_IRISSframe = [0 0 1 Center_cornea_IRISSframe(3)]';

% > XYZ_mm_IRISSframe_cornea 
% calculated as: 
% XYZ_mm_IRISSframe_cornea = XYZ_mm_IRISSframe_backup;
% XYZ_mm_IRISSframe_backup = temp4(:,1:3);
% temp4 = [XYZ_mm_backup ones(size(XYZ_mm_backup,1),1)] * inv(TOI)';
% where XYZ_mm_backup are the iris pts in [mm] in {OCT}
% so let's convert our iris_xyz_mm pts to the IRISS frame...
% but first reduce the number of points...
desiredNumPoints = 5000;
dn = round(size(iris_xyz_mm,1)/desiredNumPoints);
iris_xyz_mm = downsample(iris_xyz_mm,dn);
tempIrisPts = [iris_xyz_mm ones(size(iris_xyz_mm,1),1)] * inv(TOI)';
XYZ_mm_IRISSframe_cornea = tempIrisPts(:,1:3);

% > FX_IRISS, etc.
% these are the triangulation mesh points for the endo surface fit 
% first calculate x and y range in {IRISS} frame...
[FX_IRISS, FY_IRISS] = meshgrid(min(endoXYZ_IRISS(:,1)):.1:max(endoXYZ_IRISS(:,1)), min(endoXYZ_IRISS(:,2)):.1:max(endoXYZ_IRISS(:,2)));
% reshape into what Martin's code expects
FX_IRISS = reshape(FX_IRISS,[size(FX_IRISS,1)*size(FX_IRISS,2) 1]);
FY_IRISS = reshape(FY_IRISS,[size(FY_IRISS,1)*size(FY_IRISS,2) 1]);
% then eval surf fit at each value of x and y 
FZ_IRISS = feval(sfIRISS, [FX_IRISS, FY_IRISS]);

% > the last vars are very easy, they are: 
Thickness_cornea_mm = 1.5;
TIO_cornea = inv(TOI);
OCTprobeZ_cornea = OCTz;
SurfacePolyOrd = 2;

% now can save as the .mat file that Martin's code expects... 
% create unique filename 
timestamp = datestr(now,'YYYY-mm-DD_HHMMSSFFF');
% save this model data as a unique filename 
save([MDIR 'EyeModel_cornea_' timestamp '.mat'], ...
    'OCTprobeZ_cornea', ... % 
    'TIO_cornea', ... % 
    'Center_cornea_IRISSframe', ... % 
    'IrisEllipseAxis_cornea_IRISSframe', ... %
    'PolyCoef_cornea_mm_IRISSframe', ... %
    'SurfacePolyOrd', ... % 
    'IrisPlane_cornea_mm_IRISSframe', ... %
    'Thickness_cornea_mm', ... %
    'XYZ_mm_IRISSframe_cornea', ... %
    'FX_IRISS', 'FY_IRISS', 'FZ_IRISS');

% then make a copy of this file and save the copy as 'EyeModel_cornea.mat',
% overwriting any previous model that's in the directory...
copyfile([MDIR 'EyeModel_cornea_' timestamp '.mat'], [MDIR 'EyeModel_cornea.mat']);

% disp(['Save ACh data and model params: ' num2str(toc) ' s']);

