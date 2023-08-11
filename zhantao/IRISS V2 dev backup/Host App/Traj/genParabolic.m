function [x, y, z] = genParabolic(Ts, c, Pmax, Vmax, nCycle, plotOpt)

% total traveling time
T = Pmax / Vmax;
% initialization
tk = Ts * (0:1:ceil(T/Ts)).' - T/2;
s = zeros(size(tk));

% timing law
for k = 1:length(tk) 
    s(k) = c * tk(k)^2;
end

z = repmat([s; flipud(s)], nCycle, 1)';
x = repmat([tk; flipud(tk)], nCycle, 1)';
y = zeros(length(x), 1)';

%% plot trajectory
if plotOpt == true
    figure;
    plot3(x, y, z, 'k'); hold on
    xlabel('x[mm]');
    ylabel('y[mm]');
    zlabel('z[mm]');
    grid on; grid minor;
    axis equal
end
