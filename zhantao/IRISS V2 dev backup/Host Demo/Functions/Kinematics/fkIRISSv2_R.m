function [px, py, pz, R] = fkIRISSv2_R(d_DH, ty, joint, armID)
% 2022-11-07 Kevin
% 2022-11-15 Leo, cancel rotAngleX input, use robot2Iriss function to
% change frame instead
% forward kinematics with calibrated DH table
% INPUTS
% > d_DH      : a 4x4 matrix and it is using the regular DH table [mm/rad]
% > ty        : a 2x1 vector for tool calibration [mm/rad]
%               the first element is translation
%               the second element is rotation
% > joint     : a 4x1 array containing the current joint value [deg/mm]
% > armID     : 0 stands for left arm, 1 stands for right arm
% OUTPUTS
% > px        : X Cartesian coordinate under the {IRISS} frame
% > py        : Y Cartesian coordinate under the {IRISS} frame
% > pz        : Z Cartesian coordinate under the {IRISS} frame

% for debugging
%{
SDIR = 'D:\IRISSoft LV2016 beta\Host Demo\';
load([SDIR 'DH_static']);
d_DH = DH_static;
load([SDIR 'ty_static']);
ty = ty_static;
joint = [-68 9 1.5 0];
armID = 0;
[px, py, pz, R] = fkIRISSv2_R(d_DH, ty, joint, armID)
%}
%%%%%%%%%%%%%%

joint([1 2 4]) = deg2rad(joint([1 2 4]));

% ---------- all of the below calculation uses deg as angle unit -----------


% read in encoder values [mm/rad]
theta1 = joint(1);
theta2 = joint(2);
d3 = joint(3);
theta4 = joint(4);

% load standard DH table
ds_dh = d_DH(1,:);
thetas_dh = d_DH(2,:);
as_dh = d_DH(3,:);
alphas_dh = d_DH(4,:);


% convert to modified DH table (shift alpha and a by one)
thetas = thetas_dh + [theta1 theta2 0 theta4]; % 1x4
alphas = [0 alphas_dh]; % 1x5 (shifted)
ds = ds_dh + [0 0 d3 0]; % 1x4
as = [0 as_dh]; % 1x5 (shifted)

% offset = [0 -pi/2 0 0];

Ttemp = eye(4);
for k = 1 : 4
    th = thetas(k); al = alphas(k); d = ds(k); a = as(k);
    ct = cos(th); ca = cos(al);
    st = sin(th); sa = sin(al);
    Tk{k} = [ct    -st   0   a;
          st*ca ct*ca -sa -d*sa;
          st*sa ct*sa ca  d*ca;
          0     0     0   1 ];
    Ttemp = Ttemp * Tk{k};
end
% consider joint 4 separately
TransY_4 = makehgtform('translate', [0 ty(1) 0]);
RotY_4 = makehgtform('yrotate', ty(2));
TransX_4 = makehgtform('translate', [as(5) 0 0]);
RotX_4 = makehgtform('xrotate', alphas(5));
Ttemp = Ttemp * TransY_4*RotY_4*TransX_4*RotX_4;


Ttemp = robot2Iriss(Ttemp,armID);

px = Ttemp(1,4);
py = Ttemp(2,4);
pz = Ttemp(3,4);
R = Ttemp(1:3,1:3);

end
