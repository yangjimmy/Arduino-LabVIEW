function [xyz, j5Pos] = genIOLInsertion(totalTime)
% 2022-07-11 Kevin: initial example trajectory for IOL insertion

% inputs to the function
startPt = [0 6 -2]';
middlePt = [0 8 -4]';
endPt = [0 10 -4]';
plotOpt = 1;
Ts = 0.001;

% specify joint 5 profile
mm2deg = 720;
j5Ready_mm = 80;
j5Max_mm = 125; % 110
j5Ready = j5Ready_mm * mm2deg;
j5Max = j5Max_mm * mm2deg;

% define time points
forwardTime = totalTime/4;
j5RetractTime = (forwardTime+totalTime)/2;

% use waypoints to create trajectory
wpts = [startPt middlePt endPt middlePt startPt];
tpts = [0 forwardTime/2 forwardTime j5RetractTime totalTime];
tvec = 0:Ts:totalTime;
xyz = cubicpolytraj(wpts, tpts, tvec);

j5Wpts = [70 j5Ready j5Max 70];
tpts = [0 forwardTime j5RetractTime totalTime];
[j5Pos, ~, ~, ~] = cubicpolytraj(j5Wpts, tpts, tvec);

% padding in the beginning
padding = 3000;
xyz = padarray(xyz, [0 padding], 'replicate', 'pre');

xyzPos = vecnorm(xyz);
xyzVel = diff(xyzPos)/Ts;

if plotOpt
    figure(211); clf;
    c = get(gca,'ColorOrder');
    tvec = Ts*(0:length(j5Pos)-1);
    subplot(211);
    plot(tvec, j5Pos/mm2deg, 'linewidth', 1.2);
    grid on; grid minor;
    xlabel('Time [sec]'); ylabel('Position [mm]');
    subplot(212);
    j5Vel = [0 diff(j5Pos)/mm2deg]/Ts;
    plot(tvec, j5Vel, 'linewidth', 1.2);
    grid on; grid minor;
    xlabel('Time [sec]'); ylabel('Velocity [mm/s]');
    
    figure(111); clf;
    plot3(wpts(1,:),wpts(2,:),wpts(3,:),'x--','linewidth',1,'color',c(1,:)); hold on;
    plot3(xyz(1,:), xyz(2,:), xyz(3,:),'linewidth',1.2,'color',c(2,:));
    plot3(0, 0, 0, 'o','linewidth',1.2, 'color',c(5,:));
    legend('Waypoints', 'Trajectory', 'RCM');
    xlabel('X [mm]'); ylabel('Y [mm]'); zlabel('Z [mm]');
    axis equal;
    grid on; grid minor;

    figure(311); clf;
    c = get(gca,'ColorOrder');
    tvec = Ts*(0:length(xyz)-1);
    subplot(211);
    plot(tvec, xyzPos, 'linewidth', 1.2);
    grid on; grid minor;
    xlabel('Time [sec]'); ylabel('Position [mm]');
    subplot(212);
    tvec = Ts*(0:length(xyzVel)-1);
    plot(tvec, xyzVel, 'linewidth', 1.2);
    grid on; grid minor;
    xlabel('Time [sec]'); ylabel('Velocity [mm/s]');
end

end