function [px, py, pz] = fkIRISSv2(d_DH, ty, joint, armID)
% 2022-11-07 Kevin
% 2022-11-15 Leo, cancel rotAngleX input, use robot2Iriss function to
% change frame instead
% 2023-02-18 Leo, change mdh convention to dh convention, change
% parameterizatoin of last link from Tz(d)Rz(th)Ty(b)Ry(beta)Tx(a)Rx(alpha) 
% to Tz(d)Rz(th)Tx(a)Rx(alpha)Ty(b)Ry(beta)
% forward kinematics with calibrated DH table
% INPUTS
% > d_DH      : a 4x4 matrix and it is using the regular DH table [mm/rad]
% > ty        : a 2x1 vector for tool calibration [mm/rad]
%               the first element is translation, b
%               the second element is rotation, beta
% > joint     : a 4x1 array containing the current joint value [deg/mm]
% > armID     : 0 stands for left arm, 1 stands for right arm
% OUTPUTS
% > px        : X Cartesian coordinate under the {IRISS} frame
% > py        : Y Cartesian coordinate under the {IRISS} frame
% > pz        : Z Cartesian coordinate under the {IRISS} frame

% for debugging
% SDIR = 'D:\IRISSoft LV2016 beta\Host Demo\';
% load([SDIR 'DH_static']);
% d_DH = DH_static;
% load([SDIR 'ty_static']);
% ty = ty_static;
% joint = [-43.049 18.2061 8.685 40];
% armID = 0;
%%%%%%%%%%%%%%

joint([1 2 4]) = deg2rad(joint([1 2 4]));

% ---------- all of the below calculation uses deg as angle unit -----------


% read in encoder values [mm/deg]
theta1 = joint(1);
theta2 = joint(2);
d3 = joint(3);
theta4 = joint(4);

% load standard DH table
ds_dh = d_DH(1,:);
thetas_dh = d_DH(2,:);
as_dh = d_DH(3,:);
alphas_dh = d_DH(4,:);


% add in joint variable
thetas = thetas_dh + [theta1 theta2 0 theta4]; % 1x4
ds = ds_dh + [0 0 d3 0]; % 1x4
alphas = alphas_dh;
as = as_dh;

% offset = [0 -pi/2 0 0];

Ttemp = eye(4);
for k = 1 : 4
    th = thetas(k); al = alphas(k); d = ds(k); a = as(k);
    ct = cos(th); ca = cos(al);
    st = sin(th); sa = sin(al);
    Tk{k} = [ ct    -st*ca   st*sa     a*ct ; ...
              st    ct*ca    -ct*sa    a*st ; ...
              0     sa       ca        d    ; ...
              0     0        0         1         ];
      
    
    Ttemp = Ttemp * Tk{k};
end

% consider joint 4 separately
TransY_4 = makehgtform('translate', [0 ty(1) 0]);
RotY_4 = makehgtform('yrotate', ty(2));

Ttemp = Ttemp * TransY_4*RotY_4;


Ttemp = robot2Iriss(Ttemp,armID);

px = Ttemp(1,4);
py = Ttemp(2,4);
pz = Ttemp(3,4);

end
