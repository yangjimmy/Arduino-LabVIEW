function [ X, Y, Pinv, IrisCenter, Zc_true, Za_true, Zp_true, Zi_true,...
    za_true, za_work, zp_work, zp_true,...
    x_out, y_out, z_out, L4_out, S, vacf_out, za_eps, zp_eps ] = TrajectorySchedule_rev7...
    ( z_OCT_origin, z_OCT_cornea, z_OCT_post, idx_refract, Ngrid, NnormTraj, L1_Constr,...
    flowerMode, beta, n_flr, ofst, eps, d_Zi2Za, DepthCtrl, rAtten, zc, z_thld, vac_bnd, CycleTime, SCAN_NO_ACh, ...
    scaleRadius, traj_offset_x, traj_offset_y, traj_offset_z)

% TrajectorySchedule_rev7 2021-09-10 Mia
%   This code loads the EyeModel .mat files to generate the
%   trajectory within the eye model in {IRISS}

% clear all; close all; clc;
% % For testing function
% z_OCT_origin = 0;                 % where OCT performs 13-pt algorithm for coord. transformation
% z_OCT_cornea = 0;                 % where OCT takes a snap shot for cornea
% z_OCT_post   = 0;                 % where OCT takes a snap shot for posterior capsule
% idx_refract = 1.35;               % refractive index
% Ngrid = 200;                      % no. of workspace grid points
% NnormTraj = 1000;                 % no. of normTrajetory grid points
% L1_Constr = [-5,30];              % L1 joint constraint in degrees
% flowerMode = 5;                   % mode = 0: pivot at entry; mode = 1: ...
% %centered; mode = 2: insertion; mode = 3: extraction; mode = 4: reverse ...
% %pivot, mode = 5: reverse centered  
% beta = 60;                        % half angle range in deg
% n_flr = 10;                       % no. of lobes
% ofst = 0.2;                       % relative offset parameter in radial direction
% eps  = 0.5;                       % safety bound in radial direction [mm]
% d_Zi2Za = [0.1,0.1,0.1];          % trajectory up offset from Zi plane
% DepthCtrl = [0.2,0.3,0.4];        % depth in terms of thickness for each stage, changes Zi2Zp
% DepthCtrl = [0.4,0.6,0.8]; % Testing
% rAtten = 0.2;                     % attenuate halve close to the entry radially
% zc = 3;                           % axis of aspiration points towards (0,~,zc)
% z_thld = [2,3.5];                 % threshold z distances used to define extreme values of vacuum force
% vac_bnd = [80,100];               % extreme values of vacuum force
% CycleTime = [60,90,120];          % time elasped in seconds for each run;
% scaleRadius = 0.5;                % value between 0 and 1 denoting the scale factor applied to pupil radius to make traj radius
% traj_offset_x = 0;                % x shift in the traj start point from the pupil center
% traj_offset_y = 0;                % y shift in the traj start point from the pupil center
% traj_offset_z = 0;               % z shift in the traj start point from the pupil center
% SCAN_NO_ACh = '0011';
% insertion = 0;                    % Insertion and extraction trajectories: 1 = insertion, 2 = extraction

% Add paths
addpath('D:\Kevin\IRISS V2 dev\Host Demo\Traj');
addpath('D:\Kevin\IRISS V2 dev\Host Demo\Traj\BuildModel\matlab\functions');

% specify where the .mat files were saved (by the processVSCAN function)
SDIR = 'D:\Kevin\IRISS V2 dev\Host Demo\Traj\BuildModel\matlab\allSaves'; % (09-20-21 Mia)

% Add trailing slash to SDIR if it wasn't specified by the user
if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end

if length(DepthCtrl) ~= length(CycleTime)
    error('lengths of depth control and cycle time are not consistent!')
end
NoCycles = length(DepthCtrl);

% Insertion and extraction trajectories (2021-10-07)
if flowerMode == 2 || flowerMode == 3
    NoCycles = 1;
end
startLoc = [0.002; -0.935; -0.353]; % Starting location of the tooltip prior to trajectory

%% Load parameter data
% load the scan numbers used
%load([SDIR 'SCAN_NO_ACh.mat'], 'SCAN_NO_ACh'); % Fix this (09-20-21 Mia)

%SCAN_NO_ACh = str2num(SCAN_NO_ACh);

% load ACh and PC data points for plotting...
load([SDIR 'allParams_' num2str(SCAN_NO_ACh,'%04i') '.mat']); % (09-20-21 Mia)

% Testing 10-13-2021
pcfitpts_mm = [Xdata(:), Ydata(:), Zdata(:)];
pupil_pts_mm = pupilCurvePts'; 

%% Plotting in {OCT}
figure(99); clf;
% --- plot cornea data
hc = scatter3(corn_pts_mm(:,1), corn_pts_mm(:,2), corn_pts_mm(:,3), 1, [0.1 0.2 0.8]);
set(hc, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);

% --- plot params
hold on; grid on; axis equal;
set(gca, 'zdir', 'reverse');
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');

% --- plot endo pts
he = scatter3(endo_pts_mm(:,1), endo_pts_mm(:,2), endo_pts_mm(:,3), 3, [0 0 0]);
set(he, 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0);

% fit surface to endo pts
surffit_endo = fit([endo_pts_mm(:,1), endo_pts_mm(:,2)], endo_pts_mm(:,3), 'poly22');

% --- plot surface fit of endo
rr = (0:0.1:10)'; % range of points
xi_endo = repmat(rr, size(rr,1), 1);
yi_endo = repelem(rr, size(rr,1));
zi_endo = surffit_endo(xi_endo,yi_endo); % eval surf model at each value of xi and yi
T = delaunay(xi_endo,yi_endo);
TO_endo = triangulation(T, xi_endo(:), yi_endo(:), zi_endo(:));
% plot mesh and change color
trimesh(TO_endo, 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.3);
% 
% --- plot iris data
hs = scatter3(iris_pts_mm(:,1), iris_pts_mm(:,2), iris_pts_mm(:,3), 1, [0.8 0.2 0.1]);
set(hs, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);

% plot --- pupil points used in circle fit
hs = scatter3(pupil_pts_mm(:,1), pupil_pts_mm(:,2), pupil_pts_mm(:,3), 10, [0.2 0.2 1]);
set(hs, 'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', 0);

% 3D circle fit to pupil points --- UPDATED 2021-09-13 MJG
% Both the plotting code and Martin's code needs this, so we do it here
% and save the results
[centerLoc, circleNormal, pupilRadius, fitPoints] = fit3Dcircle(pupil_pts_mm);

% % plot center location and pupil direction
emm = 4;
plot3(centerLoc(1), centerLoc(2), centerLoc(3), 'g+');
plot3([centerLoc(1) centerLoc(1)+emm*circleNormal(1)], ...
    [centerLoc(2) centerLoc(2)+emm*circleNormal(2)], ...
    [centerLoc(3) centerLoc(3)+emm*circleNormal(3)], 'r-', 'LineWidth', 1);
plot3([centerLoc(1) centerLoc(1)-emm*circleNormal(1)], ...
    [centerLoc(2) centerLoc(2)-emm*circleNormal(2)], ...
    [centerLoc(3) centerLoc(3)-emm*circleNormal(3)], 'r-', 'LineWidth', 1);

% plot fit points -- UPDATED 2021-09-13 MJG
plot3(fitPoints(:,1), fitPoints(:,2), fitPoints(:,3), 'k-', 'LineWidth', 2);
xlim([0 10]); ylim([0 10]);


%% Coordinate transformation for plotting Matt's model in {IRISS}
TIO_AC = inv(TOI_ACh);

% 1. Convert cornea to {IRISS}
for ii = 1:size(corn_pts_mm,1) % Loop through all the coordinates
    coord = [corn_pts_mm(ii,1); corn_pts_mm(ii,2); corn_pts_mm(ii,3); 1];
    coord_IRISS = TIO_AC*coord; % Transform that point into {IRISS}
    corn_pts_mm(ii,:) = coord_IRISS(1:3)'; % Replace the {OCT} coords for that row with {IRISS} coords
end

% 2. Convert endo to {IRISS}
for ii = 1:size(endo_pts_mm,1) % Loop through all the coordinates
    coord = [endo_pts_mm(ii,1); endo_pts_mm(ii,2); endo_pts_mm(ii,3); 1];
    coord_IRISS = TIO_AC*coord; % Transform that point into {IRISS}
    endo_pts_mm(ii,:) = coord_IRISS(1:3)'; % Replace the {OCT} coords for that row with {IRISS} coords
end

% 3. Convert iris to {IRISS}
for ii = 1:size(iris_pts_mm,1) % Loop through all the coordinates
    coord = [iris_pts_mm(ii,1); iris_pts_mm(ii,2); iris_pts_mm(ii,3); 1];
    coord_IRISS = TIO_AC*coord; % Transform that point into {IRISS}
    iris_pts_mm(ii,:) = coord_IRISS(1:3)'; % Replace the {OCT} coords for that row with {IRISS} coords
end

% 4. Convert pupil to {IRISS}
for ii = 1:size(pupil_pts_mm,1) % Loop through all the coordinates
    coord = [pupil_pts_mm(ii,1); pupil_pts_mm(ii,2); pupil_pts_mm(ii,3); 1];
    coord_IRISS = TIO_AC*coord; % Transform that point into {IRISS}
    pupil_pts_mm(ii,:) = coord_IRISS(1:3)'; % Replace the {OCT} coords for that row with {IRISS} coords
end

% 5. Convert pupil center to {IRISS}
coord = [centerLoc(1); centerLoc(2); centerLoc(3); 1];
coord_IRISS = TIO_AC*coord;
centerLoc = coord_IRISS(1:3);

% 6. Convert circle normal to {IRISS}
circleNormal = TIO_AC(1:3,1:3)*circleNormal;

% 7. Convert pc fit points to {IRISS}
temp = [pcfitpts_mm ones(size(pcfitpts_mm,1),1)] * TIO_AC';
pcfitpts_mm = temp(:,1:3);

xi_PC = pcfitpts_mm(:,1);
yi_PC = pcfitpts_mm(:,2);
zi_PC = pcfitpts_mm(:,3);

% 8. Convert equator points to {IRISS}
temp = [eqpts ones(size(eqpts,1),1)] * TIO_AC';
eqpts = temp(:,1:3);

xi_eq = eqpts(:,1);
yi_eq = eqpts(:,2);
zi_eq = eqpts(:,3);

%% Surface coordinate transformations

% Convert endo surface to {IRISS}
for ii = 1:size(xi_endo,1) % Loop through all the coordinates
    coord = [xi_endo(ii); yi_endo(ii); zi_endo(ii); 1];
    coord_IRISS = TIO_AC*coord; % Transform that point into {IRISS}
    xi_endo(ii) = coord_IRISS(1); % Replace the {OCT} coords for that row with {IRISS} coords
    yi_endo(ii) = coord_IRISS(2);
    zi_endo(ii) = coord_IRISS(3);
end

T_endo = delaunay(xi_endo,yi_endo);
TO_endo = triangulation(T_endo, xi_endo(:), yi_endo(:), zi_endo(:));

% Convert pc surface to {IRISS}
T_PC = delaunay(xi_PC,yi_PC);
TO_PC = triangulation(T_PC, xi_PC(:), yi_PC(:), zi_PC(:));

%% Generate trajectory
%% coordinate settings
% IrisCenter = Center_post_IRISSframe'; % transpose so LabVIEW GUI can read
% IrisCenterXY = Center_post_IRISSframe(1:2);

% Testing 2021-09-14 Mia
IrisCenter = centerLoc;
IrisCenterZ = centerLoc(3);
IrisCenterXY = centerLoc(1:2);
IrisPlane_post_mm_IRISSframe = [0; 0; 1; centerLoc(3)];  % 09-20-21
IrisEllipseAxis_post_IRISSframe = [1/(pupilRadius^2) 0; 0 1/(pupilRadius^2)]; % 09-20-21


Pinv = IrisEllipseAxis_post_IRISSframe;
L = chol(Pinv,'lower');
A = L'\eye(2);
a = max(eig(A));
D = 2*a; % use major axis to create grid
xb = D/2+0.05; xgrid = linspace(-xb,+xb,Ngrid);
yb = D/2+0.05; ygrid = linspace(-yb,+yb,Ngrid);
[X,Y] = meshgrid(xgrid,ygrid);
X = X + IrisCenterXY(1);
Y = Y + IrisCenterXY(2);

%% surface 2D arrays
Zp = PolyCoef_post_mm_IRISSframe(1);
Zc = PolyCoef_cornea_mm_IRISSframe(1);
coeff_za_work =  -[ 0, 0.01, 0.01,  0.02, 0,  0.02 ];
coeff_zp_work =   [ 0, 0.01, 0.01,  0.02, 0,  0.02 ];
Za_temp = coeff_za_work(1);
Zp_temp = coeff_zp_work(1);

for k = 1:SurfacePolyOrd
    idx = k*(k+1)/2 + 1;
    for kk = 0:k
        Zp = Zp + PolyCoef_post_mm_IRISSframe(idx+kk) * ...
            ( (X).^(k-kk)).* ...
            ( (Y).^(kk));
        Zc = Zc + PolyCoef_cornea_mm_IRISSframe(idx+kk) * ...
            ( (X).^(k-kk)).* ...
            ( (Y).^(kk));
        Za_temp = Za_temp + coeff_za_work(idx+kk) * ...
            ( (X-IrisCenterXY(1)).^(k-kk) ).* ...
            ( (Y-IrisCenterXY(2)).^(kk) );
        Zp_temp = Zp_temp + coeff_zp_work(idx+kk) * ...
            ( (X-IrisCenterXY(1)).^(k-kk) ).* ...
            ( (Y-IrisCenterXY(2)).^(kk) );
    end
end

Zi = ( IrisPlane_post_mm_IRISSframe(4) - IrisPlane_post_mm_IRISSframe(1)*X - IrisPlane_post_mm_IRISSframe(2)*Y )/ IrisPlane_post_mm_IRISSframe(3);
Zc_true =  Zc + (z_OCT_cornea-z_OCT_origin);
Za_true =  Zc_true - corneaThickness_mm;
Zp_true = (Zp + (z_OCT_post  -z_OCT_origin) - Zc_true )/idx_refract + Zc_true;
Zi_true = (Zi + (z_OCT_cornea-z_OCT_origin) - Zc_true )/idx_refract + Zc_true;

lensThickness = max(Za_true(:)) - min(Zp_true(:));
%IrisCenterZ = mean(Zi_true(:)); % Testing 2021-09-15

IrisCenter(3) = IrisCenterZ;
depthIris2Post = IrisCenterZ - min(Zp_true(:));

% constraint space
ooeff_L1min = [ 0,tan(deg2rad(L1_Constr(1))),1,0 ];
coeff_L1max = [ 0,tan(deg2rad(L1_Constr(2))),1,0 ];
L1_minPlane = ( ooeff_L1min(4) - ooeff_L1min(1)*X - ooeff_L1min(2)*Y )/ ooeff_L1min(3);
L1_maxPlane = ( coeff_L1max(4) - coeff_L1max(1)*X - coeff_L1max(2)*Y )/ coeff_L1max(3);

% compensate for refraction
za_true_center = griddata(X,Y,Za_true,IrisCenterXY(1),IrisCenterXY(2),'cubic');
zp_true_center = griddata(X,Y,Zp_true,IrisCenterXY(1),IrisCenterXY(2),'cubic');
za_work_center = griddata(X,Y,Za_temp,IrisCenterXY(1),IrisCenterXY(2),'cubic');
zp_work_center = griddata(X,Y,Zp_temp,IrisCenterXY(1),IrisCenterXY(2),'cubic');

d_Zi2Zp = depthIris2Post * DepthCtrl;
for k = 1:NoCycles
    Za_work{k} = Za_temp - (za_work_center - IrisCenterZ - d_Zi2Za(k));
    Zp_work{k} = Zp_temp - (zp_work_center - IrisCenterZ + d_Zi2Zp(k));
    za_eps(k) =  (za_true_center - IrisCenterZ - d_Zi2Za(k));
    zp_eps(k) = -(zp_true_center - IrisCenterZ + d_Zi2Zp(k));
end

za_true = za_true_center;
za_work = -(za_work_center - IrisCenterZ - d_Zi2Za(1));
zp_work = -(zp_work_center - IrisCenterZ + d_Zi2Zp(1));
zp_true = zp_true_center;


%% define normalized normTrajectory
r = 1;
thb = linspace(0,2*pi,NnormTraj);
%thb = linspace(0,pi,NnormTraj); %  Testing 2021-09-16
beta = deg2rad(beta);
bound = [r*cos(thb);
    r*sin(thb) + r];
[thi,ri] = cart2pol(bound(1,:),bound(2,:));

if flowerMode == 0 || flowerMode == 4
    % find array index of the starting point
    [~,k] = min(abs(thi-pi/2+beta));
    thi = circshift(thi',NnormTraj-k+1)';
    ri = circshift(ri',NnormTraj-k+1)';
    [~,m] = min(abs(thi-pi/2-beta));
    
    % clear unused angle range
    if ri(m) >= 0
        ri(m+1:end) = [];
        thi(m+1:end) = [];
    else
        ri(m:end) = [];
        thi(m:end) = [];
    end
    
    % polar flower pattern
    s = linspace(0,2*pi,length(thi));
    r_flr = (ri-ofst).*(sin(n_flr*s/2).^2);
    wb = hann(round(.5*length(thi)/n_flr))';
    Nwb = round(size(wb,2)/2);
    wb = wb(1:Nwb); w = ones(1,length(thi)); w(1:Nwb) = wb;
    w(length(thi)-Nwb+1:end) = fliplr(wb);
    r_flr = r_flr + ofst*w;
    
    % normalized flower normTrajectory
    normTraj = [r_flr.*cos(thi) ;
        r_flr.*sin(thi) + r];
    
elseif flowerMode == 1 || flowerMode == 5
    % generate polar flower pattern
    s = linspace(0,2*pi,Ngrid);
    r_flr = (r-ofst).*sin(n_flr*s/2).^2;
    wb = hann(round(length(s)/n_flr))';
    Nwb = round(size(wb,2)/2);
    wb = wb(1:Nwb); w = ones(1,Ngrid); w(1:Nwb) = wb;
    w(length(s)-Nwb+1:end) = fliplr(wb);
    r_scale = ones(1,length(s));
    r_scale(1:round(length(s)/4)) = linspace(rAtten*r,r,round(length(s)/4));
    r_scale = fliplr(r_scale);
    r_scale(1:round(length(s)/4)) = linspace(rAtten*r,r,round(length(s)/4));
    r_flr = r_scale.*r_flr + ofst*w;
    
    % normalized flower trajectory
    normTraj = [r_flr.*cos(s-pi/2)   ;
        r_flr.*sin(s-pi/2)+r];
end

if flowerMode == 4 || flowerMode == 5 % Generate reverse trajectories
    normTraj(1,:) = flip(normTraj(1,:)); 
    normTraj(2,:) = flip(normTraj(2,:)); 
end

if flowerMode == 0 || flowerMode == 1 || flowerMode == 4 || flowerMode == 5
    % scaling
    normTraj(2,:) = normTraj(2,:) - r;
    % scaleTraj = ( A - diag([eps eps]))*normTraj;
    %trajRadius = 0.3*pupilRadius; % Traj radius is scaled from pupil radius
    trajRadius = scaleRadius*pupilRadius;
    scaleTraj = diag([trajRadius trajRadius])*normTraj;
    
    
    
    %% Rotating trajectory and generate tilting matrix
    % Rotate x and y coordinates before translating center 2021-09-14 Mia
%     R = [cos(3*pi/2) -sin(3*pi/2); sin(3*pi/2) cos(3*pi/2)]; % 270 degree rotation in (x,y) plane
    R = [cos(pi) -sin(pi); sin(pi) cos(pi)]; % 180 degree rotation in (x,y) plane
    scaleTraj = R*[scaleTraj(1,:); scaleTraj(2,:)]; % Applying 2x2 rotation matrix to the 2d trajectory
    
    % Translate the rotated coordinates
    x = scaleTraj(1,:) + IrisCenterXY(1);
    y = scaleTraj(2,:) + IrisCenterXY(2);
    
    
    % Obtain unit rotation vector and angle for tilt
    if circleNormal(3) < 0
        circleNormal = -circleNormal;
    end
    
    rot_vector = cross([0;0;1], circleNormal); % Rotation vector obtained as the cross product between z-axis of {IRISS} and circleNormal
    rot_vector = rot_vector/norm(rot_vector); % Obtain unit rotation vector
    rot_angle = acos(dot([0;0;1], circleNormal)/norm(circleNormal)); % Letting dot(v1,v2) = norm(v1)*norm(v2)*cos(theta) and solving for theta
    
    % Construct rotation matrix for tilting trajectory
    ux = rot_vector(1); uy = rot_vector(2); uz = rot_vector(3);
    cost = cos(rot_angle); sint = sin(rot_angle);
    
    Rtilt = [cost + ux^2*(1-cost), ux*uy*(1-cost) - uz*sint, ux*uz*(1-cost) + uy*sint; ...
        uy*ux*(1-cost) + uz*sint, cost + uy^2*(1-cost), uy*uz*(1-cost) - ux*sint; ...
        uz*ux*(1-cost) - uy*sint, uz*uy*(1-cost) + ux*sint, cost + uz^2*(1-cost)];
    
    % Defining a location for the center of the trajectory, underneath the iris
    % Note: The x and y offsets are currently in the IRISS frame, whereas the z
    % offset is normal to the iris plane
    traj_offset = (d_Zi2Za(1) - d_Zi2Zp(1))/2;
    traj_offset = traj_offset + traj_offset_z;
    trajCenter = [centerLoc(1) + traj_offset*circleNormal(1) + traj_offset_x, ...
        centerLoc(2) + traj_offset*circleNormal(2) + traj_offset_y, ...
        centerLoc(3) + traj_offset*circleNormal(3)];
    
    %% determine the distance from 2D normTrajectory points to lower z bound
    for k = 1:NoCycles
        zp{k} = griddata(X,Y,Zp_work{k},x,y,'cubic');
        za{k} = griddata(X,Y,Za_work{k},x,y,'cubic');
    end
    
    
    
    %% shift in z direction to construct a 3D curve
    z_start = IrisCenterZ + (d_Zi2Za(1) - d_Zi2Zp(1))/2;
    z_ofst = -sin(n_flr*s);
    
    
    
    for k = 1:NoCycles
        z{k} = scoopPattern(z_ofst,z_start,za{k},zp{k},n_flr,s,w); % Generate z component of trajectory
    end
    
    x_original = x;
    y_original = y;
    
    for k = 1:NoCycles
        %% Rotate trajectory to align with pupil normal direction 2021-09-14 Mia
        traj_rot = Rtilt*[x_original - centerLoc(1); y_original - centerLoc(2); z{k}-z_start]; % Apply tilting matrix to the 3d trajectory
        
        % Testing 2021-09-15 Mia
        x = traj_rot(1,:) + trajCenter(1);
        y = traj_rot(2,:) + trajCenter(2);
        z{k} = traj_rot(3,:) + trajCenter(3);
        %
        %     if flowerMode == 0 % For angled traj, move starting point past center (2021-09-16 Mia)
        %         dist = -3; % Arbitary distance to translate the trajectory from current position (not from center)
        %         dir_vector = cross(circleNormal,[1;0;0]);
        %         x = x + dist*dir_vector(1);
        %         y = y + dist*dir_vector(2);
        %         z{k} = z{k} + dist*dir_vector(3);
        %     end
        
    end
    
end 

% L1 saturation
for k = 1:NoCycles
    if flowerMode == 0 || flowerMode == 1 || flowerMode == 4 || flowerMode == 5
        x_temp = x; y_temp = y; z_temp = z{k}; % for debugging purpose
        x_sat{k} = x_temp;
        y_sat{k} = y_temp;
        z_sat{k} = z_temp;
        % Insertion and extraction trajectories (2021-10-07)
    elseif flowerMode == 2 % Insertion
        t = linspace(0,1,NnormTraj);
        x = startLoc(1) + t*(centerLoc(1) - startLoc(1));
        y = startLoc(2) + t*(centerLoc(2) - startLoc(2));
        z{k} = startLoc(3) + t*(centerLoc(3) - startLoc(3));
        
        x_sat{k} = x; y_sat{k} = y; z_sat{k} = z{k}; 
    elseif flowerMode == 3
        t = linspace(1,0,NnormTraj);
        x = startLoc(1) + t*(centerLoc(1) - startLoc(1));
        y = startLoc(2) + t*(centerLoc(2) - startLoc(2));
        z{k} = startLoc(3) + t*(centerLoc(3) - startLoc(3));
        x_sat{k} = x; y_sat{k} = y; z_sat{k} = z{k}; 
    end
end

% insertion part (2022-04-25 Kevin: for presentation)
% x_sat{2} = [linspace(0,x_sat{2}(1),1000) x_sat{2}];
% y_sat{2} = [linspace(0,y_sat{2}(1),1000) y_sat{2}];
% z_sat{2} = [linspace(0,z_sat{2}(1),1000) z_sat{2}];

%% Plotting

for k = 1:NoCycles
    figure(k); clf;
    
    %% Plot eye model
    % Plot cornea
    hc = scatter3(corn_pts_mm(:,1), corn_pts_mm(:,2), corn_pts_mm(:,3), 1, [0.1 0.2 0.8]);
    set(hc, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);
    % plot params
    hold on; grid on; axis equal;
    %set(gca, 'zdir', 'reverse');
    xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
    
    % Plot endo points and surface
    he = scatter3(endo_pts_mm(:,1), endo_pts_mm(:,2), endo_pts_mm(:,3), 3, [0 0 0]); hold on;
    set(he, 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0);
    
    trimesh(TO_endo, 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.3); hold on;
    
    % Plot iris points
    hs = scatter3(iris_pts_mm(:,1), iris_pts_mm(:,2), iris_pts_mm(:,3), 1, [0.8 0.2 0.1]); hold on;
    set(hs, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);
    
    % Plot pupil points and centerline
    hs = scatter3(pupil_pts_mm(:,1), pupil_pts_mm(:,2), pupil_pts_mm(:,3), 10, [0.2 0.2 1]); hold on;
    set(hs, 'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', 0);
    
    plot3(centerLoc(1), centerLoc(2), centerLoc(3), 'g+'); hold on;
    
    
    emm = 4; % [mm] distance up&down to extend line
    plot3([centerLoc(1) centerLoc(1)+emm*circleNormal(1)], ... % plot pupil "optical center" line
        [centerLoc(2) centerLoc(2)+emm*circleNormal(2)], ...
        [centerLoc(3) centerLoc(3)+emm*circleNormal(3)], 'r-', 'LineWidth', 1); hold on;
    plot3([centerLoc(1) centerLoc(1)-emm*circleNormal(1)], ...
        [centerLoc(2) centerLoc(2)-emm*circleNormal(2)], ...
        [centerLoc(3) centerLoc(3)-emm*circleNormal(3)], 'r-', 'LineWidth', 1); hold on;
    
    circle_3D(pupilRadius, centerLoc, circleNormal); hold on;
    
    % Plot PC points and surface
    trimesh(TO_PC, 'LineStyle', 'none', 'FaceColor', 'r', 'FaceAlpha', 0.3); hold on;
%     trimesh(TO_PC, 'FaceColor', 'r', 'FaceAlpha', 0.3); hold on;
    
    % Plot equator points
    plot3(eqpts(:,1), eqpts(:,2), eqpts(:,3), 'b:', 'LineWidth', 1); hold on;
    
    % Plot insertion point (0,0,0)
%     plot3(0,0,0,'k+');
    
    % Plot initial location of tooltip
%     plot3([0 startLoc(1)],[0 startLoc(2)],[0 startLoc(3)],'k');
    
    % Flip y axis
    set(gca,'YDir','reverse');
    %% 2021-10-05 Kevin: just for plotting something else
    %     addpath('\\Iriss_server\OCT_DATA\Kevin Data\Kevin\kllib\');
    %     DDIR = '\\Iriss_server\OCT_DATA\Demo Data\2021-10-01 Pig Eye Lens Extraction\IOPData\';
    %     [~,~,~,~,~,~,~, X1, Y1, Z1, OCT] = LoadIOPData_v2([DDIR 'IOPData1.txt']);
    %     [~,~,~,~,~,~,~, X2, Y2, Z2, OCT] = LoadIOPData_v2([DDIR 'IOPData2.txt']);
    %     h1 = plot3(X1, Y1, Z1+traj_offset_z,'LineWidth', 2); hold on;
    %     h2 = plot3(X2, Y2, Z2+traj_offset_z,'LineWidth', 2); hold on;
    %     legend([h1 h2], 'Trial 01', 'Trial 02');
    
    %% Plot trajectory
    plot3(x_sat{k},y_sat{k},z_sat{k},'k','LineWidth',2); hold on;
    hold off
    xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Z [mm]');
    
    title('Eye Model and Trajectory \{IRISS\} [mm]');
    
    
    
end

%% calculate the overall arc length
for k = 1:NoCycles
    S(k) = sum(sqrt(diff(x_sat{k}).^2+diff(y_sat{k}).^2+diff(z_sat{k}).^2));
end

%% calculate the tool rotation angle based on the tool tip position
for k = 1:NoCycles
    L4{k} = atan2( (zc-z_sat{k}),x_sat{k}-IrisCenterXY(1) )* 180/pi - 90;
end

%% calculate the vacuum force based on the tool tip position
min_dist2pc = zeros(NoCycles,length(x)); % Matrix to hold the distance to PC for all trajectory points, for all 3 cycles
x_opt = zeros(NoCycles,length(x));
y_opt = zeros(NoCycles,length(x));
z_opt = zeros(NoCycles,length(x));

for k = 1:NoCycles
    % Calculating distance to pc
    x_traj = x_sat{k};
    y_traj = y_sat{k};
    z_traj = z_sat{k};
    
    
    for ii = 1:length(x_traj) % Loop through the trajectory points
        x_current = x_traj(ii);
        y_current = y_traj(ii);
        z_current = z_traj(ii);
        
        dist2pc = zeros(1,length(xi_PC)); % For each trajectory point, create array to contain the distances
        for jj = 1:length(xi_PC) % Loop through surface points to find closest distance from trajectory to PC
            dist2pc(jj) = norm([xi_PC(jj), yi_PC(jj), zi_PC(jj)] - [x_current, y_current, z_current]);
        end
        
        [min_dist2pc(k,ii), index_min] = min(dist2pc); % Take the minimum distance for that traj point to be the smallest distance to PC
        x_opt(k,ii) = xi_PC(index_min);
        y_opt(k,ii) = yi_PC(index_min);
        z_opt(k,ii) = zi_PC(index_min);
    end
    
    % Specify vacuum command
    min_vacuum = 500; % [mmHg]
    max_vacuum = 600; % [mmHg]
    dist_for_min = 2; % [mm] % Distance corresponding to minimum vacuum command, [mm]
    dist_for_max = 5; % Distance corresponding to maximum vacuum command, [mm]
    
    vacuum_array = zeros(1, length(x_traj));
    
    for i = 1:length(x_traj)
        if      min_dist2pc(k,i) < dist_for_min
            vacuum_array(i) = min_vacuum;
        elseif  dist_for_min < min_dist2pc(k,i) && min_dist2pc(k,i) < dist_for_max
            vacuum_array(i) = (min_dist2pc(k,i) - dist_for_min)*(max_vacuum - min_vacuum)/(dist_for_max - dist_for_min) + min_vacuum;
        else
            vacuum_array(i) = max_vacuum;
        end
    end
    
    vacf{k} = vacuum_array;
    
    %vacf{k} = vacuumSchedule(z_sat{k},zp{k},z_thld,vac_bnd);
end



%% output formatting
for k = 1:NoCycles
    x_out(k,:) = x;
    y_out(k,:) = y;
    z_out(k,:) = z{k};
    L4_out(k,:) = L4{k};
    vacf_out(k,:) = vacf{k};
end

%% save file
ParamDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\ParameterSaving';

Time = clock;
FileName = ['IRISS_ParamData_',...
    num2str(Time(1)),'-',num2str(Time(2)),'-',num2str(Time(3)),'-',...
    num2str(Time(4)),'-',num2str(Time(5)),'.mat'];
FullFilePath = fullfile(ParamDIR,FileName);
save(FullFilePath,...
    'z_OCT_origin', 'z_OCT_cornea', 'z_OCT_post', 'idx_refract', 'Ngrid', 'NnormTraj', 'L1_Constr',...
    'flowerMode', 'beta', 'n_flr', 'ofst', 'eps', 'd_Zi2Za', 'DepthCtrl', 'rAtten', 'zc', 'z_thld', 'vac_bnd', 'NoCycles', 'CycleTime',...
    'X', 'Y', 'Pinv', 'IrisCenter', 'Zc_true', 'Za_work', 'Za_true', 'Zp_work', 'Zp_true', 'Zi_true',...
    'x_out', 'y_out', 'z_out', 'L4_out', 'S', 'vacf_out', 'za_eps', 'zp_eps')

end
