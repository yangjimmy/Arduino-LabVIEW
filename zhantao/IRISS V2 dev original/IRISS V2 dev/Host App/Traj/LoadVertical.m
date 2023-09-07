function [x, y, z] = LoadVertical(Ts, sp, Pmax, Vmax, nCycle, plotOpt)

% total traveling time
T = Pmax / Vmax;
% initialization
tk = Ts * (0:1:ceil(T/Ts)).';
s = zeros(size(tk));

% timing law
for k = 1:length(tk) 
    s(k) = -tk(k)*Vmax;
end

z = repmat([s; flipud(s)], nCycle, 1) + sp(3);
% x = repmat([tk; flipud(tk)], nCycle, 1) + sp(1);
% y = zeros(length(x), 1) + sp(2);
x = zeros(length(z),1) + sp(1);
y = zeros(length(z),1) + sp(2);

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
