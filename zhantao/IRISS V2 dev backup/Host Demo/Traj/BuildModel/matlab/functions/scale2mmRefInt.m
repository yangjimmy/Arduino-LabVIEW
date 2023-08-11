function xyz_mm = scale2mmRefInt(pts2scale, refIndex, ratio_mm, corn_epi_px)
% scale2mmRefInt 2021-09-23 MJG 
% uses knowledge of the corneal epithelium location to properly scale xyz
% pts inside the eye with the experimentally determined refIndex 
% SEE:
% http://matthewjgerber.com/papers/paper_2018iriss.pdf; Equation 2
% INPUTS: 
% > pts2scale; n x 3 of xyz pts [px] {OCT} where n is >> 3 
% > refIndex = 0.74 = value "n" from the above cited paper 
% > ratio_mm = 0.025; always
% > corn_epi_px; a 400x400 matrix of z coords (output of corn proc step)

% convert all for later (-) operation with a double
corn_epi_px = double(corn_epi_px); 

% need to round since we're transforming them to indices
% NOTE: sub-pixel loss of accuracy here. 
pts2scale = round(pts2scale);

% convert the xyz points to a binary volume
ptvol = false(376, 400, 400); 
idx = sub2ind(size(ptvol), pts2scale(:,3), pts2scale(:,1), pts2scale(:,2));
ptvol(idx) = true;

% sum in z; purpose is to determine if more than one z value in all the
% ascans (some nx3 matrices of pts only have a single z value in each ascan; 
% if that's the case, it can be processed slightly faster
cs = squeeze(sum(ptvol));

if nnz(cs>1) > 0 
% then multiple vals of z in each ascan, do it the long/slow way by looking
% at each ascan and processing all the z vals in that ascan
    
    % loop through each ascan and scale the z vals 
    ii = 1;
    scaledxyz = zeros(size(pts2scale));
    for xx = 1:400
        for yy = 1:400
            % the ascan col, with binary pts 
            ascan = ptvol(:,xx,yy); 
            % number of pts in this ascan
            L = nnz(ascan);
            % break loop if nothing in this ascan 
            if L == 0; continue; end 
            % get epi depth [px]
            ze = corn_epi_px(yy,xx);
            % scale this ascan in z 
            z_scaled = ze + refIndex * (find(ascan) - ze);
            % update 
            scaledxyz(ii:ii+L-1,:) = [ones(L,1)*xx ones(L,1)*yy z_scaled];
            % inc counter 
            ii = ii + 1;
        end
    end

else 
% only a single z value in each ascan, can speed up code by a few
% simplifying assumptions of the above 

    % loop through each ascan and scale the z vals 
    ii = 1;
    scaledxyz = zeros(size(pts2scale));
    for xx = 1:400
        for yy = 1:400
            % get z value in ascan [px]
            z = find(ptvol(:,xx,yy));
            % break loop if nothing 
            if isempty(z); continue; end
            % get epi depth [px]
            ze = corn_epi_px(yy,xx);
            % scale this ascan in z 
            z_scaled = ze + refIndex * (z - ze);
            % update 
            scaledxyz(ii,:) = [xx yy z_scaled];
            % inc counter 
            ii = ii + 1;
        end
    end

    
    
end
    

% --- convert x,y,z to [mm]
% this is as easy as a single multiplication because, by definition, we've
% previously resized the pixels to be 1:1:1 square cubes
% (see notes in vscan2nice.m function file)
xyz_mm = ratio_mm * scaledxyz;



