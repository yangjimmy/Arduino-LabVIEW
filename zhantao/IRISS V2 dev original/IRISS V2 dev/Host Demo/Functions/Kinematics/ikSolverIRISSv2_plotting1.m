clc;clear;close all;

SDIR = 'D:\Kevin\IRISS V2 dev\Host Demo\Functions\Kinematics\';
load([SDIR 'DH_static']);
d_DH = DH_static;
load([SDIR 'ty_static']);
ty = ty_static;
% ty = [0;0];

armID = 0;
limits = [-68 -4;-26 52;-40 23;-180 180];
limits2 = [-360 360;-360 360;-40 23;-360 360];
%limits = [-68 -4;-15 15;-40 23;-180 180];
%limits = [-90 90;-90 90;-50 50;-180 180];
jointInit = [-68;5;-2;0];

% path='D:\Jason\planned trajectory.txt';
path='D:\Jason\planned trajectory_2.txt';jointInit = [-68;-15;-2;0];
fid = fopen(path,'r');
data = fscanf(fid,'%f');
data = reshape(data,[length(data)/3,3])';

JointAngles = zeros(4,size(data,1));
JointAngles1 = zeros(4,size(data,1));
Position = zeros(3,size(data,1));
Position1 = zeros(3,size(data,1));
jointInit = [-68;5;-2;0];
jointInit1 = [-68;5;-2;0];


lbpos = limits(1:3,1);
ubpos = limits(1:3,2);
boxpts = [lbpos ubpos];
indbox = string(dec2bin(0:7)');
indbox = replace(indbox,"0","0 ");
indbox = replace(indbox,"1","1 ");
indbox = split(indbox);
indbox = round(str2double(indbox(:,1:(end-1)))+1);
boxpts = [boxpts(1,indbox(1,:)); boxpts(2,indbox(2,:)); boxpts(3,indbox(3,:))];
order = [1 2 4 3 7 8 6 5 1 3 7 5 6 2 4 8];
boxpts = boxpts(:,order);

for i=1:size(data,2)
    
    
    
    disp(' ');
    disp(['trajectory point: ' num2str(i)])
    
    
    if i==5
        aa=1;
    end
    
    [joint, ret] = ikSolverIRISSv2(armID, data(1,i), data(2,i), data(3,i), limits, jointInit);
    [joint1, ret] = ikSolverIRISSv2(armID, data(1,i), data(2,i), data(3,i), limits2, jointInit1);
    
    jointInit = joint;
    jointInit1 = joint1;
    
    JointAngles(:,i) = joint;
    JointAngles1(:,i) = joint1;
    
    [px, py, pz] = fkIRISSv2(d_DH, ty, joint, armID);
    [px1, py1, pz1] = fkIRISSv2(d_DH, ty, joint1, armID);
    Position(:,i) = [px;py;pz];
    Position1(:,i) = [px1;py1;pz1];
    
    
    ptind = 28;
    pt = JointAngles(1:3,i);
    pt1 = JointAngles1(1:3,i);
    figure(22);clf; hold on; grid on;
    h(1) = plot3(pt(1),pt(2),pt(3),'ob','DisplayName','with constraint','MarkerSize',20);
    h(2) = plot3(pt1(1),pt1(2),pt1(3),'r*','DisplayName','without constrain','MarkerSize',20);
    
    plot3(JointAngles(1,1:i),JointAngles(2,1:i),JointAngles(3,1:i),'b.');
    plot3(JointAngles1(1,1:i),JointAngles1(2,1:i),JointAngles1(3,1:i),'r.');
    
    h(3) = plot3(boxpts(1,:),boxpts(2,:),boxpts(3,:),'g','DisplayName','joint constraint');
%     xline(limits(1,1)); xline(limits(1,2));
%     yline(limits(2,1)); yline(limits(2,2));
    xlim([-80 200]);
    ylim([-100 60]);
%     zlim([-5 5]);
    xlabel('\theta_1 [deg]');
    ylabel('\theta_2 [deg]');
    zlabel('d_3 [mm]');
    legend(h(1:3))
    view(2)
end

%%
figure;hold on; grid on; axis equal
plot3(Position(1,:),Position(2,:),Position(3,:),'DisplayName','with constraint');
plot3(Position1(1,:),Position1(2,:),Position1(3,:),'DisplayName','without constraint');
plot3(data(1,:),data(2,:),data(3,:),'k--','DisplayName','position command');
legend('show')
xlabel('x [mm]');ylabel('y [mm]');zlabel('z [mm]');


%%
end_index = size(data,2);
%end_index = 100;
figure;
subplot(311);
plot(1:end_index,JointAngles(1,1:end_index),1:end_index,JointAngles1(1,1:end_index));
xlabel('# of point');ylabel('Joint 1 [degree]');
yline(limits(1,1),'r--');yline(limits(1,2),'m--');
legend('With constraints','Without constraints');
xlim([0 100]);

subplot(312);
plot(1:end_index,JointAngles(2,1:end_index),1:end_index,JointAngles1(2,1:end_index));
xlabel('# of point');
ylabel('Joint 2 [degree]');
yline(limits(2,1),'r--');
yline(limits(2,2),'m--');
xlim([0 100]);

subplot(313);
plot(1:end_index,JointAngles(3,1:end_index),1:end_index,JointAngles1(3,1:end_index));
xlabel('# of point');
ylabel('Joint 3 [mm]');%yline(limits(3,1),'r--');yline(limits(3,2),'m--');
xlim([0 100]);
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








