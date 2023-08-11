function [unit_direction, distance] = udir(p1, p2)
%2021-10-05 MJG Calculate unit (normed) direction from point p1 towards
%point p2 and the distance between them 

% vector from p1 to p2 
xdir = p2 - p1;

% Euclidean distance b/t p1 and p2 
distance = norm(xdir);

% unit vector from p1 to p2 
unit_direction = xdir / distance;

end