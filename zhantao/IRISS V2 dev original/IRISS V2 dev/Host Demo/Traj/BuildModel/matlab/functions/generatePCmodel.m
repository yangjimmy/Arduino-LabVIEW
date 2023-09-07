function [p_bc, eqpts, Xdata, Ydata, Zdata, pcfitpts_mm] = generatePCmodel(pupilCenter, opticalCenter, pupilRadius)
%generatePCmodel gen simulated model of bag, 2021-09-20 MJG just from pupil
%radius... 
% NOTE: this is only for hte posterior part of the caps bag; the anterior
% part has been commented out, since we won't be using it... 

% calcs, based on model assumptions
a = 0.45 * pupilRadius;
% r_ant = 1.52 * a; % dist from bag center to AC apex = minor ellipsoid axis of ant part of bag 
r_post = 2.61 * a; % dist from bag center to PP = minor ellipsoid axis of the post part of bag 
r_equator = 1.05 * r_post; % bag equator radius = major ellipsoid axis 

% to get the center of the caps bag, we start at p_eyeCenter and go a 
% distance down (positive) a along c
% TODO: ensure c points in the correct direction; 3d circ fit might not
% guarantee it does 
p_bc = pupilCenter + a * opticalCenter; % center of the capsular bag 

% generate full ellipsoid, centered at origin, with correctly sized cap bag
% equator radius and posterior (minor axis) radius 
nPts = 100;
[Xpost, Ypost, Zpost] = ellipsoid(0, 0, 0, r_equator, r_equator, r_post, nPts);
% do the same for the anterior part of the caps bag 
% [Xant, Yant, Zant] = ellipsoid(0, 0, 0, r_equator, r_equator, r_ant, nPts);

% remove the top portion of the ellipsoid since we only want half (the
% posterior part of the cap bag)
bpos = floor(nPts/2); % calc halfway point 
Xpost(1:bpos,:) = [];
Ypost(1:bpos,:) = [];
Zpost(1:bpos,:) = [];
% do the same for the anterior part, but remove the other half
% bant = ceil(nPts/2)+2;
% Xant(bant:end,:) = [];
% Yant(bant:end,:) = [];
% Zant(bant:end,:) = [];


% plot as surface; 
% note: this is important, as it's the plot's data that we'll be exporting,
% so we have to genreate it this way (by plotting). 
% we use a number >99 since MJG never creates figure windows with IDs > 99;
% we then close this figure at the end of hte script 
figure(200); clf; 
spos = surf(Xpost, Ypost, Zpost, 'LineStyle', 'none', 'FaceAlpha', 0.3); 
% sant = surf(Xant, Yant, Zant, 'LineStyle', 'none', 'FaceAlpha', 0.3); 
% colormap winter

% get the axis b/t (mean) the desired axis (centerline of the pupil) and
% the current axis of the ellipsoid (= [0 0 1], by default)
% Note, rotate() normalizes the direction vector, so no need to do that
% here
dirPos = -mean([opticalCenter [0;0;1]], 2);
% dirAnt = -dirPos;


% now rotate the ellipse by 180° about this average direction 
% note, this updates the plot's XData, etc., as well as updates the plot 
rotate(spos, dirPos, 180);
% same for the ant
% rotate(sant, dirAnt, 180);


% imp pts of cap bag 
midpt = mean([spos.XData(1,:)' spos.YData(1,:)' spos.ZData(1,:)'], 1)';
% post_pole = [spos.XData(end,end) spos.YData(end,end) spos.ZData(end,end)]';
% AC_apex = [sant.XData(1,1) sant.YData(1,1) sant.ZData(1,1)]';




% --- translation 
% apply the translation
% calc the offset 
offset = p_bc - midpt;

% shift everything over; note: this updates the plot as well as the data 
spos.XData = spos.XData + offset(1);
spos.YData = spos.YData + offset(2);
spos.ZData = spos.ZData + offset(3);
% % do the same for the ant pts 
% sant.XData = sant.XData + offset(1);
% sant.YData = sant.YData + offset(2);
% sant.ZData = sant.ZData + offset(3);

% nota, for output 
Xdata = spos.XData;
Ydata = spos.YData;
Zdata = spos.ZData;

% equator points
eqpts = [Xdata(1,:)' Ydata(1,:)' Zdata(1,:)'];

% Mia's code expects poly22 fit coefficients, not the surf fit above 
% To get a good fit, we need to first shave off some of the "close to
% equator" points 
levels2shave = round(bpos/5);
xx = Xdata(levels2shave:end, :);
yy = Ydata(levels2shave:end, :);
zz = Zdata(levels2shave:end, :);

% then rescale and change nota of these variables 
pcfitpts_mm = [xx(:), yy(:), zz(:)];

% fit surface as before 
% surfPC_OCT = fit([pcfitpts(:,1), pcfitpts(:,2)], pcfitpts(:,3), 'poly22');

% 
% %  plot to see 
% figure(1); clf;
% plot3(pcfitpts(:,1), pcfitpts(:,2), pcfitpts(:,3), 'k.'); grid on; hold on;

% 
% % FOR PLOTTING OF PC SURF FIT ONLY: det lims for fit function
% xlims = [min(pcfitpts(:,1)) max(pcfitpts(:,1))];
% ylims = [min(pcfitpts(:,2)) max(pcfitpts(:,2))];
% % get full range
% nn = 50;
% xrange = linspace(xlims(1), xlims(2), nn)';
% yrange = linspace(ylims(1), ylims(2), nn)';
% % then get numbers; TODO: meshgrid better here
% xi = repmat(xrange, nn, 1);
% yi = repelem(yrange, nn);
% 
% 
% zi = surfPC_OCT(xi,yi); 
% T = delaunay(xi,yi); 
% TO = triangulation(T, xi(:), yi(:), zi(:));
% % plot mesh and change color 
% trimesh(TO, 'LineStyle', 'none', 'FaceColor', 'r', 'FaceAlpha', 0.3); 
% set(gca, 'zdir', 'reverse');
% axis equal;



% close the figure window... 
close 200;


end