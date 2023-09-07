function [x, y, z] = bagModel(p_bc, r_equator, opticalCenter)
% 2021-10-11 MJG 
% trying to simplify the ellipsoid generation... 


%     opticalCenter = p_bc - pupilCenter;
%     opticalCenter = opticalCenter / norm(opticalCenter);


% "direction" of the cap bag 
direction = sign(opticalCenter(3));

% nota from inputs 
xc = p_bc(1);
yc = p_bc(2);
zc = p_bc(3);
xr = r_equator;
yr = xr; 

% calc r_post (zr)
zr = r_equator / 1.05;

% nPts should equal the same as was used to generate the original ellipsoid
nPts = 100;



% angular ranges, full
theta = (-nPts:2:nPts)/nPts * pi;
phi = (-nPts:2:nPts)'/nPts * pi/2;

% all pts 
x = cos(phi) * cos(theta);
y = cos(phi) * sin(theta);
z = sin(phi) * ones(1, nPts+1);

if direction > 0
    to_remove = z < 0;
else
    to_remove = z > 0;
end
to_remove = to_remove(:,1);

% remove those parts... 
x(to_remove,:) = [];
y(to_remove,:) = [];
z(to_remove,:) = [];


% scale, but don't shift yet 
x = xr * x; % + xc;
y = yr * y; % + yc;
z = zr * z; % + zc;


% direction to align bag to... 
dirPos = -mean([opticalCenter [0;0;1]], 2);
% get rotation matrix from direction; magnitude is rotation amt
R = rotationVectorToMatrix(deg2rad(180) * dirPos);


% rotate all data by the rotation matrix...
for ii = 1:size(x,1)
    for jj = 1:size(x,2)
        xyz = R * [x(ii,jj); y(ii,jj); z(ii,jj)];
        x(ii,jj) = xyz(1);
        y(ii,jj) = xyz(2);
        z(ii,jj) = xyz(3);
    end
end

% shift everything over
x = x + xc;
y = y + yc;
z = z + zc;
% Ydata = Ypost + offset(2);
% Zdata = Zpost + offset(3);


% figure(10); clf;
% 	surf(x,y,z); hold on; grid on; axis equal;
%     set(gca,'zdir','reverse');
%     xlabel('x');
%     ylabel('y');
%     zlabel('z');

end