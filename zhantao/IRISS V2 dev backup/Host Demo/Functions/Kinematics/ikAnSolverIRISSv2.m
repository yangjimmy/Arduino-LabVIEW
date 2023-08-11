function joint = ikAnSolverIRISSv2(armID,px,py,pz)
% use nominal dh value to solve the inverse kinematics analytically
% Author: Kevin, Leo
% joint in [deg/mm], 4x1

% position command in iriss frame
pI = [px;py;pz];

% position command in robot base frame
pb = iriss2robot(pI,armID);

% solve for joint value analytically (assume alpha13 = alpha35 = pi/3)
joint = zeros(4,1);

% solve joint 3
xr = pb(1); yr = pb(2); zr = pb(3);
joint(3) = sqrt(xr^2 + yr^2 + zr^2);

% solve joint 2
aa = -zr + cos(pi/3)*cos(pi/3)*joint(3);
bb = sin(pi/3)*sin(pi/3)*joint(3);
joint(2) = -asin(aa / bb);

% solve joint 1
aa = -xr*tan(pi/3)*sin(joint(2))*cos(pi/3) + xr*sin(pi/3) + yr*tan(pi/3)*cos(joint(2));
bb = -xr*tan(pi/3)*cos(joint(2)) - yr*tan(pi/3)*sin(joint(2))*cos(pi/3) + yr*sin(pi/3);
joint(1) = -atan(aa / bb);

% change unit from rad to deg
joint([1 2 4]) = rad2deg(joint([1 2 4]));


end