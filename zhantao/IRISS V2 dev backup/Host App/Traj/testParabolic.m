clc; clear; close all;

%% parabolic profile
Ts = 0.001;        % sampling time [sec]
sp = [0 0 -3];      % start position [x, y, z] [mm]
c  = 0.1;          % curvature of the parabolic [mm]
Pmax = 12;          % total travel [mm]
Vmax = 2;          % maximum velocity [mm/s]
nCycle = 1;        % repeat motion
[x, y, z] = genParabolic(Ts, c, Pmax, Vmax, nCycle, 1);

xk = x(1); yk = y(1); zk = z(1);
marker = plot3(xk,yk,zk,'ro');
marker.XDataSource = 'xk';
marker.YDataSource = 'yk';
marker.ZDataSource = 'zk';
    
for k = 1:length(x)
    if mod(k,100) == 1
        xk = x(k); yk = y(k); zk = z(k);
        refreshdata;
        drawnow;
    end
end