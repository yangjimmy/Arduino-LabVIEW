function [TrajX, TrajY, TrajZ] = genGroove(initLoc, d, p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs: 
% - initLoc              (Start location)
% - d                    (Depth of current groove)
% - p                    (Groove length) 

% Outputs: 
% - TrajX, TrajY, TrajZ  (Trajectory) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 0
    initLoc = [0;0;0]; 
    d = 0; 
    p = 5; 
end

% Parameters 
sampleTime = 1e-3; % sec 
%totalTime = 4; % sec
%numSegments = 4; 
%timePerSegment = totalTime/numSegments;  
timeInit = 3; 
numInit = floor(timeInit/sampleTime); 
timePerSegment = 10; 
numSegment = floor(timePerSegment/sampleTime); 

yOffset = 1; % mm 
zOffset = 0; % mm 

% Segment #1: Init location to start of groove 
ySeg1 = linspace(initLoc(2), initLoc(2) + yOffset, numInit); 
zSeg1 = linspace(initLoc(3), initLoc(3) + zOffset + d, numInit); 

% Segment #2: Forward motion 
ySeg2 = linspace(ySeg1(end), ySeg1(end) + p, numSegment); 
zSeg2 = zSeg1(end)*ones(1,numSegment); 

% Pause trajectory for a few seconds 
pauseTime = 7; % [s]  
numPause = floor(pauseTime/sampleTime); 
yPause = ySeg2(end)*ones(1,numPause); 
zPause = zSeg2(end)*ones(1,numPause); 

% Segment #3: Backward motion 
ySeg3 = flip(ySeg2); 
zSeg3 = zSeg2; 

% Segment #4: Return to start 
ySeg4 = flip(ySeg1); 
zSeg4 = flip(zSeg1); 

% Segment #5: Pause again to give us time to reset operation 
yPause2 = ySeg4(end)*ones(1,numPause); 
zPause2 = zSeg4(end)*ones(1,numPause); 

% Combine trajectories 
TrajY = [ySeg1, ySeg2, yPause, ySeg3, ySeg4, yPause2]; 
TrajZ = [zSeg1, zSeg2, zPause, zSeg3, zSeg4, zPause2]; 
TrajX = zeros(1,length(TrajY)); 

% Plot trajectory 
% figure;
% plot3(TrajX, TrajY, TrajZ, '.'); 
end