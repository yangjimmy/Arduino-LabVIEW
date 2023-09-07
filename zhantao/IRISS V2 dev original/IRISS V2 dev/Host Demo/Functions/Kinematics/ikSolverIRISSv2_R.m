function [joint, ret] = ikSolverIRISSv2_R(armID, px, py, pz, limits, jointInit, R)
%function [joint, ret] = ikSolverIRISSv2(armID, px, py, pz, limits)
% use Matlab lsqnonlin function to solve the inverse kinematics numerically 
% in least sqaure sense with the analytic solution as the initial guess
% Author: Kevin, Leo, Jason
% History: 
% 2022-10-12: initial commit, Kevin
% 2022-11-07: incorporated DH calibration results (buggy), Kevin
% 2022-11-15: change from symbolic tool to least square tool, solve fk unit issue (deg/rad), Leo
% 2023-02-02: add rotational matrix

% for debugging
% SDIR = 'D:\Kevin\IRISS V2 dev\Host Demo\Functions\Kinematics\';
% clear; close all; clc;
% armID = 0;
% % px = -0.012; py = 0.934; pz = -0.356;
% px = 0.6398; py = 8.365; pz = -6.038;
% limits = [-90 40; -45 45; -20 20; -720 720];
% If you want to use Ji's initial guess, jointInit = [-1;-1;-1;-1];

SDIR = 'D:\Kevin\IRISS V2 dev\Host Demo\Functions\Kinematics\';
load([SDIR 'DH_static']);
d_DH = DH_static;
load([SDIR 'ty_static']);
ty = ty_static;

% debug: test using nominal dh value
% load('robot.mat');
% d_DH(1,:) = robot.d;
% d_DH(2,:) = robot.offset;
% d_DH(3,:) = robot.a;
% d_DH(4,:) = robot.alpha;
% ty = [0;0];


%%%%%%%%%%%%%%%




%%  rotation angle definition
ret = 0;

if armID == 0 % left arm (currently being used)
    
elseif armID == 1 % right arm
    
else
    ret = -100;
    joint = [Inf Inf Inf Inf];
    return;
end



%% solve for joint value using least square numerically
% initial guess of joint value from the analytic solutions
if all(jointInit(1:4)==-1)
    jointInit = ikAnSolverIRISSv2(armID,px,py,pz);
    gamma = 0;
else
    gamma = 3;
end
for i=1:4
    if isnan(jointInit(i))
        if i==1
            jointInit(i) = -68;
        else
            jointInit(i) = 0;
        end
    end
end

% lower and upper bound of joint
lb = limits(:,1);
ub = limits(:,2);

% define objective function
%pI = [px;py;pz;R(1,1);R(1,2);R(1,3);R(2,1);R(2,2);R(2,3);R(3,1);R(3,2);R(3,3)]; % position command in iriss frame
%pI = [R(1,1);R(1,2);R(1,3);R(2,1);R(2,2);R(2,3);R(3,1);R(3,2);R(3,3)];
pI = R2XZX(R);
objfunc = @(angles) pI - wrap_fkIRISSv2_R(d_DH, ty, angles, armID);
%objfunc = @(angles) [pI - wrap_fkIRISSv2(d_DH, ty, angles, armID);gamma*(jointInit(1:3)-angles(1:3))/180*pi];

% optimization option
options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt');

% solve for joint value using least square
joint  = lsqnonlin(objfunc ,jointInit,lb,ub,options);

% position error
error = objfunc(joint);


% check if there's a set of solution (meaning error is small)
if norm(error) > 1.0 % error threshold [mm]
    ret = -1;
    return;
end



end





%% support function (only used in this file)
% change the output of fkIRISSv2 into vector form
function p = wrap_fkIRISSv2_R(d_DH, ty, angles, armID)


[px, py, pz, R] = fkIRISSv2_R(d_DH, ty, angles, armID);
%[px, py, pz] = fkIRISSv2(d_DH, ty, angles, armID);

%p = [px;py;pz;R(1,1);R(1,2);R(1,3);R(2,1);R(2,2);R(2,3);R(3,1);R(3,2);R(3,3)];
%p = [R(1,2);R(1,3);R(2,1);R(2,2);R(2,3);R(3,1);R(3,2);R(3,3)];
%R = [-1 0 0;0 0 1;0 1 0]*R;
p = R2XZX(R);
end










