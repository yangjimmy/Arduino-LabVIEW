function [num_lp, num_hp] = design_filter(cutoff_freq)

Ts = 0.01;
Fs = 1/Ts;

StopTime = 5; % seconds 
t = (0:Ts:StopTime)'; % seconds 
F = 5; % Sine wave frequency (hertz) 
x = sin(2*pi*F*t);
x = padarray(x, 1000, "replicate","pre");
t = Ts*(0:length(x)-1);

z  = tf('z',Ts);
nFFT    = 2048;
order_M = 100;
% cutoff_freq = 2;

% design low-pass filter
Fp_M = cutoff_freq;
Rp_M  = 5.7565E-5;  % peak-to-peak ripple
Rst_M = 1E-2;       % stopband attenuation
vec_M = firceqrip(order_M, Fp_M/(Fs/2), [Rp_M Rst_M], 'passedge');
M_filt = dsp.FIRFilter('Numerator',vec_M);
[num_lp, den_lp] = tf(M_filt);
y = filtfilt(num_lp, den_lp, x); 
save('coeff_LP.mat', 'num_lp', 'den_lp');

% figure(1); clf;
% plot(t, x); hold on;
% plot(t, y);
% grid on; grid minor;

% high-pass
vec_M = firceqrip(order_M, Fp_M/(Fs/2), [Rp_M Rst_M], 'high');
M_filt = dsp.FIRFilter('Numerator',vec_M);
[num_hp, den_hp] = tf(M_filt);
y = filtfilt(num_hp, den_hp, x);
save('coeff_HP.mat', 'num_hp', 'den_hp');

% figure(2); clf;
% plot(t, x); hold on;
% plot(t, y);
% grid on; grid minor;

end