function [center_x, center_y, circRadius] = max_inscribed_circle_v2(pupilBlob)
% 2021-09-24; MJG 
% This code finds the largest circle that can be inscribed within the
% convex hull of a binary image that's fed to it (single positive blob
% present in the input) 

% get convex hull of the input binary blob 
CH = bwconvhull(pupilBlob);

% trace the boundary of the CH 
[B, ~] = bwboundaries(CH); 
edgeImage = false(400);
boundary = B{1};
for jj = 1:size(boundary,1)
   edgeImage(boundary(jj,1), boundary(jj,2)) = true;
end

% mask the pixel distances with the CH; only interested in internal points
intPointDists = CH .* bwdist(edgeImage);

% find the max (peak) point in this image 
[circRadius, rind] = max(intPointDists(:));

% incase of multiple hits, just take one 
% note: some loss of accuracy here; not imp at all
circRadius = circRadius(1);
rind = rind(1);

% mesh out the possible locations 
[Mx, My] = meshgrid(1:400, 1:400);
allPoints = [Mx(:), My(:)]; % nota

% get center points 
center_x = allPoints(rind, 2);
center_y = allPoints(rind, 1);



% --- plot 
% theta = [linspace(0,2*pi) 0];
% 
% figure(1); clf; imshow(pupilBlob); hold on;
% plot(center_y, center_x, 'r+');
% plot(sin(theta)*circRadius + center_y, cos(theta)*circRadius + center_x, 'color','g','LineWidth', 2);
% 
% figure(2); clf; imshow(CH); hold on;
% plot(center_y, center_x, 'r+');
% plot(sin(theta)*circRadius + center_y, cos(theta)*circRadius + center_x, 'color','g','LineWidth', 2);
   

    
end