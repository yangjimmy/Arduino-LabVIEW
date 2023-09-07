function [ X, Y, Pinv, IrisCenter, Zc_true, Za_true, Zp_true, Zi_true,...
    za_true, za_work, zp_work, zp_true,...
    x_out, y_out, z_out, L4_out, S, vacf_out, za_eps, zp_eps ] = TrajectorySchedule_rev6...
    ( z_OCT_origin, z_OCT_cornea, z_OCT_post, idx_refract, Ngrid, NnormTraj, L1_Constr,...
    flowerMode, beta, n_flr, ofst, eps, d_Zi2Za, DepthCtrl, rAtten, zc, z_thld, vac_bnd, CycleTime)

% TrajectorySchedule_rev6 2021-09-10 Mia
%   This code loads the EyeModel .mat files to generate the
%   trajectory within the eye model in {IRISS}

% clear all; close all; clc; 
% For testing function 
% z_OCT_origin = 0;                 % where OCT performs 13-pt algorithm for coord. transformation
% z_OCT_cornea = 0;                 % where OCT takes a snap shot for cornea
% z_OCT_post   = 0;                 % where OCT takes a snap shot for posterior capsule
% idx_refract = 1.35;               % refractive index
% Ngrid = 200;                      % no. of workspace grid points
% NnormTraj = 1000;                 % no. of normTrajetory grid points
% L1_Constr = [-5,30];              % L1 joint constraint in degrees
% flowerMode = 0;                   % mode = 0: pivot at entry; mode = 1: centered
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
addpath('D:\IRISSoft LV2016 beta\Host Demo\Traj');

% Add path to functions
addpath('D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\functions');
 
% specify where the .mat files were saved (by the processVSCAN function)
SDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\savedData';
% specify directory where .mat files are located 
MDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\modelFiles';

% Add trailing slash to SDIR if it wasn't specified by the user
if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end 
if MDIR(end) ~= filesep; MDIR(end+1) = filesep; end 

if length(DepthCtrl) ~= length(CycleTime)
    error('lengths of depth control and cycle time are not consistent!')
end
NoCycles = length(DepthCtrl);

%% Load data
% load the scan numbers used for this pair 
load([SDIR 'SCAN_NO_ACh.mat'], 'SCAN_NO_ACh');
load([SDIR 'SCAN_NO_PC.mat'], 'SCAN_NO_PC');

% load ACh and PC data points for plotting... 
load([SDIR 'params_ACh_' num2str(SCAN_NO_ACh,'%04i') '.mat']); 
load([SDIR 'params_PC_' num2str(SCAN_NO_PC,'%04i') '.mat']);

load([MDIR 'EyeModel_cornea.mat']);
load([MDIR 'EyeModel_capsule.mat']);

% Copy these variables from the cornea variables into the capsule variables
% (2021-09-08 Mia)
IrisPlane_post_mm_IRISSframe = IrisPlane_cornea_mm_IRISSframe; 
IrisEllipseAxis_post_IRISSframe = IrisEllipseAxis_cornea_IRISSframe; 
Center_post_IRISSframe = Center_cornea_IRISSframe; 

%% Plotting in {OCT}
figure(6); clf;
% --- plot cornea data 
hc = scatter3(corn_pts_mm(:,1), corn_pts_mm(:,2), corn_pts_mm(:,3), 1, [0.1 0.2 0.8]);
set(hc, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);

% --- plot params
hold on; grid on; axis equal; 
set(gca, 'zdir', 'reverse'); 
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
% xlim([0 10]); ylim([0 10]); zlim([0 9.4]); 

% --- plot endo pts 
he = scatter3(endo_pts_mm(:,1), endo_pts_mm(:,2), endo_pts_mm(:,3), 3, [0 0 0]);
set(he, 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0);

% fit surface to endo pts 
surffit_endo = fit([endo_pts_mm(:,1), endo_pts_mm(:,2)], endo_pts_mm(:,3), 'poly22');

% --- plot surface fit of endo 
% wow, must have been really tired here... TODO: just use meshgrid()
rr = (0:0.1:10)'; % range of points 
xi_endo = repmat(rr, size(rr,1), 1);
yi_endo = repelem(rr, size(rr,1));
zi_endo = surffit_endo(xi_endo,yi_endo); % eval surf model at each value of xi and yi 
T = delaunay(xi_endo,yi_endo); 
TO_endo = triangulation(T, xi_endo(:), yi_endo(:), zi_endo(:));
% plot mesh and change color 
trimesh(TO_endo, 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.3); 

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

% plot center location and pupil direction 
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


% --- plotting PC 

% calculate relative distance that the OCT moved 
OCTzRelDist = OCTz_ACh - OCTz_PC; 

% then shift all the Z data pts in this scan down by that much 
pc_pts_mm(:,3) = pc_pts_mm(:,3);% + OCTzRelDist; % 2021-09-13 Mia % I think this shift has already been taken care of
% pc_mm(:,3) = pc_mm(:,3) + OCTzRelDist;


% full PC data points 
plot3(pc_pts_mm(:,1), pc_pts_mm(:,2), pc_pts_mm(:,3), 'k.', 'MarkerSize', 1); 



% plot surface fit of PC 
% det range of x and y... don't want it to extend too large across the plot
% (will look really bad)
padding = 1; % [mm] 
xlims = [min(pc_pts_mm(:,1))-padding max(pc_pts_mm(:,1))+padding];
ylims = [min(pc_pts_mm(:,2))-padding max(pc_pts_mm(:,2))+padding];
% get full range
nn = 20;
xrange = linspace(xlims(1), xlims(2), nn)';
yrange = linspace(ylims(1), ylims(2), nn)';
% then get numbers 
xi_PC = repmat(xrange, nn, 1);
yi_PC = repelem(yrange, nn);

% need to recalculate the surface fit because pc_mm(:,3) has updated 
surfPC_OCT = fit([pc_pts_mm(:,1), pc_pts_mm(:,2)], pc_pts_mm(:,3), 'poly22');
%, 'normalize', 'on');

% eval surf model at each value of xi and yi 
zi_PC = surfPC_OCT(xi_PC,yi_PC); 
T = delaunay(xi_PC,yi_PC); 
TO_PC = triangulation(T, xi_PC(:), yi_PC(:), zi_PC(:));
% plot mesh and change color 
trimesh(TO_PC, 'LineStyle', 'none', 'FaceColor', 'r', 'FaceAlpha', 0.3); 

xlim([0 10]); ylim([0 10]);

title(['AC Scan: ' num2str(SCAN_NO_ACh) '; PC Scan: ' num2str(SCAN_NO_PC)]);


%% Coordinate transformation for plotting Matt's model in {IRISS}
% Note: I think this section can be removed if we just care about
% trajectory, without the accompanying plot
TIO_PC = inv(TOI_PC); 
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

% 7. Convert pc points to {IRISS}
temp = [pc_pts_mm ones(size(pc_pts_mm,1),1)] * TIO_PC';
pc_pts_mm = temp(:,1:3);

%% Surface coordinate transformations
% Note: Might take a lot of computational time to transform all the points
% in the surface

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
% Plotting mesh and change color
% trimesh(TO, 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.3);

% Convert PC surface to {IRISS}
for ii = 1:size(xi_PC,1) % Loop through all the coordinates
    coord = [xi_PC(ii); yi_PC(ii); zi_PC(ii); 1];
    coord_IRISS = TIO_PC*coord; % Transform that point into {IRISS}
    xi_PC(ii) = coord_IRISS(1); % Replace the {OCT} coords for that row with {IRISS} coords
    yi_PC(ii) = coord_IRISS(2);
    zi_PC(ii) = coord_IRISS(3);
end

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
Za_true =  Zc_true - Thickness_cornea_mm;
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

% %% adjust point cloud data
% AdjustedPointCloud = zeros(size(XYZ_mm_IRISSframe_cornea,1) + size(XYZ_mm_IRISSframe_capsule,1),3);
% for i = 1:size(XYZ_mm_IRISSframe_cornea,1)
%     AdjustedPointCloud(i,1:2) = XYZ_mm_IRISSframe_cornea(i,1:2);
%     
%     temp = 0;
%     for k = 1:SurfacePolyOrd
%         idx = k*(k+1)/2 + 1;
%         for kk = 0:k
%             temp = temp + PolyCoef_cornea_mm_IRISSframe(idx+kk) * ...
%                 ( AdjustedPointCloud(i,1).^(k-kk)).* ...
%                 ( AdjustedPointCloud(i,2).^(kk));
%         end
%     end
%     
%     AdjustedPointCloud(i,3) = (XYZ_mm_IRISSframe_cornea(i,3) - temp)/idx_refract + temp;
% end
% 
% for i = 1:size(XYZ_mm_IRISSframe_capsule,1)
%     offset = size(XYZ_mm_IRISSframe_cornea,1);
%     AdjustedPointCloud(i+offset,1:2) = XYZ_mm_IRISSframe_capsule(i,1:2);
%     
%     temp = 0;
%     for k = 1:SurfacePolyOrd
%         idx = k*(k+1)/2 + 1;
%         for kk = 0:k
%             temp = temp + PolyCoef_cornea_mm_IRISSframe(idx+kk) * ...
%                 ( AdjustedPointCloud(i+offset,1).^(k-kk)).* ...
%                 ( AdjustedPointCloud(i+offset,2).^(kk));
%         end
%     end
%     
%     AdjustedPointCloud(i+offset,3) = (XYZ_mm_IRISSframe_capsule(i,3) - temp)/idx_refract + temp;
% end


%% define normalized normTrajectory
r = 1;
thb = linspace(0,2*pi,NnormTraj);
%thb = linspace(0,pi,NnormTraj); %  Testing 2021-09-16
beta = deg2rad(beta);
bound = [r*cos(thb);
    r*sin(thb) + r];
[thi,ri] = cart2pol(bound(1,:),bound(2,:));

if flowerMode == 0
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
        r_flr.*sin(thi)];
    
elseif flowerMode == 1
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

% scaling
normTraj(2,:) = normTraj(2,:) - r;
scaleTraj = ( A - diag([eps eps]))*normTraj;
%scaleTraj = 0.5*scaleTraj; % Shrinking the trajectory (2021-09-17 Mia) 
%trajRadius = 1*pupilRadius; % Traj radius is scaled from pupil radius 
%scaleTraj = diag([trajRadius trajRadius])*normTraj;

% % Remove petals below x-axis (2021-09-16 Mia)
% for ii = 1:size(scaleTraj,2) 
%     if scaleTraj(2,ii) <= 0 % If y value is negative, replace that point in the trajectory with [0;0] 
%         scaleTraj(:,ii) = [0; 0]; 
%     end
% end
% scaleTraj(:,all(~scaleTraj,1)) = []; % Remove all the [0;0] points we created from the trajectory 

% % Testing 2021-09-15
% figure; 
% plot(normTraj(1,:),normTraj(2,:)); hold on;
% plot(scaleTraj(1,:),scaleTraj(2,:)); 
% legend('Normal','Scaled'); 

%% Rotating trajectory and generate tilting matrix
% Rotate x and y coordinates before translating center 2021-09-14 Mia 
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

% 2021-09-15 Mia: Defining a location for the center of the trajectory, underneath the iris
% (preferably we instead constrain the top of the trajectory to be at the
% iris plane) 
traj_offset = (d_Zi2Za(1) - d_Zi2Zp(1))/2;
dist_below_iris = 1; % mm
traj_offset = traj_offset - dist_below_iris; % (2021-09-17 Mia) 
trajCenter = [centerLoc(1) + traj_offset*circleNormal(1), ...
    centerLoc(2) + traj_offset*circleNormal(2), ...
    centerLoc(3) + traj_offset*circleNormal(3)]; 

%% determine the distance from 2D normTrajectory points to lower z bound
for k = 1:NoCycles
    zp{k} = griddata(X,Y,Zp_work{k},x,y,'cubic');
    za{k} = griddata(X,Y,Za_work{k},x,y,'cubic');
end



%% shift in z direction to construct a 3D curve
z_start = IrisCenterZ + (d_Zi2Za(1) - d_Zi2Zp(1))/2;
z_ofst = -sin(n_flr*s);


 
for k = 1:NoCycles % (2021-09-16 Mia)
    z{k} = scoopPattern(z_ofst,z_start,za{k},zp{k},n_flr,s,w); % Generate z component of trajectory
    
    % Testing
% figure; 
% plot(x,y); 
%     % Remove petals above x axis
%     for ii = 1:length(y)
%         if y(ii) >= 0 % If y value is positive, replace that point in the trajectory with [0;0]
%             x(ii) = [];
%             y(ii) = [];
%             z{k(ii)} = [];
%         end
%     end


end

x_original = x; 
y_original = y;

for k = 1:NoCycles
    %% Rotate trajectory to align with pupil normal direction 2021-09-14 Mia 
    traj_rot = Rtilt*[x_original - centerLoc(1); y_original - centerLoc(2); z{k}-z_start]; % Apply tilting matrix to the 3d trajectory
    
%     x = traj_rot(1,:) + centerLoc(1);
%     y = traj_rot(2,:) + centerLoc(2);
%     z{k} = traj_rot(3,:) + centerLoc(3);
  
    % Testing 2021-09-15 Mia
    x = traj_rot(1,:) + trajCenter(1);
    y = traj_rot(2,:) + trajCenter(2);
    z{k} = traj_rot(3,:) + trajCenter(3);
   
    if flowerMode == 0 % For angled traj, move starting point past center (2021-09-16 Mia)
        dist = -3; % Arbitary distance to translate the trajectory from current position (not from center)
        dir_vector = cross(circleNormal,[1;0;0]);
        x = x + dist*dir_vector(1);
        y = y + dist*dir_vector(2);
        z{k} = z{k} + dist*dir_vector(3);
    end
end

 

% L1 saturation
for k = 1:NoCycles
    %     [x_temp,y_temp,z_temp] = L1saturation(x,y,z{k},L1_Constr);
    x_temp = x; y_temp = y; z_temp = z{k}; % for debugging purpose
    x_sat{k} = x_temp;
    y_sat{k} = y_temp;
    z_sat{k} = z_temp;
end


%% Plotting

for k = 1:NoCycles
    figure(k+1); clf; 
    
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
    plot3(pc_pts_mm(:,1), pc_pts_mm(:,2), pc_pts_mm(:,3), 'r.', 'MarkerSize', 1); hold on; 
    trimesh(TO_PC, 'LineStyle', 'none', 'FaceColor', 'r', 'FaceAlpha', 0.3); hold on; 
    
 
    %% Plot trajectory
    plot3(x_sat{k},y_sat{k},z_sat{k},'k','LineWidth',2); hold on; 
    hold off
    xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Z [mm]');
    
    set(gca,'YDir','reverse'); 

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
for k = 1:NoCycles
    vacf{k} = vacuumSchedule(z_sat{k},zp{k},z_thld,vac_bnd);
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
