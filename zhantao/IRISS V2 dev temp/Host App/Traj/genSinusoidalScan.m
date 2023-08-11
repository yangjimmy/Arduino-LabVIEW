function [t, xTotal, yTotal, z] = genSinusoidalScan( ...
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

disp('Generating sinusoidal scan trajectory ...');

% the space between each cycle
d = Pmax / (2*nCycle);

%% Damped sine wave
yTotal = -Pmax*0.55:0.0005:Pmax*0.55;

maxDist = sqrt(radius^2 - yTotal.^2);
xTotal = maxDist .*(sin(yTotal*pi*2));

yTotal = yTotal();
% xTotal = fliplr(xTotal);
% yTotal = fliplr(yTotal);

%% assign initial and final velocity profile
assignVelocity = 0;
if assignVelocity
    vel = diff(xTotal)/Ts;
    pos = sqrt(xTotal.^2 + yTotal.^2);

    % initial velocity profile
    initVel = vel(1);
    initPos = pos(1);
    initDist = Inf;
    initEnd = 0.5;
    while (initDist > initPos)
        tSigmoid = 0:Ts:initEnd;
        initVelProf = initVel * sigmf(tSigmoid,[30 tSigmoid(end)*0.5]);
        initEnd = initEnd - Ts;
        distArray = cumsum(initVelProf);
        initDist = distArray(end)*Ts;
    end

    % final velocity profile
    finalVel = vel(end);
    finalPos = pos(end);
    finalDist = Inf;
    finalEnd = 0.5;
    while (finalDist > finalPos)
        tSigmoid = 0:Ts:finalEnd;
        finalVelProf = finalVel * fliplr(sigmf(tSigmoid,[30 tSigmoid(end)*0.5]));
        finalEnd = finalEnd - Ts;
        distArray = cumsum(finalVelProf);
        finalDist = distArray(end)*Ts;
    end

    % concatenate the trajectory in velocity and remove offset
    xOffset = xTotal(1) - initDist;
    yOffset = yTotal(1) - 0;
    nInitVelPts = length(initVelProf);
    nFinalVelPts = length(finalVelProf);
    
    yVel = padarray(diff(yTotal)/Ts, [0 nInitVelPts], 'replicate', 'pre');
    yVel = padarray(yVel, [0 nFinalVelPts], 'replicate', 'post');
    xVel = [initVelProf diff(xTotal)/Ts finalVelProf];

    xTotal = cumsum(xVel)*Ts + xOffset;
    yTotal = cumsum(yVel)*Ts + yOffset;
end
%% calculate final position, velocity, and acceleration
nTraj = length(yTotal);

z = zeros(length(nTraj), 1);
vel = sqrt(diff(xTotal).^2 + diff(yTotal).^2)/Ts;
t = Ts * (0:length(vel)-1);
acc = diff(vel)/Ts;
tAcc = Ts * (0:length(acc)-1);

%% plotting
if PlotOpt == true
    figure(1);
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
    title('Sinusoidal scan trajectory');
    grid on; grid minor;
    set(gcf, 'Position', [50, 50, 200, 600])
end

end