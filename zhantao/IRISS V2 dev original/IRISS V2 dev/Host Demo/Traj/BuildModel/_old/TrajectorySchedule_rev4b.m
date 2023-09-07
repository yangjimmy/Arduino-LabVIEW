function [ X, Y, Pinv, IrisCenter, Zc_true, Za_true, Zp_true, Zi_true,...
           za_true, za_work, zp_work, zp_true,...
           x_out, y_out, z_out, L4_out, S, vacf_out, za_eps, zp_eps ] = TrajectorySchedule_rev4b...
         ( z_OCT_origin, z_OCT_cornea, z_OCT_post, idx_refract, Ngrid, NnormTraj, L1_Constr,...
           flowerMode, beta, n_flr, ofst, eps, d_Zi2Za, DepthCtrl, rAtten, zc, z_thld, vac_bnd, CycleTime)
% 
% clc; clear all; close all
% z_OCT_origin = 0;                 % where OCT performs 13-pt algorithm for coord. transformation
% z_OCT_cornea = 0;                 % where OCT takes a snap shot for cornea
% z_OCT_post   = 0;                 % where OCT takes a snap shot for posterior capsule
% idx_refract = 1.35;               % refractive index
% Ngrid = 200;                      % no. of workspace grid points
% NnormTraj = 1000;                 % no. of normTrajetory grid points
% L1_Constr = [-5,30];              % L1 joint constraint in degrees
% flowerMode = 1;                   % mode = 0: pivot at entry; mode = 1: centered
% beta = 60;                        % half angle range in deg
% n_flr = 10;                       % no. of lobes
% ofst = 0.2;                       % relative offset parameter in radial direction
% eps  = 0.5;                       % safety bound in radial direction [mm]
% d_Zi2Za = [0.1,0.1,0.1];          % trajectory up offset from Zi plane
% DepthCtrl = [0.2,0.3,0.4];        % depth in terms of thickness for each stage, changes Zi2Zp
% rAtten = 0.2;                     % attenuate halve close to the entry radially
% zc = 3;                           % axis of aspiration points towards (0,~,zc)
% z_thld = [2,3.5];                 % threshold z distances used to define extreme values of vacuum force
% vac_bnd = [80,100];               % extreme values of vacuum force
% CycleTime = [60,90,120];          % time elasped in seconds for each run;

% REVISION:
% rev1.  first version
% rev2.  change plot settings
% rev3.  save parameters and trajectories
% rev4.  use post center and consider elliptic XY space
% rev5.  MJG, added MDIR 


% specify directory where .mat files are located 
MDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\modelFiles';

% ---

% add trailing slash to MDIR if none specified by user
if MDIR(end) ~= filesep; MDIR(end+1) = filesep; end 

if length(DepthCtrl) ~= length(CycleTime)
    error('lengths of depth control and cycle time are not consistent!')
end
NoCycles = length(DepthCtrl);

% load our model data... 
load([MDIR 'EyeModel_capsule.mat');
load([MDIR 'EyeModel_cornea.mat');


%% coordinate settings
IrisCenter = Center_post_IRISSframe'; % transpose so LabVIEW GUI can read
IrisCenterXY = Center_post_IRISSframe(1:2);
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
IrisCenterZ = mean(Zi_true(:));
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

%% adjust point cloud data
AdjustedPointCloud = zeros(size(XYZ_mm_IRISSframe_cornea,1) + size(XYZ_mm_IRISSframe_capsule,1),3);
for i = 1:size(XYZ_mm_IRISSframe_cornea,1)
    AdjustedPointCloud(i,1:2) = XYZ_mm_IRISSframe_cornea(i,1:2);
    
    temp = 0;
    for k = 1:SurfacePolyOrd   
    idx = k*(k+1)/2 + 1;
        for kk = 0:k
            temp = temp + PolyCoef_cornea_mm_IRISSframe(idx+kk) * ...
                   ( AdjustedPointCloud(i,1).^(k-kk)).* ...
                   ( AdjustedPointCloud(i,2).^(kk));
        end
    end
    
    AdjustedPointCloud(i,3) = (XYZ_mm_IRISSframe_cornea(i,3) - temp)/idx_refract + temp;    
end

for i = 1:size(XYZ_mm_IRISSframe_capsule,1)
    offset = size(XYZ_mm_IRISSframe_cornea,1);
    AdjustedPointCloud(i+offset,1:2) = XYZ_mm_IRISSframe_capsule(i,1:2);
    
    temp = 0;
    for k = 1:SurfacePolyOrd   
    idx = k*(k+1)/2 + 1;
        for kk = 0:k
            temp = temp + PolyCoef_cornea_mm_IRISSframe(idx+kk) * ...
                   ( AdjustedPointCloud(i+offset,1).^(k-kk)).* ...
                   ( AdjustedPointCloud(i+offset,2).^(kk));
        end
    end
    
    AdjustedPointCloud(i+offset,3) = (XYZ_mm_IRISSframe_capsule(i,3) - temp)/idx_refract + temp;    
end


%% define normalized normTrajectory
r = 1;
thb = linspace(0,2*pi,NnormTraj);
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
x = scaleTraj(1,:) + IrisCenterXY(1);
y = scaleTraj(2,:) + IrisCenterXY(2);


%% determine the distance from 2D normTrajectory points to lower z bound
for k = 1:NoCycles
    zp{k} = griddata(X,Y,Zp_work{k},x,y,'cubic');
    za{k} = griddata(X,Y,Za_work{k},x,y,'cubic');
end


%% shift in z direction to construct a 3D curve
z_start = IrisCenterZ + (d_Zi2Za(1) - d_Zi2Zp(1))/2;
z_ofst = -sin(n_flr*s);

for k = 1:NoCycles
    z{k} = scoopPattern(z_ofst,z_start,za{k},zp{k},n_flr,s,w);
end

% L1 saturation
for k = 1:NoCycles
%     [x_temp,y_temp,z_temp] = L1saturation(x,y,z{k},L1_Constr);
    x_temp = x; y_temp = y; z_temp = z{k}; % for debugging purpose
    x_sat{k} = x_temp;
    y_sat{k} = y_temp;
    z_sat{k} = z_temp;
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


%% plotting
close all;

for k = 1:NoCycles
    figure(k);
    plot3(AdjustedPointCloud(1:50:end,1), AdjustedPointCloud(1:50:end,2), AdjustedPointCloud(1:50:end,3),'.','color', [51 102 204]/255,'MarkerSize',1); hold on;
    grid on; axis equal;
    surf(X,Y,Za_true,'FaceColor','r','EdgeColor','none','FaceAlpha',.1);
    surf(X,Y,Za_work{k},'FaceColor','g','EdgeColor','none','FaceAlpha',.2);
    surf(X,Y,Zp_true,'FaceColor','r','EdgeColor','none','FaceAlpha',.1);
    surf(X,Y,Zp_work{k},'FaceColor','g','EdgeColor','none','FaceAlpha',.2);
    plot3(x_sat{k},y_sat{k},z_sat{k},'k','LineWidth',2); 
    hold off
    xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Z [mm]');
%     view([270 0])
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
Time = clock;
FileName = ['IRISS_ParamData_',...
             num2str(Time(1)),'-',num2str(Time(2)),'-',num2str(Time(3)),'-',...
             num2str(Time(4)),'-',num2str(Time(5)),'.mat'];
FolderName = 'ParameterSaving';
FullFilePath = fullfile(FolderName,FileName);
save(FullFilePath,...
     'z_OCT_origin', 'z_OCT_cornea', 'z_OCT_post', 'idx_refract', 'Ngrid', 'NnormTraj', 'L1_Constr',...
     'flowerMode', 'beta', 'n_flr', 'ofst', 'eps', 'd_Zi2Za', 'DepthCtrl', 'rAtten', 'zc', 'z_thld', 'vac_bnd', 'NoCycles', 'CycleTime',...
     'X', 'Y', 'Pinv', 'IrisCenter', 'Zc_true', 'Za_work', 'Za_true', 'Zp_work', 'Zp_true', 'Zi_true',...
     'x_out', 'y_out', 'z_out', 'L4_out', 'S', 'vacf_out', 'za_eps', 'zp_eps')


end