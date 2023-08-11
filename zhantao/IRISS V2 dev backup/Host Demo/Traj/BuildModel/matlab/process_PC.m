% 2021-08-20 MJG 
% With the vscan, known to be PC, find PC and fit a surface to it

% the depth to look for the PC, in [mm]
% all data beneath this depth will be ignored! 
depth_to_look = 4; % [mm]
tooltip_offset = -3.2; % 2021-09-02 Kevin

% --- 

% Load OCTz and TOI vals from the SRM and TOI files 
[OCTz, TOI] = readScanData(filename_toi, filename_srm);

% convert depth to [px]
depth2look_px = round(depth_to_look/ratio_mm);

% truncate vscan (remove bottom and top)
vscan = vscan(1:depth2look_px, :, :);

% blur the whole thing... 
vscan = imgaussfilt3(vscan,1);

% % average each slice with its neighbors 
% FIXME: is this really the fastest way? 
bwvol = zeros(size(vscan));
for yy = 2:399
    bwvol(:,:,yy) = (vscan(:,:,yy-1) .* vscan(:,:,yy) .* vscan(:,:,yy+1));
end

% binary threshold, based on some stats... 
thresh = mean(bwvol(:)) + 2*std(bwvol(:));
% convert to binary 
bwvol = bwvol > thresh;

% --- remove reflection line... 

% sum number of 1s in each Ascan (col)
s = squeeze(sum(bwvol));

% find xy position of largest---
% We assume there is ALWAYS a reflection and will remove it! 
[xm, ym] = find(ismember(s, max(s(:)))); 

% now create a 2d mask to mask out that reflection...
% preallo a mask
reflectionMask = zeros(size(s));
% set the reflection line XY center as 1
reflectionMask(xm,ym) = 1;
% get dist to that point and convert to binary mask based on distance
% px amt  chosen as it should be sufficient to remove all reflection lines
reflectionMask = bwdist(reflectionMask) < 10;
% now repmat it into the full size
reflectionMask = repmat(reflectionMask, 1, 1, depth2look_px);
% permute so the dimensions/order is correct
reflectionMask = permute(reflectionMask, [3 1 2]);
%then mask it with the original set of points; thereby masking out the
%reflection line (assuming it exists)... 
bwvol = bwvol .* ~reflectionMask;
% note: this will essentially punch a hole through the data of radius
% chosen above, even if there ISN'T a reflection line
% we assume this is okay because, assuming enough data, remove some isn't a
% big deal since enough of "good" points will remain to form a good fit...

% --- these are ALL our xyz pts of the PC data, which could be lens, PC, 
% etc... for now, convert to xyz so we can plot this if needed 
[zz, xx, yy] = ind2sub(size(bwvol), find(bwvol));
pc_xyz_full_px = [xx yy zz];
% convert to [mm]
pc_xyz_full_mm = ratio_mm * pc_xyz_full_px;
% scale Z by refractive index 
pc_xyz_full_mm(:,3) = refIndex * pc_xyz_full_mm(:,3);
% % shift the points down by OCTzRelDist 
% pc_xyz_full_mm(:,3) = pc_xyz_full_mm(:,3) + OCTzRelDist;
% NOTE: NOT DOING THIS HERE. Martin's code and the plotting code will have
% to do it... 

% --- but we're only interested in the PC itself... not all the lens
% material, etc. at the bottom; so let's find that. 
% flipud the 3d vol; cumsum these and find where it's 1
origb = cumsum(flipud(bwvol))==1;

% unfortunately, this will cause a lot of artifacts; eg, see:
% [zz, xx, yy] = ind2sub(size(origb), find(origb));
% figure; clf; plot3(xx, yy, zz, 'r.');
% to remove the columns of 1's, shift the data down one then subtract it
% from the first to leave only edge pts. 
% add a single layer of zeros (ZY) to the top of the vol... 
fattyb = cat(1, zeros(1,400,400), origb);
% remove the bot plane to get the dim correct
mask = fattyb(1:depth2look_px, :, :);
% then subtract and take the pixels == 1 
bwvol_PC = (origb - mask) == 1;
% and then flip it back
bwvol_PC = flipud(bwvol_PC);

% now convert these pixels to PC xyz [px]{O} points 
[zz, xx, yy] = ind2sub(size(bwvol_PC), find(bwvol_PC));
pc_xyz = [xx yy zz];

% scale to [mm]
pc_mm = ratio_mm * pc_xyz; 

% scale Z by refractive index 
pc_mm(:,3) = refIndex * pc_mm(:,3);

% % shift the points down by OCTzRelDist (the dist OCTz moved down b/t ACh
% % and PC scans
% pc_mm(:,3) = pc_mm(:,3) + OCTzRelDist;
% NOTE: not doing this here, handle it in the plotting code and in Martin's
% code... 

% Surface fit the PC points... {OCT} frame [mm]
surfPC_OCT = fit([pc_mm(:,1), pc_mm(:,2)], pc_mm(:,3), 'poly22', 'normalize', 'on');


% save the following to a .mat file: data_plotPC.mat  for plotModel.m to
% use
% ---save data for plotting {OCT} frame; just for plotting---ind of
% Martin's model params
OCTz_PC = OCTz; % nota
save([SDIR '\data_plotPC.mat'], ...
    'pc_xyz_full_mm', 'pc_mm', 'OCTz_PC');



% --- save vals and params for Martin's traj gen 


% --- convert orig vars to vars that Martin's code expects 

% -- first we convert the {O} [mm] pts to {I} [mm] pts
% then we fit a surface to the PC {I} and extract whatever information that
% Matin's code will require.

% convert PC {O}[mm] pts to {I}[mm]
%pc_mm(:,3) = pc_mm(:,3) + OCTz; % 2021-09-08 Mia 
tempPCpts = [pc_mm ones(size(pc_mm,1),1)] * inv(TOI)';
% tempPCpts(:,3) = tempPCpts(:,3) + OCTz; % 2021-09-02 Kevin
% tempPCpts(:,2) = tempPCpts(:,2) + tooltip_offset; % 2021-09-02 Kevin
PCpts_IRISS = tempPCpts(:,1:3);

% > XYZ_mm_IRISSframe_capsule
% the nx3 xyz pts {IRISS} [mm] used in the PC fitting..
% for Martin's code... 
XYZ_mm_IRISSframe_capsule = PCpts_IRISS;

% then fit surface to these points... {IRISS} frame [mm]
surfPC_IRISS = fit([PCpts_IRISS(:,1), PCpts_IRISS(:,2)], PCpts_IRISS(:,3), 'poly22', 'normalize', 'on');

% only want to fit across the actual data---not all the way out to the
% sides; so truncate the range:
padding = 1; % [mm] 
xlims = [min(PCpts_IRISS(:,1))-padding max(PCpts_IRISS(:,1))+padding];
ylims = [min(PCpts_IRISS(:,2))-padding max(PCpts_IRISS(:,2))+padding];

% get xy range
nn = 100;
xrange = linspace(xlims(1), xlims(2), nn)';
yrange = linspace(ylims(1), ylims(2), nn)';

% then get numbers 
xi = repmat(xrange, nn, 1);
yi = repelem(yrange, nn);

% eval surf model at each value of xi and yi 
zi = surfPC_IRISS(xi,yi);

% get idx of deepest part of the PC fit 
[~, idx] = max(zi);

% > Center_post_IRISSframe
% this is a 3x1 in {IRISS} of the center of the PC in [mm]_IRISS 
% needed for Martin's code 
Center_post_IRISSframe = [xi(idx); yi(idx); zi(idx)];

% > PolyCoef_post_mm_IRISSframe 
%    PolyCoef_post_mm_IRISSframe = PolyCoef_mm_IRISSframe;
% a 1x6 of the poly22 surface fit coeff of the PC, in the {IRISS} frame!
PolyCoef_post_mm_IRISSframe = [surfPC_IRISS.p00 surfPC_IRISS.p10 surfPC_IRISS.p01 surfPC_IRISS.p20 surfPC_IRISS.p11 surfPC_IRISS.p02];

% > 'FX_IRISS', 'FY_IRISS','FZ_IRISS');
% the triangulation mesh points used in the PC surface fit... 
% for Martin's code... 
FX_IRISS = xi;
FY_IRISS = yi;
FZ_IRISS = zi;



% --- other params that Martin's code wants: 

% > 'OCTprobeZ_post'
% the value of OCTz [mm] when the scan was taken
OCTprobeZ_post = OCTz;
    
% > TIO_post
% inverted TOI; easy to calc:
TIO_post = inv(TOI);

% MIA 2021-09-03: probably wrong -> get this from the Ach(cornea).mat
% > IrisEllipseAxis_post_IRISSframe
% a 2x2 in IRISS frame
% it's the same as the one saved for the ACh... TODO: is this being used?
IrisEllipseAxis_post_IRISSframe = eye(2);

% MIA 2021-09-03: probably wrong -> get from ACh(cornea).mat file
% > Center_front_IRISSframe
% just a constant 3x1 of zeros...
Center_front_IRISSframe = zeros(3,1); 

% MIA 2021-09-03: probably wrong -> get from ACh(cornea).mat file
% > Radius_front_IRISSframe
% just a constant 2x2 of zeros...
Radius_front_IRISSframe = zeros(2);

% MIA 2021-09-03: probably wrong -> get from ACh(cornea).mat file
% > PolyCoef_front_mm_IRISSframe
% just a constant 1x6 of zeros...
PolyCoef_front_mm_IRISSframe = zeros(1,6);

% > SurfacePolyOrd
% a constant 2
SurfacePolyOrd = 2;

% MIA 2021-09-03: probably wrong -> get from ACh(cornea).mat file
% > IrisPlane_post_mm_IRISSframe
% a 4x1 that is the same as the one in the ACh file... is this needed?
IrisPlane_post_mm_IRISSframe = zeros(4,1); 

% --- save the data for Martin's code 
% now can save as the .mat file that Martin's code expects... 
% create unique filename 
timestamp = datestr(now,'YYYY-mm-DD_HHMMSSFFF');
% save this model data as a unique filename 
save([MDIR 'EyeModel_capsule_' timestamp '.mat'], ...
    'OCTprobeZ_post', ... 
    'TIO_post',...
    'Center_post_IRISSframe', ... 
    'IrisEllipseAxis_post_IRISSframe', ... 
    'PolyCoef_post_mm_IRISSframe', ... 
    'Center_front_IRISSframe', ... 
    'Radius_front_IRISSframe', ... 
    'PolyCoef_front_mm_IRISSframe', ... 
    'SurfacePolyOrd', ... 
    'IrisPlane_post_mm_IRISSframe', ... 
    'XYZ_mm_IRISSframe_capsule', ... 
    'FX_IRISS', 'FY_IRISS','FZ_IRISS',...
    'pc_mm'); % 2021-09-08 Mia

% then make a copy of this file and save the copy as 'EyeModel_capsule.mat',
% overwriting any previous model that's in the directory...
copyfile([MDIR 'EyeModel_capsule_' timestamp '.mat'], [MDIR 'EyeModel_capsule.mat']);


