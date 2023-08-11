function [x,y,z] = ERCMSolverIRISSv2(armID)
%function [joint, ret] = ikSolverIRISSv2(armID, px, py, pz, limits)
% use Matlab lsqnonlin function to solve the inverse kinematics numerically 
% in least sqaure sense with the analytic solution as the initial guess
% Author: Jason

%{
armID = 0;
px = -0.9902; py = 0.1251; pz = -0.0660;
joint1 = -68;joint2 = 7;
limits = [-68 -4;-26 52;-40 23;-360 360];
[joint3, ret] = RCMSolverIRISSv2(armID, px, py, pz, joint1, joint2,limits)
% [px, py, pz] = fkIRISSv2(d_DH, ty, [-68 8.4 10 0], armID)
%}

SDIR = 'D:\Kevin\IRISS V2 dev\Host Demo\Functions\Kinematics\';
load([SDIR 'DH_static']);
d_DH = DH_static;
load([SDIR 'ty_static']);
ty = ty_static;

file = 'D:/Jason/nominal joint angles.txt';
fid = fopen(file,'r');
data = fscanf(fid,'%f');
data = reshape(data,[length(data)/3,3])';
fclose(fid);
%%  rotation angle definition
ret = 0;

if armID == 0 % left arm (currently being used)
    
elseif armID == 1 % right arm
    
else
    ret = -100;
    return;
end

global x1s
global x2s
x1s = [];
x2s = [];
for i=2000:500:length(data)
    [px, py, pz, R] = fkIRISSv2_R(d_DH, ty, [data(:,i);0], armID);
    x1s = [x1s [px;py;pz]];
    x2s = [x2s R(:,3)+[px;py;pz]];
end




%% solve for joint value using least square numerically

A = [];
b = [];
Aeq = [];
beq = [];
lb = [-20 -20 -20];
ub = [20 20 20];
x0 = [0 0 0];
% interior-point sqp sqp-legacy trust-region-reflective active-set
option = optimoptions(@fmincon,'Algorithm','sqp','MaxIterations',10000,'ConstraintTolerance',1e-6,'MaxFunctionEvaluations',100000);
[X,fval] = fmincon(@objfun,x0,A,b,Aeq,beq,lb,ub,[],option);

x=X(1);y=X(2);z=X(3);

end

function f=objfun(x)
    global x1s
    global x2s
    f = 0;
    for i=1:size(x1s,2)
        d = norm(cross(x2s(:,i)-x1s(:,i), x1s(:,i)-[x(1);x(2);x(3)]))/norm(x2s(:,i)-x1s(:,i));
        f = f+d^2;
    end
end



%% support function (only used in this file)
% change the output of fkIRISSv2 into vector form
function p = wrap_fkIRISSv2(d_DH, ty, angles, armID)


[px, py, pz] = fkIRISSv2(d_DH, ty, angles, armID);


p = [px;py;pz];

end