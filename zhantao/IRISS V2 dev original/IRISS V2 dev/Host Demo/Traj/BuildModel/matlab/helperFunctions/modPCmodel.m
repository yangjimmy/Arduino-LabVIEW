function [Xdata, Ydata, Zdata] = modPCmodel(p_bc, opticalCenter, r_equator)
% 2021-10-04 MJG 
% for plotting; update the PC model based on user input 

% we already have r_equator (it's what we're updating) 
r_post = r_equator / 1.05; 

% generate full ellipsoid, centered at origin, with correctly sized cap bag
% equator radius and posterior (minor axis) radius 
nPts = 100;
[Xpost, Ypost, Zpost] = ellipsoid(0, 0, 0, r_equator, r_equator, r_post, nPts);

% remove the top portion of the ellipsoid since we only want half (the
% posterior part of the cap bag)
bpos = floor(nPts/2); % calc halfway point 
Xpost(1:bpos,:) = [];
Ypost(1:bpos,:) = [];
Zpost(1:bpos,:) = [];

% get the axis b/t (mean) the desired axis (centerline of the pupil) and
% the current axis of the ellipsoid (= [0 0 1], by default)
dirPos = -mean([opticalCenter [0;0;1]], 2);

% get rotation matrix from direction; magnitude is rotation amt
R = rotationVectorToMatrix(deg2rad(180) * dirPos);

% rotate all data by the rotation matrix...
for ii = 1:size(Xpost,1)
    for jj = 1:size(Xpost,2)
        xyz = R * [Xpost(ii,jj); Ypost(ii,jj); Zpost(ii,jj)];
        Xpost(ii,jj) = xyz(1);
        Ypost(ii,jj) = xyz(2);
        Zpost(ii,jj) = xyz(3);
    end
end


% figure(200); clf; 
% spos = surf(Xpost, Ypost, Zpost, 'LineStyle', 'none', 'FaceAlpha', 0.3); 


% center of the PC bag 
midpt = mean([Xpost(1,:)' Ypost(1,:)' Zpost(1,:)'], 1)';

% calc the translational offset 
offset = p_bc - midpt;

% shift everything over
Xdata = Xpost + offset(1);
Ydata = Ypost + offset(2);
Zdata = Zpost + offset(3);



end