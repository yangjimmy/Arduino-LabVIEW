clc; clear; close all;

%% 
jointID = 1;
if jointID == 1
    length_hF = 3000;
    PadLength = 1000;
elseif jointID == 2
    length_hF = 6000;
    PadLength = 3000;
else
    length_hF = 2000;
    PadLength = 1000;
end
nPrvw = PadLength + 1;
PadLength = 3000;


%% Trapezoidal profile
ts = 0.001;
si = 0;             % start position [deg]
L = 20;             % total travel [deg]
Vmax = 5;           % maxiumum velocity [deg/s]
Tdwl = 1;           % dwell time when reach s = si + L
Cycles = 3;         % repeat motion
% PadLength = 1000;   % padding at the beginning and the end

% Smoothened profile
[~,s,~] = GenVelLtdMotion(si, L, Vmax, Tdwl, Cycles, ts, 0);
s = padarray(s, PadLength, 'pre', 'replicate');
n_traj = numel(s);
t = ts * (0:n_traj-1).';

%% load filters
load(strcat('G',num2str(jointID),'.mat'));
h_G = h_G_all(:,1);
length_hG = length(h_G);

load(strcat('F',num2str(jointID),'_filter.mat'));

%%
q_des = s;
% Gu = filter(h_G, 1, padarray(q_des, nPrvw, 'both', 'replicate'));
% Gu = Gu(nPrvw+1:nPrvw+length(q_des));
Gu = filter(h_G,1,q_des);

%% Apply the learning filter
q_des = s;
uFF = filter(h_F, 1, padarray(q_des, nPrvw, 'post', 'replicate'));
uFF = uFF(nPrvw+1:nPrvw+length(q_des));

FGq_des = filter(h_G,1,uFF);

figure;
colorOrder = get(gca,'ColorOrder');
plot(t, q_des, 'k--', 'LineWidth', 2); hold on;
plot(t, uFF, 'color',colorOrder(1,:),'LineWidth', 1); hold on;
plot(t, FGq_des, 'color',colorOrder(2,:),'LineWidth', 1); hold on;
ylim([-5 25]);
legend('r', 'u', 'y');
xlabel('Time [sec]');
ylabel('Position [deg]');  
% set(gca, 'color', 'none');
grid on; grid minor;
