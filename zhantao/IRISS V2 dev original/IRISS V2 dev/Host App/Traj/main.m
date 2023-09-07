clc; clear; close all;
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesFontSize',10);

%% Parameters
Ts      = 0.001; % sampling time [ms]
nCycle  = 5;     % number of cycle
Pmax    = 4;     % maximum travel distance [mm]
Vmax    = 4;     % maximum velocity [mm/s]
radius  = 3;     % the radius of the anatomy [mm]
dR      = -0.5;  % the offset for multiple depths [mm]
plotOpt = 1;     % plot option
type    = 'parabolic';     % 0: raster; 1: sine; 2: lissajous
phase   = 'phase1a';
arm = 1; 

%% Load trajectory
if strcmp(phase, 'phase1a') == 1
    centerLoc = [0.5464, -5.0453, -1.388]; 
    circleNormal = [-0.2418,0.1877,0.9522]; 
    pupilRadius = 5.5; 
    rhexisRadius = 4; 
    [x, y, z] = genGrooving(arm, pupilRadius, rhexisRadius, centerLoc, circleNormal);
else
    [x, y, z] = genTrajWithModel(Ts, nCycle, Pmax, Vmax, 0, radius, type, plotOpt);
end
% calculate travel distance
pOld = [0 0 0]; distAll = 0;
for ii = 1 : length(x)
    if ii == 1
        pOld = [x(ii) y(ii) z(ii)];
    end
    pCurr = [x(ii) y(ii) z(ii)];
    dist = norm(pCurr - pOld);
    distAll = distAll + dist;
    
    pOld = pCurr;
end
distAll

%% Trajectory tracking animation
figure(1); clf;
h1 = plot3(x, y, z, 'r', 'LineWidth', 1.2); hold on;
h2 = plot3(0, 0, 0, 'go', 'linewidth', 3);
grid on; grid minor;
axis equal;
xlabel('$^I \hat{X}$ [mm]');
ylabel('$^I \hat{Y}$ [mm]');
zlabel('$^I \hat{Z}$ [mm]');
if plotOpt
    xk = x(1); yk = y(1); zk = z(1);
    marker = plot3(xk, yk, zk, 'ko');
    marker.XDataSource = 'xk';
    marker.YDataSource = 'yk';
    marker.ZDataSource = 'zk';

    for k = 1:length(x)
        if mod(k,100) == 1
            xk = x(k); yk = y(k); zk = z(k);
            refreshdata;
            drawnow;
        end
    end
end
legend([h1 h2], 'Grooving trajectory', 'RCM');