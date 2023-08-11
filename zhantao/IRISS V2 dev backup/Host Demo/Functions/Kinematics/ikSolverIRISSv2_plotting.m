clc;clear;close all;

SDIR = 'D:\Kevin\IRISS V2 dev\Host Demo\Functions\Kinematics\';
load([SDIR 'DH_static']);
d_DH = DH_static;
load([SDIR 'ty_static']);
ty = ty_static;
% ty = [0;0];

armID = 0;
limits = [-68 -4;-26 52;-40 23;-180 180];
%limits = [-68 -4;-15 15;-40 23;-180 180];
%limits = [-90 90;-90 90;-50 50;-180 180];
jointInit = [-68;12;-1;0];

path='D:\Jason\planned trajectory.txt';
%path='D:\Jason\planned trajectory_2.txt';
fid = fopen(path,'r');
data = fscanf(fid,'%f');
data = reshape(data,[length(data)/3,3])';
JointAngles = zeros(4,size(data,1));
Position = zeros(3,size(data,1));
for i=1:size(data,2)
    [joint, ret] = ikSolverIRISSv2(armID, data(1,i), data(2,i), data(3,i), limits, jointInit);
    jointInit = joint;
    JointAngles(:,i) = joint;
    [px, py, pz] = fkIRISSv2(d_DH, ty, joint, armID);
    Position(:,i) = [px;py;pz];
    if i==28
        aa=1;
    end
end
%%
limits2 = [-180 180;-180 180;-40 23;-180 180];
jointInit = [-68;12;-1;0];
JointAngles1 = zeros(4,size(data,1));
Position1 = zeros(3,size(data,1));
for i=1:size(data,2)
    [joint, ret] = ikSolverIRISSv2(armID, data(1,i), data(2,i), data(3,i), limits2, jointInit);
    jointInit = joint;
    JointAngles1(:,i) = joint;
    [px, py, pz] = fkIRISSv2(d_DH, ty, joint, armID);
    Position1(:,i) = [px;py;pz];
    if i==28
        aa=1;
    end
end
%%
figure;plot3(data(1,:),data(2,:),data(3,:));hold on
plot3(Position(1,:),Position(2,:),Position(3,:));hold off
xlabel('x [mm]');ylabel('y [mm]');zlabel('z [mm]');axis equal
%%
end_index = size(data,2);
%end_index = 100;
figure;
subplot(311);plot(1:end_index,JointAngles(1,1:end_index),1:end_index,JointAngles1(1,1:end_index));xlabel('# of point');ylabel('Joint 1 [degree]');yline(limits(1,1),'r--');yline(limits(1,2),'m--');legend('With constraints','Without constraints');
subplot(312);plot(1:end_index,JointAngles(2,1:end_index),1:end_index,JointAngles1(2,1:end_index));xlabel('# of point');ylabel('Joint 2 [degree]');yline(limits(2,1),'r--');yline(limits(2,2),'m--');
subplot(313);plot(1:end_index,JointAngles(3,1:end_index),1:end_index,JointAngles1(3,1:end_index));xlabel('# of point');ylabel('Joint 3 [mm]');%yline(limits(3,1),'r--');yline(limits(3,2),'m--');
%%
error = data-Position;error_ = sqrt(sum(error.^2,1));
error1 = data-Position1;error1_ = sqrt(sum(error1.^2,1));



figure;hold on; grid on;
plot(1:end_index,error_(1:end_index),1:end_index,error1_(1:end_index));
title('Position Error magnitude');legend('With constraints','Without constraints');
set(gca, 'YScale', 'log')
xlabel('# of points'); ylabel('position error [mm]');
log_min_e = floor(log10(min([error_ error1_])))-1;
log_max_e = ceil(log10(max([error_ error1_])))+1;
ytic = 10.^(log_min_e:2:log_max_e);
yticks(ytic);
ax = gca;
ax.YAxis.MinorTickValues = 10.^(log_min_e:1:log_max_e);


figure;
subplot(311);plot(1:end_index,error(1,1:end_index),1:end_index,error1(1,1:end_index));xlabel('# of point');ylabel('x [mm]');title('Position Error');legend('With constraints','Without constraints');
subplot(312);plot(1:end_index,error(2,1:end_index),1:end_index,error1(2,1:end_index));xlabel('# of point');ylabel('y [mm]');
subplot(313);plot(1:end_index,error(3,1:end_index),1:end_index,error1(3,1:end_index));xlabel('# of point');ylabel('z [mm]');


ptind = 28;
pt = JointAngles(1:2,ptind);
pt1 = JointAngles1(1:2,ptind);
figure(); hold on; grid on; axis equal;
plot(pt(1),pt(2),'o');
plot(pt1(1),pt1(2),'x');
xline(limits(1,1)); xline(limits(1,2));
yline(limits(2,1)); yline(limits(2,2));





