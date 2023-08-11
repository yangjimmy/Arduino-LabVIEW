clc; clear; close all;
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesFontSize',16);
addpath('.\export_fig\');

%% Parameters
Ts      = 0.001; % sampling time [ms]
nCycle  = 3;     % number of cycle
Pmax    = 5;     % maximum travel distance [mm]
Vmax    = 4;     % maximum velocity [mm/s]
radius  = 3;     % the radius of the anatomy [mm]
dR      = -0.5;  % the offset for multiple depths [mm]
PlotOpt = 1;     % plot option

%% Load trajectory
[x, y, z] = LoadRasterScan(Ts, nCycle, Pmax, Vmax, 0, radius, PlotOpt);
% [x_p, y_p, z_p] = LoadRasterScan(Ts, nCycle, Pmax, Vmax, dR, radius, PlotOpt);

%% Trajectory tracking animation
% if PlotOpt
%     xk = x(1); yk = y(1); zk = z(1);
%     marker = plot3(xk, yk, zk, 'ro');
%     marker.XDataSource = 'xk';
%     marker.YDataSource = 'yk';
%     marker.ZDataSource = 'zk';
% 
%     for k = 1:length(x)
%         if mod(k,100) == 1
%             xk = x(k); yk = y(k); zk = z(k);
%             refreshdata;
%             drawnow;
%         end
%     end
% end