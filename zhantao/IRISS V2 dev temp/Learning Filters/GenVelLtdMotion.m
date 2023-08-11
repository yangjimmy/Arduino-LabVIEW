function [t,s,v] = GenVelLtdMotion(si, L, Vmax, Tdwl, Cycles, Ts, PlotOpt)
%% check input arguments
if nargin < 7
    PlotOpt = true;
end


%% transition time
T = L/Vmax;


%% limited velocity profile
% initialization
tk = Ts*[0:1:ceil(T/Ts)]';
s = zeros(size(tk));

% timing law
for k = 1:length(tk) 
    s(k) = si + Vmax*tk(k);
end

% concatenate reference
s = [s;
     s(end)*ones(ceil(Tdwl/Ts),1);
     flipud(s);
     s(1)*ones(ceil(Tdwl/Ts),1)];

s = repmat(s,Cycles,1);

v = [0; diff(s)/Ts];
a = [0; diff(v)/Ts];

t = Ts*[0:1:length(s)-1]';


%% plotting
if PlotOpt == true
    figure
    subplot(211)
    plot(t,s)
    grid on; grid minor;
    ylabel('Travel [deg]')
    title('Limited Velocity Profile')
    subplot(212)
    plot(t,v); hold on;
    plot([t(1),t(end)], Vmax*[1,1],'r--')
    plot([t(1),t(end)],-Vmax*[1,1],'r--')
    grid on; grid minor;
    xlabel('Time [sec]')
    ylabel('Velocity [deg/s]')
end


end