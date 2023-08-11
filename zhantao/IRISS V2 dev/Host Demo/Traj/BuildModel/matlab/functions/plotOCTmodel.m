function plotOCTmodel(SDIR, SCAN_NO)
% 2021-09-20 MJG 
% This code loads in allParams.mat and generates a nice 3D plot in {OCT}
% [mm] frame; Note: This code has nothing to do with traj generation. 

% add trailing slash if not specified 
if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end 

% load all data/params used for plotting
load([SDIR 'allParams_' num2str(SCAN_NO, '%04i') '.mat'], ...
    'pupil_pts_mm', ...
    'corn_pts_mm', ...
    'endo_pts_mm', ...
    'iris_pts_mm', ...
    'pupilCenter', ...
    'opticalCenter', ...
    'p_bc', ...
    'eqpts', ...
    'Xdata', ...
    'Ydata', ...
    'Zdata', ...
    'pupilCurvePts', ...
    'surffit_endo'); 

% Initialize Plot 
figure(1); clf;

% Data: Cornea
hc = scatter3(corn_pts_mm(:,1), corn_pts_mm(:,2), corn_pts_mm(:,3), 1, [0.1 0.2 0.8]);
set(hc, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);

% Establish plot parameters 
hold on; grid on; axis equal; 
set(gca, 'zdir', 'reverse'); 
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
title(['Full Eye Model \{O\} [mm] - ' num2str(SCAN_NO, '%04i')]);

% Data: Corneal endothelium points (endo)
he = scatter3(endo_pts_mm(:,1), endo_pts_mm(:,2), endo_pts_mm(:,3), 3, [0 0 0]);
set(he, 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0);

% Surface fit to corneal endothelium 
[xi, yi] = meshgrid(0:0.1:10);
zi = surffit_endo(xi, yi);
TO = triangulation(delaunay(xi, yi), xi(:), yi(:), zi(:));
trimesh(TO, 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.3); 

% Data: Iris
hs = scatter3(iris_pts_mm(:,1), iris_pts_mm(:,2), iris_pts_mm(:,3), 1, [0.8 0.2 0.1]);
set(hs, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);

% Data: Pupil points 
hs = scatter3(pupil_pts_mm(:,1), pupil_pts_mm(:,2), pupil_pts_mm(:,3), 10, [0.2 0.2 1]);
set(hs, 'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', 0);

% Pupil center
plot3(pupilCenter(1), pupilCenter(2), pupilCenter(3), 'g+');

% Optical centerline
cline = [pupilCenter pupilCenter+(3*opticalCenter);
         pupilCenter pupilCenter-(3*opticalCenter)];
plot3([cline(1,1) cline(1,2)], ...
      [cline(2,1) cline(2,2)], ...
      [cline(3,1) cline(3,2)], 'r-', 'LineWidth', 1); 
plot3([cline(4,1) cline(4,2)], ...
      [cline(5,1) cline(5,2)], ...
      [cline(6,1) cline(6,2)], 'r-', 'LineWidth', 1); 

% Pupil 3D circle
plot3(pupilCurvePts(:,1), pupilCurvePts(:,2), pupilCurvePts(:,3), 'k-', 'LineWidth', 1);

% Capsular bag center point 
plot3(p_bc(1), p_bc(2), p_bc(3), 'b+', 'MarkerSize', 10, 'LineWidth', 2);

% Modeled equator points 
plot3(eqpts(:,1), eqpts(:,2), eqpts(:,3), 'b:', 'LineWidth', 1);

% Modeled capsular bag (posterior section)
surf(Xdata, Ydata, Zdata, 'LineStyle', 'none', 'FaceAlpha', 0.3); hold on;
colormap winter;

% Fullscreen the figure window
set(gcf, 'Position', get(0, 'Screensize'));

% Change the default view
view(-45,20);

% Save a .png of this figure 
saveas(gcf, [SDIR 'fullEyeModel' num2str(SCAN_NO) '.png'], 'png');

end