function [circleCenter, circleNormal, circleRadius, pupilCurvePts] = fit3Dcircle_v2(xyz)
%fit3Dcircle 2021-09-13 MJG 
%   Fits 3D xyz points with a circle in 3D 
%   INPUTS: xyz ~ list of n x 3 xyz points, any unit [px, mm...]
%   OUTPUTS: should be obvious from the var names...
% Update: v2 (2021-10-05) MJG; force the circleNormal to point upwards
% (towards the cornea) = negative Z direction 

% figure(1); clf;
% plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'k.', 'MarkerSize', 1); 
% hold on; grid on; axis equal;

% find rough center (average) of all points ~= barycenter 
XC = mean(xyz,1);
% plot3(XC(1), XC(2), XC(3), 'r+');

% offset all points by barycenter; rough zero-center 
Y = xyz - XC;
% plot3(Y(:,1), Y(:,2), Y(:,3), 'm.', 'MarkerSize', 1);

% svd 
[~, ~, V] = svd(Y,0);

% circle normal is easy... 
circleNormal = V(:, 3);

% 2021-10-05 MJG v2
% We define "up" as from the pupil pointed anterior-ly (negative Z in
% {OCT}); since this is the basis for a lot of defintions, we need to
% ensure the circleNormal is defined in this way... flip it if it's not
if sign(circleNormal(3)) > 0
    circleNormal = -circleNormal;
end


% basis of the plane through the circle 
Q = V(:, [1 2]);

% project the barycenter-shifted xyz onto the plane...
Y = Y * Q;

% nota
xc = Y(:,1);
yc = Y(:,2);
% plot3(xc, yc, zeros(length(xc),1), 'ko');

% least squares fit to the eqn of the circle 
M = [xc.^2 + yc.^2, -2*xc, -2*yc];
P = M \ ones(size(xc));
a = P(1);
P = P/a;

% radius 
circleRadius = sqrt(P(2)^2 + P(3)^2 + 1/a);
% center 
circleCenter = XC' + Q*P(2:3);
% plot3([circleCenter(1) circleCenter(1)+circleNormal(1)], [circleCenter(2) circleCenter(2)+circleNormal(2)], [circleCenter(3) circleCenter(3)+circleNormal(3)], 'b-');

% return the fit points (for plotting, etc.)
theta = linspace(0, 2*pi);
pupilCurvePts = (circleCenter + circleRadius * Q * [cos(theta); sin(theta)])';
% plot3(fitPoints(:,1), fitPoints(:,2), fitPoints(:,3), 'r-');







end

