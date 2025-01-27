Array=csvread('read_data_2.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);
figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
hold off
figure()
plot(t,col1)


Array=csvread('read_data_3.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);
figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
hold off
figure()
plot(t,col1)

%%

Array=csvread('read_data_4.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);
figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
hold off
figure()
plot(t,col1)

%%

Array=csvread('read_data_abs.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);
figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
hold off
figure()
plot(t,col1)

figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
hold off

%%

Array=csvread('read_data_delt2.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);
figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
hold off
figure()
plot(t,col1)

figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
hold off

%%
clear
clc
Array=csvread('read_data_abs3.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);
figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
title("absolute, axis 1")
hold off
figure()
plot(t,col1)

figure()
hold on
plot(t,rad2deg(col2*0.005))
plot(t,rad2deg(col2*0.005),'.')
title("absolute, axis 2")
hold off

%%

Array=csvread('read_data_delt3.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);
figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
title("delta, axis 1")
hold off
figure()
plot(t,col1)

figure()
hold on
plot(t,rad2deg(col2*0.005))
plot(t,rad2deg(col2*0.005),'.')
title("delta, axis 2")
hold off

%%
clear
clc
Array=csvread('read_data_abs3.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);
figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
hold off
figure()
plot(t,col1)

figure()
hold on
plot(t,rad2deg(col1*0.005))
plot(t,rad2deg(col1*0.005),'.')
hold off

%%

Array=csvread('read_data_delt4.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);

figure()
hold on
plot(t,rad2deg(col2*0.005))
plot(t,rad2deg(col2*0.005),'.')
title("delta, axis 2")
hold off

%%
clear
clc
Array=csvread('read_data_abs4.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);

figure()
hold on
plot(t,rad2deg(col2*0.005))
plot(t,rad2deg(col2*0.005),'.')
title("abs, axis 2")
hold off

%%
Array=csvread('read_data_delt5.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);

figure()
hold on
plot(t(8000:end),rad2deg(col2(8000:end)*0.005))
plot(t(8000:end),rad2deg(col2(8000:end)*0.005),'.')
title("delta, axis 2")
hold off

Array=csvread('delt_rec2.csv');
col1 = Array(:, 1);
t = 1:1:length(col1);
col2 = Array(:, 2);

figure()
hold on
plot(t,rad2deg(col2*0.005))
plot(t,rad2deg(col2*0.005),'.')
title("delta, axis 2")
hold off

%%
Array=csvread('read_data_abs_sending.csv');
col1 = Array(10:end, 1);
col2 = Array(10:end, 2);
t = Array(10:end, end);
Array=csvread('read_data_abs_filtered.csv');
col1_f = Array(10:end, 1);
col2_f = Array(10:end, 2);
t_f = Array(10:end, end);
%%
figure()
hold on
plot(t_f,col1_f)
%plot(t,col2)
% hold off
% figure()
% hold on
plot(t,col1)
legend("filtered", "not filtered")
xlabel("Time elapsed (s)");
ylabel("Angle (deg)");
hold off

%%
Array=csvread('read_data_abs_sending.csv');
col1 = Array(10:end, 1);
col2 = Array(10:end, 2);
col3 = Array(10:end, 3);

t = Array(10:end, end);
%%
figure()
hold on
plot(t,col3)
xlabel("Time elapsed (s)");
ylabel("mm");
hold off
