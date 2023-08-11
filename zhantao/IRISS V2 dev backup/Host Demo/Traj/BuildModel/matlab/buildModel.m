function buildModel
% 2021-08-25 MJG 
% This code takes the plotting outputs .mat of process_ACh and process_PC
% and generates a 3D plot of the eye and model 

% specify where the .mat files were saved (by the processVSCAN function)
SDIR = 'D:\IRISSoft LV2016 beta\Host Demo\Traj\BuildModel\matlab\savedData';

% specify the number of points to show
% less points will plot faster but makes the anatomy look sparse 
numPts_in_corn = 50000;
numPts_in_iris = 40000;
numPts_in_endo = 100000;

% --- 

% Add trailing slash to SDIR if it wasn't specified by the user
if SDIR(end) ~= filesep; SDIR(end+1) = filesep; end 

% load ACh and PC data points for plotting, overwriting any previous vals
load([SDIR 'data_plotACh.mat']);
load([SDIR 'data_plotPC.mat']);

% ensure the number of points we want to display actually exist
% if so, then downsample as intended
% else, use however many points are actually available;
% > for cornea 
if size(corn_xyz_mm,1) > numPts_in_corn
    corn_xyz_red = corn_xyz_mm(randperm(size(corn_xyz_mm,1), numPts_in_corn)',:);
else
    corn_xyz_red = corn_xyz_mm;
end
% > for iris 
if size(iris_xyz_mm,1) > numPts_in_iris
    iris_xyz_red = iris_xyz_mm(randperm(size(iris_xyz_mm,1), numPts_in_iris)',:);
else
    iris_xyz_red = iris_xyz_mm;
end
% > for endothelium (endo)
if size(endo_xyz_org_mm,1) > numPts_in_endo
    endo_xyz_org = endo_xyz_org_mm(randperm(size(endo_xyz_org_mm,1), numPts_in_endo)',:);
else
    endo_xyz_org = endo_xyz_org_mm;
end

% --- BEGIN PLOTTING --- % 

figure(1); clf;
% plot cornea  
hc = scatter3(corn_xyz_red(:,1), corn_xyz_red(:,2), corn_xyz_red(:,3), 1, [0.1 0.2 0.8]);
set(hc, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);
% plot params
hold on; grid on; axis equal; 
set(gca, 'zdir', 'reverse'); 
xlabel('x [mm]'); ylabel('y [mm]'); zlabel('z [mm]');
xlim([0 10]); ylim([0 10]); zlim([0 9.4]); 
% plot endo pts 
he = scatter3(endo_xyz_org(:,1), endo_xyz_org(:,2), endo_xyz_org(:,3), 3, [0 0 0]);
set(he, 'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0);

% plot surface fit of endo 
rr = (0:0.1:10)'; % range of points 
xi = repmat(rr, size(rr,1), 1);
yi = repelem(rr, size(rr,1));
zi = surffit(xi,yi); % eval surf model at each value of xi and yi 
T = delaunay(xi,yi); 
TO = triangulation(T, xi(:), yi(:), zi(:));
% plot mesh and change color 
trimesh(TO, 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.3); 

% plot iris data 
hs = scatter3(iris_xyz_red(:,1), iris_xyz_red(:,2), iris_xyz_red(:,3), 1, [0.8 0.2 0.1]);
set(hs, 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0);

% plot pupil points that were used in the circle fit 
hs = scatter3(pupil_mm(:,1), pupil_mm(:,2), pupil_mm(:,3), 10, [0.2 0.2 1]);
set(hs, 'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', 0);

% plot pupil center 
plot3(centerLoc(1), centerLoc(2), centerLoc(3), 'g+');

% plot pupil "optical center" line 
emm = 4; % [mm] distance up&down to extend line
plot3([centerLoc(1) centerLoc(1)+emm*circleNormal(1)], ...
      [centerLoc(2) centerLoc(2)+emm*circleNormal(2)], ...
      [centerLoc(3) centerLoc(3)+emm*circleNormal(3)], 'r-', 'LineWidth', 1); 
plot3([centerLoc(1) centerLoc(1)-emm*circleNormal(1)], ...
      [centerLoc(2) centerLoc(2)-emm*circleNormal(2)], ...
      [centerLoc(3) centerLoc(3)-emm*circleNormal(3)], 'r-', 'LineWidth', 1); 

% use 3rd party function to plot the circle 
circle_3D(pupilRadius, centerLoc, circleNormal);


% --- plotting PC ---

% calculate relative distance that the OCT moved 
OCTzRelDist = OCTz_ACh - OCTz_PC; 

% then shift all the Z data pts in this scan down by that much 
pc_xyz_full_mm(:,3) = pc_xyz_full_mm(:,3) + OCTzRelDist;
pc_mm(:,3) = pc_mm(:,3) + OCTzRelDist;

% full PC/lens data points 
plot3(pc_xyz_full_mm(:,1), pc_xyz_full_mm(:,2), pc_xyz_full_mm(:,3), 'k.', 'MarkerSize', 1); 

% just the PC pts (used in surface fit) 
plot3(pc_mm(:,1), pc_mm(:,2), pc_mm(:,3), 'r.', 'MarkerSize', 1);

% plot surface fit of PC 
% det range of x and y... don't want it to extend too large across the plot
% (will look really bad)
padding = 1; % [mm] 
xlims = [min(pc_mm(:,1))-padding max(pc_mm(:,1))+padding];
ylims = [min(pc_mm(:,2))-padding max(pc_mm(:,2))+padding];
% get full range
nn = 20;
xrange = linspace(xlims(1), xlims(2), nn)';
yrange = linspace(ylims(1), ylims(2), nn)';
% then get numbers 
xi = repmat(xrange, nn, 1);
yi = repelem(yrange, nn);

% need to recalculate the surface fit because pc_mm(:,3) has updated from
% the pc_mm data saved in the .mat file that was loaded; FIXME
surfPC_OCT = fit([pc_mm(:,1), pc_mm(:,2)], pc_mm(:,3), 'poly22', 'normalize', 'on');

% eval surf model at each value of xi and yi 
zi = surfPC_OCT(xi,yi); 
T = delaunay(xi,yi); 
TO = triangulation(T, xi(:), yi(:), zi(:));
% plot mesh and change color 
trimesh(TO, 'LineStyle', 'none', 'FaceColor', 'r', 'FaceAlpha', 0.3); 

% force limits again
xlim([0 10]); ylim([0 10]);

end % fx