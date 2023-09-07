function [t, xTotal, yTotal, z] = genLissajous( ...
    Pmax, Vmax, radius, nCycle, Ts, PlotOpt)
%% check input arguments
if nargin < 5
    PlotOpt = true;
end
assert(Pmax < radius*2, ...
    "Travel length must be smaller than the capsule radius");
if Vmax >= 12
    warning("Vmax is high. You might want to decrease the speed");
end

disp('Generating Lissajous curve trajectory ...');

% the space between each cycle
d = Pmax / (2*nCycle);

%% Lissajous curve
tTotal = 15;
t = 0:Ts:tTotal;
a = 3; b = a+1;
% square Lissajous 
% xTotal = (radius-1)*cos(a*t);
% yTotal = (radius-1)*sin(b*t);

% spherical Lissajous
xTotal = (radius-0.5) * sin(b*t) .* cos(a*t);
yTotal = (radius-0.5) * sin(b*t) .* sin(a*t);

%% assign initial and final velocity profile in x direction
vel = diff(xTotal)/Ts;
% initial velocity profile
initVel = vel(1);
dist = Inf;
initEnd = 0.5;
while (dist > radius)
    tSigmoid = 0:Ts:initEnd;
    initVelProf = initVel * sigmf(tSigmoid,[60 tSigmoid(end)*0.5]);
    initEnd = initEnd - Ts;
    distArray = cumsum(initVelProf);
    dist = distArray(end)*Ts;
end

% final velocity profile
finalVel = vel(end);
dist = Inf;
finalEnd = 0.5;
while (dist > radius)
    tSigmoid = 0:Ts:finalEnd;
    finalVelProf = finalVel * fliplr(sigmf(tSigmoid,[60 tSigmoid(end)*0.5]));
    finalEnd = finalEnd - Ts;
    distArray = cumsum(finalVelProf);
    dist = distArray(end)*Ts;
end

% concatenate the trajectory in velocity and remove offset
xVel = [initVelProf diff(xTotal)/Ts finalVelProf];

%% assign initial and final velocity profile in y direction
vel = diff(yTotal)/Ts;
% initial velocity profile
initVel = vel(1);
dist = Inf;
initEnd = 0.5;
while (dist > radius)
    tSigmoid = 0:Ts:initEnd;
    initVelProf = initVel * sigmf(tSigmoid,[60 tSigmoid(end)*0.5]);
    initEnd = initEnd - Ts;
    distArray = cumsum(initVelProf);
    dist = distArray(end)*Ts;
end

% final velocity profile
finalVel = vel(end);
dist = Inf;
finalEnd = 0.5;
while (dist > radius)
    tSigmoid = 0:Ts:finalEnd;
    finalVelProf = finalVel * fliplr(sigmf(tSigmoid,[60 tSigmoid(end)*0.5]));
    finalEnd = finalEnd - Ts;
    distArray = cumsum(finalVelProf);
    dist = distArray(end)*Ts;
end

% concatenate the trajectory in velocity
yVel = [initVelProf diff(yTotal)/Ts finalVelProf];


% calculate final trajectory and remove offset
xOffset = mean(cumsum(xVel)*Ts);
yOffset = mean(cumsum(yVel)*Ts);
xTotal = cumsum(xVel)*Ts - xOffset;
yTotal = cumsum(yVel)*Ts - yOffset;

%% calculate final position, velocity, and acceleration
nTraj = length(yTotal);

z = zeros(length(nTraj), 1);
vel = sqrt(diff(xTotal).^2 + diff(yTotal).^2)/Ts;
t = Ts * (0:length(vel)-1);
acc = diff(vel)/Ts;
tAcc = Ts * (0:length(acc)-1);

%% plotting
if PlotOpt == true
    figure(1); clf;
    subplot(3,1,2)
    plot(t, vel, '-.', 'LineWidth', 1);
    grid on; grid minor;
    xlabel('Time [sec]')
    ylabel('Velocity [mm/s]')
    title('Limited Velocity Profile');
    ylim([min(vel)-0.5 max(vel)+0.5]);
    xlim([0 5]);
    subplot(3,1,3);
    plot(tAcc, acc, '-.', 'LineWidth', 1);
    grid on; grid minor;
    xlabel('Time [sec]')
    ylabel('Acceleration [mm/s$^2$]')
    title('Acceleration Profile');
    ylim([1.1*min(acc) 1.1*max(acc)]);
    xlim([0 5]);
%     subplot(2,3,[1 2 4 5])
    subplot(3,1,1)
    viscircles([0, 0], radius, 'LineStyle', '--', 'Color', '#D95319', ...
        'LineWidth', 1); hold on;
    plot(xTotal, yTotal, '.'); hold on;
    axis([-radius radius -radius radius]);
    axis square; 
    xlabel('x position [mm]');
    ylabel('y position [mm]');
    title('Spherical Lissajous trajectory top view');
    grid on; grid minor;
    set(gcf, 'Position', [50, 50, 200, 600])
end

end