function [t, xTotal, yTotal, z] = genRasterScan( ...
    Pmax, Vmax, radius, nCycle, Ts, PlotOpt)
%% check input arguments
if nargin < 5
    PlotOpt = true;
end
assert(Pmax < radius*2, ...
    "Travel length must be smaller than the capsule radius");
if Vmax >= 6
    warning("Vmax is high. You might want to decrease the speed");
end

disp('Generating raster scan trajectory ...');

% the space between each cycle
d = Pmax / (2*nCycle);

%% velocity profile
interval = (0:0.1:10).';
velProf = dsigmf(interval, [5 2.5 5 7.5]);
velProf = velProf - min(velProf); % remove offset
nVelProf = length(velProf);

%% define straight regions
xStraight = cell(2*nCycle+1); yStraight = cell(2*nCycle+1); 
thTotal = zeros(2*nCycle+1);
for k = 1 : 2*nCycle+1
    th = acosd((Pmax/2-(k-1)*d) / radius);
    thTotal(k) = th;
    
    k_odd = mod(k,2) == 1;
    if k_odd
        start_x = radius * sind(th); end_x = radius * sind(-th);
    else
        start_x = -radius * sind(th); end_x = -radius * sind(-th);
    end
    
    % initialize condition
    error = 100;
    N = 1;
    % iteratively assign velocity profile
    while (abs(error) > 1e-4)
        prof = [velProf(1:ceil(nVelProf/2));
                ones(N-nVelProf,1);
                velProf(ceil(nVelProf/2)+1:end)];
        if k_odd
            prof = -prof;
        end
        delta_p = Vmax * prof * Ts;
        travel = cumsum(delta_p);
        error = abs(travel(end)) - abs(end_x - start_x);
        N = N + 1;
        if abs(travel(end)) >= abs(end_x - start_x)
            break;
        end
    end
    % assign the final result to the straight part
    xStraight{k} = cumsum(delta_p) + start_x;
    yStraight{k} = radius * linspace(cosd(th), cosd(-th), N-1).';
end

%% define circular turning regions
xCirc = cell(2*nCycle); yCirc = cell(2*nCycle);
for k = 1 : 2*nCycle
    start_angle = thTotal(k);
    end_angle = thTotal(k+1);
    
    % initialize condition
    error = 100;
    N = 1;
    % iteratively assign velocity profile
    while (abs(error) > 1e-4)
        prof = [velProf(1:ceil(nVelProf/2));
                ones(N-nVelProf,1);
                velProf(ceil(nVelProf/2)+1:end)];
        delta_a = (Vmax/radius) * prof * Ts * (180/pi);
        travel = cumsum(delta_a);
        error = abs(travel(end)) - abs(end_angle - start_angle);
        N = N + 1;
        if abs(travel(end)) >= abs(end_angle - start_angle)
            break;
        end
    end       
    a = cumsum(delta_a) + start_angle;
    % assign the result to the circular part
    if mod(k,2) == 1
        xCirc{k} = -sind(a) * radius;
    else
        xCirc{k} = sind(a) * radius;
    end
    yCirc{k} = cosd(a) * radius;
end

%% concatenate all subsections
count = 1;
for k = 1 : length(xStraight)
    % straight region
    if k <= length(xStraight)
        len = length(xStraight{k});
        if k == 1
            offset_x = 0;
            offset_y = 0;
        else
            offset_x = last_posit_x - xStraight{k}(1);
            offset_y = last_posit_y - yStraight{k}(1);
        end
        xTotal(count:count+len-1) = xStraight{k} + offset_x;
        yTotal(count:count+len-1) = yStraight{k} + offset_y;
        count = count + len;
    end
    last_posit_x = xTotal(end);
    last_posit_y = yTotal(end);
    % circular region
    if k <= length(yCirc)
        len = length(yCirc{k});
        offset_x = last_posit_x - xCirc{k}(1);
        offset_y = last_posit_y - yCirc{k}(1);
        xTotal(count:count+len-1) = xCirc{k} + offset_x;
        yTotal(count:count+len-1) = yCirc{k} + offset_y;
        count = count + len;
    end 
    last_posit_x = xTotal(end);
    last_posit_y = yTotal(end);

end
% statistics
nTraj = length(xTotal);
z = zeros(length(nTraj), 1);
vel = sqrt(diff(xTotal).^2 + diff(yTotal).^2)/Ts;
t = Ts * (0:length(vel)-1);
acc = diff(vel)/Ts;
tAcc = Ts * (0:length(acc)-1);

%% plotting
if PlotOpt == true
    figure(1);
    subplot(2,3,3)
    plot(t, vel, '-.', 'LineWidth', 1);
    grid on; grid minor;
    xlabel('Time [sec]')
    ylabel('Velocity [mm/s]')
    title('Limited Velocity Profile');
    ylim([-0.5 Vmax+0.5]);
    subplot(2,3,6);
    plot(tAcc, acc, '-.', 'LineWidth', 1);
    grid on; grid minor;
    xlabel('Time [sec]')
    ylabel('Acceleration [mm/s$^2$]')
    title('Acceleration Profile');
    ylim([1.1*min(acc) 1.1*max(acc)]);
    subplot(2,3,[1 2 4 5])
    viscircles([0, 0], radius, 'LineStyle', '--', 'Color', '#D95319', ...
        'LineWidth', 1); hold on;
    plot(xTotal, yTotal, '.'); hold on;
    axis([-radius radius -radius radius]);
    axis square; 
    xlabel('x position [mm]');
    ylabel('y position [mm]');
    title('Raster scan trajectory top view');
    grid on; grid minor;
end

end