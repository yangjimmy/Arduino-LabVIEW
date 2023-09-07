clc; clear all; close all;

[t, Pdes, Vcmd, Pirr, Pvac, Pac, Pvit] = loadIopData_rev1('KevData8.txt');
figure;
subplot(211)
plot(t,Pdes,'k--','linewidth',2); hold on;
plot(t,Pac,'linewidth',2); hold on;
grid on; grid minor;
xlabel('Time [sec]')
ylabel('IOP [mmHg]')
subplot(212)
plot(t,Vcmd,'linewidth',2)
grid on; grid minor;
xlabel('Time [sec]')
ylabel('Vacuum Command [mmHg]')