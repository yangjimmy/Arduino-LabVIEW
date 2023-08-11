function [joint3, ret] = RCMSolverIRISSv2(armID, px, py, pz, joint1, joint2,limits)
%function [joint, ret] = ikSolverIRISSv2(armID, px, py, pz, limits)
% use Matlab lsqnonlin function to solve the inverse kinematics numerically 
% in least sqaure sense with the analytic solution as the initial guess
% Author: Jason
% based on codes from Kevin and Leo

%{
armID = 0;
px = 1.2675; py = 2.7894; pz = -2.3711;
joint1 = -68;joint2 = 7;
limits = [-68 -4;-26 52;-40 23;-360 360];
[joint3, ret] = RCMSolverIRISSv2(armID, px, py, pz, joint1, joint2,limits)
% [px, py, pz] = fkIRISSv2(d_DH, ty, [-68 8.4 10 0], armID)
%}
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
debug = false;


%%%%%%%%%%%%%%%




%%  rotation angle definition
ret = 0;

if armID == 0 % left arm (currently being used)
    
elseif armID == 1 % right arm
    
else
    ret = -100;
    return;
end



%% solve for joint value using least square numerically

% lower and upper bound of joint
lb = limits(3,1);
ub = limits(3,2);

% define objective function
pI = [px;py;pz]; % position of effective RCM
objfunc = @(joint3) pI - wrap_fkIRISSv2(d_DH, ty, [joint1 joint2 joint3 0], armID);

% optimization option
options = optimoptions(@lsqnonlin,'Algorithm','levenberg-marquardt');
%options.OptimalityTolerance = 0;options.FunctionTolerance = 0;options.StepTolerance = 0;
% solve for joint value using least square
[joint3,resnorm,residual,exitflag,output,lambda,J]  = lsqnonlin(objfunc ,0,lb,ub,options);


% position error
error = objfunc(joint3);


if debug
    
    disp(['residual error norm: ' num2str(norm(residual))]);
    
    
    Js =J./vecnorm(J);
    [U,S,V] = svd(Js);
    
    
    
end



% check if there's a set of solution (meaning error is small)
if norm(error) > 1.0 % error threshold [mm]
    ret = -1;
    return;
end





end





%% support function (only used in this file)
% change the output of fkIRISSv2 into vector form
function p = wrap_fkIRISSv2(d_DH, ty, angles, armID)


[px, py, pz] = fkIRISSv2(d_DH, ty, angles, armID);


p = [px;py;pz];

end