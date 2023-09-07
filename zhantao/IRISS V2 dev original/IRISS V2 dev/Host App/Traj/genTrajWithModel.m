function [TrajX, TrajY, TrajZ] = genTrajWithModel(Ts, nCycle, ... 
    Pmax, Vmax, dR, radius, type, plotOpt)
%% 2021-12-01 Kevin
% This function takes in parameters to generate trajectory
% ---- INPUTS ----
% > Ts     : Sampling time for the trajectory
% > nCycle : Repetition of a sweep
% > Pmax   : Maximum travel length along the tool
% > Vmax   : Maximum speed of the trajectory
% > dR     : Offset of the trajectory in z direction (used for multi-depth ILC)
% > radius : The radius that constraints the trajectory
% > type   : The type of trajectory to generate
% > plotOpt: The plotting option
% ---- OUTPUTS ----
% > TrajX  : The X coordinate of the trajectory
% > TrajY  : The Y coordinate of the trajectory
% > TrajZ  : The Z coordinate of the trajectory

% set plotting attributes
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesFontSize',10);

% load surface data from PC fit
SDIR = '..\PC Polishing GUI\';
load([SDIR 'PCfit.mat']);

% surface data
orderSurfPoly = 2;                  % order of surface polynomial
% CoefPoly_post = ...                 % polynomial coefficients of posterior capsule
%     [ -4.7954, 0, -0.8818, 0.0882, 0, 0.0882 ];
CoefPoly_post = iriss_fitParams;    % polynomial coef. of PC from the model
    

CoefPoly_cornea  = ...              % polynomial coefficients of cornea
    [ 1.6977, 0, 0.9009, -0.0901, 0, -0.0901 ];

% iris data
CoefPlane_iris = ...                % iris plane coefficients
    [0, 0, 1, -1.5];
% CenterXY_iris = [0, 5];             % iris center x and y coordinates
CenterXY_iris = iriss_centerPC;     % PC center from the model
% radiusIris = 4;                     % iris radius
radiusIris = radius + 1;

% work surfaces
CoefPoly_work_top = ...             % top work surface
    -[ 0, 0.01, 0.01,  0.02, 0,  0.02 ];
CoefPoly_work_bottom = ...          % bottom work surface
    [ 0, 0.01, 0.01,  0.02, 0,  0.02 ];

% trajectory parameters
nCartGrid = 400;                    % no. of workspace grid points
% 2
dist_iris2post = 3.5;               % trajectory offset from iris to posterior

%% construct the quadratic surface based on the fitting model
% grid settings
xGridLimit = radiusIris + 0.05;
GridX = linspace(-xGridLimit, xGridLimit, nCartGrid);
yGridLimit = radiusIris + 0.05;
GridY = linspace(-yGridLimit, yGridLimit, nCartGrid);
[X, Y] = meshgrid(GridX, GridY);
X = X + CenterXY_iris(1);
Y = Y + CenterXY_iris(2);

% construct surface 2D array
Z_post   = CoefPoly_post(1);
Z_cornea = CoefPoly_cornea(1);
Z_work_top = CoefPoly_work_top(1);
Z_work_bot = CoefPoly_work_bottom(1);

for k = 1:orderSurfPoly
    for kk = 0:k
        idx = k*(k+1)/2 + 1;
        Z_post = Z_post + CoefPoly_post(idx+kk) * ...
            ( (X).^(k-kk)).* ...
            ( (Y).^(kk));
        Z_cornea = Z_cornea + CoefPoly_cornea(idx+kk) * ...
            ( (X).^(k-kk)).* ...
            ( (Y).^(kk));
        Z_work_top = Z_work_top + CoefPoly_work_top(idx+kk) * ...
            ( (X-CenterXY_iris(1)).^(k-kk) ).* ...
            ( (Y-CenterXY_iris(2)).^(kk) );
        Z_work_bot = Z_work_bot + CoefPoly_work_bottom(idx+kk) * ...
            ( (X-CenterXY_iris(1)).^(k-kk) ).* ...
            ( (Y-CenterXY_iris(2)).^(kk) );
    end
end

Z_iris = (CoefPlane_iris(4) - CoefPlane_iris(1)*X - CoefPlane_iris(2)*Y) / ...
    CoefPlane_iris(3);
zCenter_iris  = mean(Z_iris(:));
zCenter_work_bot = griddata(X, Y, Z_work_bot, ...
    CenterXY_iris(1),CenterXY_iris(2),'cubic');
Z_work_bot = Z_work_bot - (zCenter_work_bot - zCenter_iris + dist_iris2post);

%% Polishing trajectory profile
% select trajectory to generate
if strcmp(type, 'raster') == 1 % raster scan
    [~, TrajX, TrajY, ~] = genRasterScan(Pmax, Vmax, radius, nCycle, Ts, plotOpt);
elseif strcmp(type, 'sine') == 1 % sinusoidal scan
    [~, TrajX, TrajY, ~] = genSinusoidalScan(Pmax, Vmax, radius, nCycle, Ts, plotOpt);
elseif strcmp(type, 'lissajous') == 1 % lissajous curve
    [~, TrajX, TrajY, ~] = genLissajous(Pmax, Vmax, radius, nCycle, Ts, plotOpt);
elseif strcmp(type, 'parabolic') == 1 % parabolic on PC
    c  = 0.1;          % curvature of the parabolic [mm]
    Pmax = 12;          % total travel [mm]
    Vmax = 2;          % maximum velocity [mm/s]
    [TrajX, TrajY, ~] = genParabolic(Ts, c, Pmax, Vmax, nCycle, plotOpt);
else
    disp('Trajectory does not exist');
end
% offset to iris center
si = CenterXY_iris;
TrajX = TrajX + si(1);
TrajY = TrajY + si(2);
% project onto structure
TrajZ = griddata(X, Y, Z_post, TrajX, TrajY, 'cubic');
% for multi-depth ILC
TrajZ = TrajZ + dR;

%% plotting
if plotOpt == true
    % downsample pts for plot
    n = round(size(iriss_pcxyz_mm,1) / 6000);
    pts4plot = downsample(iriss_pcxyz_mm, n);
    
    figure(20);
    hpc = scatter3(pts4plot(:,1), pts4plot(:,2), pts4plot(:,3), 0.2, [0 0 0], 'Marker', '.'); hold on;
    set(hpc, 'MarkerEdgeAlpha', 0.8, 'MarkerFaceAlpha', 0);
    hpcsurf = surf(X, Y, Z_post); hold on;
    set(hpcsurf, 'FaceColor', [0.55 0.59 0.82], 'EdgeAlpha', 0, 'FaceAlpha', 0.5);

    
    hpctraj = plot3(TrajX(:), TrajY(:), TrajZ(:), 'r', 'LineWidth', 1.2);
%     legend([hpcsurf, hpc], 'PC surface fit', 'PC data points');
    legend([hpcsurf, hpc, hpctraj], 'PC surface fit', 'PC data points', 'Polishing trajectory');
    grid on; grid minor;
    axis equal;
    xlabel('$^I \hat{X}$ [mm]');
    ylabel('$^I \hat{Y}$ [mm]');
    zlabel('$^I \hat{Z}$ [mm]');
%     ylim([1 10]); xlim([-5 6]); zlim([-16 -10]);
    
    set(gcf, 'Color', 'w');
end

end