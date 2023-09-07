%% revision history
% rev1: rename variables
% rev2: remove unused variables and functaionalities

% surface data
orderSurfPoly = 2;                  % order of surface polynomial
CoefPoly_post = ...                 % polynomial coefficients of posterior capsule
    [ -4.7954, 0, -0.8818, 0.0882, 0, 0.0882 ];

CoefPoly_cornea  = ...              % polynomial coefficients of cornea
    [ 1.6977, 0, 0.9009, -0.0901, 0, -0.0901 ];

% iris data
CoefPlane_iris = ...                % iris plane coefficients
    [0, 0, 1, -1.5];
CenterXY_iris = [0, 5];             % iris center x and y coordinates
radiusIris = 4;                     % iris radius
% radiusIris = radius + 1;

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

%% Raster scan profile
% 2021-05-12
% L1 = [59 58 58];
% L2 = [-18 0 11];
% d3 = [6.5 6.7 6.9];
% 2021-05-19
L1 = [45 45 42];
L2 = [-38 -17 -3];
d3 = [7.4 6.5 6.5];
for k = 1 : length(L1)
    [~, pos] = fwd_kmtcs_rev2(90-L1(k), L2(k), d3(k), 0);
    pos_all(k,:) = pos.';
end
% si = [0, 5];
% [~, TrajX, TrajY, ~] = GenRasterScan_v2(Pmax, Vmax, radius, nCycle, Ts, PlotOpt);
% TrajX = TrajX + si(1);
% TrajY = TrajY + si(2);
% TrajZ = griddata(X, Y, Z_work_bot, TrajX, TrajY, 'cubic');
% TrajZ = TrajZ + dR;

%% import d2 data
Ts = 0.001;
PID_d2_DATA_DIR = 'D:\IRISSoft LV2016 beta\ILC Exp Signals\2021-05-10 Multi Depth ILC\Trial 08\PID d2\';
ILC_d2_DATA_DIR = 'D:\IRISSoft LV2016 beta\ILC Exp Signals\2021-05-10 Multi Depth ILC\Trial 08\';
ILC_d2_NAME = 'Iter5_physical.txt';
FF_d2_DATA_DIR  = 'D:\IRISSoft LV2016 beta\ILC Exp Signals\2021-06-23 Joint3 Inversion & FF\d2\';
% PID
filename = [PID_d2_DATA_DIR 'Iter0_Physical.txt'];
[r1_d2, r2_d2, r3_d2, ~, ~, ~, ~, ~, PID_y1_d2, PID_y2_d2, PID_y3_d2, ~] = ImportExpData(filename);
% ILC 
filename = [ILC_d2_DATA_DIR ILC_d2_NAME];
[~, ~, ~, ~, ~, ~, ~, ~, ILC_y1_d2, ILC_y2_d2, ILC_y3_d2, ~] = ImportExpData(filename);
% Feedforward
filename = [FF_d2_DATA_DIR 'Iter0_Physical.txt'];
[~, ~, ~, ~, ~, ~, ~, ~, FF_y1_d2, FF_y2_d2, FF_y3_d2, ~] = ImportExpData(filename);

% forward kinematics
for k = 1 : length(r1_d2)
    [~, pos] = fwd_kmtcs_rev2(90-r1_d2(k), r2_d2(k), r3_d2(k), 0);
    r_d2_pos(k,:) = pos.';
    [~, pos] = fwd_kmtcs_rev2(90-PID_y1_d2(k), PID_y2_d2(k), PID_y3_d2(k), 0);
    PID_d2_pos(k,:) = pos.';
    [~, pos] = fwd_kmtcs_rev2(90-ILC_y1_d2(k), ILC_y2_d2(k), ILC_y3_d2(k), 0);
    ILC_d2_pos(k,:) = pos.';
    [~, pos] = fwd_kmtcs_rev2(90-FF_y1_d2(k), FF_y2_d2(k), FF_y3_d2(k), 0);
    FF_d2_pos(k,:) = pos.';
end

%% plot workspace
figure(2); clf;
set(gca, 'fontsize', 18);
% surf(X-1.5, Y-10, Z_cornea, 'FaceColor', 'r', 'FaceAlpha', 0.2, ...
%     'EdgeColor','none'); hold on;
% surf(X-1.5, Y-10, Z_work_top, 'FaceColor', 'b', 'FaceAlpha', 0.2, ...
%     'EdgeColor','none'); hold on;
% surf(X-1.5, Y-10, Z_work_bot, 'FaceColor', 'b', 'FaceAlpha', 0.2, ...
%     'EdgeColor','none'); hold on;
% surf(X-1.5, Y-10, Z_post, 'FaceColor', 'r', 'FaceAlpha', 0.2, ...
%     'EdgeColor','none'); hold on;
h1 = plot3(r_d2_pos(:,1), r_d2_pos(:,2), -r_d2_pos(:,3), 'k--', 'LineWidth', 1); hold on;
h2 = plot3(PID_d2_pos(:,1), PID_d2_pos(:,2), -PID_d2_pos(:,3), 'LineWidth', 1, 'Color', '#0072BD'); hold on;
h3 = plot3(ILC_d2_pos(:,1), ILC_d2_pos(:,2), -ILC_d2_pos(:,3), 'LineWidth', 1, 'Color', '#D95319'); hold on;
% scatter3(0, 0, 0, 'MarkerFaceColor', '#77AC30', 'LineWidth', 1.5);
legend([h1,h2,h3], 'Reference', 'Without ILC', 'With ILC');
axis equal;
% scatter3(pos_all(1,1), pos_all(1,2), -pos_all(1,3), ...
%     'MarkerEdgeColor', '#0072BD', 'LineWidth', 1.5);
% scatter3(pos_all(2,1), pos_all(2,2), -pos_all(2,3), ...
%     'MarkerEdgeColor', '#D95319', 'LineWidth', 1.5);
% scatter3(pos_all(3,1), pos_all(3,2), -pos_all(3,3), ...
%     'MarkerEdgeColor', '#77AC30', 'LineWidth', 1.5);
% scatter3(-1.5, 0, 0, 'k', 'LineWidth', 2);
legend('PC', 'Reference', 'Without ILC', 'With ILC', 'RCM');
xlabel('X [mm]');
ylabel('Y [mm]');
zlabel('Z [mm]');
grid on; grid minor;



% 2021-09-09 MJG 
% This code takes the plotting outputs .mat of process_ACh and process_PC
% and plots a pretty 3D model of the eye... 
% Note: This has nothing to do with Martin's traj gen code; it's completely
% separate! 
% This code should run completely on its own, loading everything it needs
% from the .mat files.. 

% load the specified directories, etc. 
% load([SDIR 'allparams.mat'], 'refIndex', 'ratio_mm', 'DDIR', 'MDIR', 'SDIR');

SDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\savedData';

% --- 
% add trailing slash if doesn't exist 
if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end 

% load the scan numbers used for this pair 
SCAN_NO_ACh = 38;
SCAN_NO_PC = 39;
% load([SDIR 'SCAN_NO_ACh.mat'], 'SCAN_NO_ACh');
% load([SDIR 'SCAN_NO_PC.mat'], 'SCAN_NO_PC');

% load ACh and PC data points for plotting... 
load([SDIR 'params_ACh_' num2str(SCAN_NO_ACh,'%04i') '.mat']); 
load([SDIR 'params_PC_' num2str(SCAN_NO_PC,'%04i') '.mat']);

% --- Make Plot 

figure(1); clf;
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
xi = repmat(rr, size(rr,1), 1);
yi = repelem(rr, size(rr,1));
zi = surffit_endo(xi,yi); % eval surf model at each value of xi and yi 
T = delaunay(xi,yi); 
TO = triangulation(T, xi(:), yi(:), zi(:));
% plot mesh and change color 
trimesh(TO, 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.3); 

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
pc_pts_mm(:,3) = pc_pts_mm(:,3) + OCTzRelDist;
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
xi = repmat(xrange, nn, 1);
yi = repelem(yrange, nn);

% need to recalculate the surface fit because pc_mm(:,3) has updated 
surfPC_OCT = fit([pc_pts_mm(:,1), pc_pts_mm(:,2)], pc_pts_mm(:,3), 'poly22');
%, 'normalize', 'on');

% eval surf model at each value of xi and yi 
zi = surfPC_OCT(xi,yi); 
T = delaunay(xi,yi); 
TO = triangulation(T, xi(:), yi(:), zi(:));
% plot mesh and change color 
trimesh(TO, 'LineStyle', 'none', 'FaceColor', 'r', 'FaceAlpha', 0.3); 

xlim([0 10]); ylim([0 10]);

% 2021-10-24 Kevin: plot trajectory
% surf(X+5, Y, Z_work_top+10, 'FaceColor', 'b', 'FaceAlpha', 0.2, ...
%     'EdgeColor','none'); hold on;
% TO_work = triangulation(T, xi(:), yi(:), zi(:)-1);
% trimesh(TO_work, 'LineStyle', 'none', 'FaceColor', 'b', 'FaceAlpha', 0.3, 'EdgeColor','none'); 
h1 = plot3(r_d2_pos(:,1)+5, r_d2_pos(:,2)+13.5, r_d2_pos(:,3)+11, 'k--', 'LineWidth', 1); hold on;
h2 = plot3(PID_d2_pos(:,1)+5, PID_d2_pos(:,2)+13.5, PID_d2_pos(:,3)+11, 'LineWidth', 1, 'Color', '#0072BD'); hold on;
h3 = plot3(ILC_d2_pos(:,1)+5, ILC_d2_pos(:,2)+13.5, ILC_d2_pos(:,3)+11, 'LineWidth', 1, 'Color', '#D95319'); hold on;
% scatter3(0, 0, 0, 'MarkerFaceColor', '#77AC30', 'LineWidth', 1.5);
legend([h1,h2,h3], 'Reference', 'Without ILC', 'With ILC');

title(['AC Scan: ' num2str(SCAN_NO_ACh) '; PC Scan: ' num2str(SCAN_NO_PC)]);

% this code automatically fullscreens the figure (if you want that?)
% set(gcf, 'Position', get(0, 'Screensize'));

% saveas(gcf, ['C:\Users\stein\Desktop\2021-09-07 Build Eye Model v2\savedData\fullOutputs\finalPlotAC' num2str(SCAN_NO_ACh) 'PC' num2str(SCAN_NO_PC) '.png'], 'png');

