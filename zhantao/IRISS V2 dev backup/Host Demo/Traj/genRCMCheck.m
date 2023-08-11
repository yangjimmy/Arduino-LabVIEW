function [j1Pos, j2Pos, j3Pos, j4Pos, j5Pos] = genRCMCheck(totalTime)
% 2022-07-13 Kevin: generate joint rotation trajectory for rcm check

jointLimits = [-68 -4; -35 35; 0 0; 0 0; 0 0];
Ts = 0.001;
padding = 1000;

% use waypoints to create trajectory
wpts = [jointLimits(1,1) jointLimits(1,2) jointLimits(1,1)];
tpts = [0 totalTime/2 totalTime];
tvec = 0:Ts:totalTime;
j1Pos = cubicpolytraj(wpts, tpts, tvec);
j1Pos = padarray(j1Pos, [0 padding], 'replicate', 'pre');

wpts = [jointLimits(2,2) jointLimits(2,1) jointLimits(2,2) jointLimits(2,1) jointLimits(2,2)];
tpts = [0 totalTime/4 totalTime/2 3*totalTime/4 totalTime];
tvec = 0:Ts:totalTime;
j2Pos = cubicpolytraj(wpts, tpts, tvec);
j2Pos = padarray(j2Pos, [0 padding], 'replicate', 'pre');

wpts = [jointLimits(3,1) jointLimits(3,2) jointLimits(3,1)];
tpts = [0 totalTime/2 totalTime];
tvec = 0:Ts:totalTime;
j3Pos = cubicpolytraj(wpts, tpts, tvec);
j3Pos = padarray(j3Pos, [0 padding], 'replicate', 'pre');

wpts = [jointLimits(4,1) jointLimits(4,2) jointLimits(4,1)];
tpts = [0 totalTime/2 totalTime];
tvec = 0:Ts:totalTime;
j4Pos = cubicpolytraj(wpts, tpts, tvec);
j4Pos = padarray(j4Pos, [0 padding], 'replicate', 'pre');

wpts = [jointLimits(5,1) jointLimits(5,2) jointLimits(5,1)];
tpts = [0 totalTime/2 totalTime];
tvec = 0:Ts:totalTime;
j5Pos = cubicpolytraj(wpts, tpts, tvec);
j5Pos = padarray(j5Pos, [0 padding], 'replicate', 'pre');

end