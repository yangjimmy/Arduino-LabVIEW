function [TrajX, TrajY, TrajZ] = genGrooving( ...
    arm, pupilRadius, rhexisRadius, centerLoc, circleNormal)


%% 2022-01-19 Mia
% This function takes in parameters to generate trajectory
% ---- INPUTS ----
% > pupilRadius: radius of pupil [mm]
% > rhexisRadius: radius of rhexis [mm] 
% > centerLoc: pupil center location in IRISS frame 
% > circleNormal: pupil normal vector in IRISS frame
% ---- OUTPUTS ----
% > TrajX  : The X coordinate of the trajectory
% > TrajY  : The Y coordinate of the trajectory
% > TrajZ  : The Z coordinate of the trajectory

if nargin == 1    
    pupilRadius = 5.5; 
    rhexisRadius = 4; 
    centerLoc = [0.5464, -5.0453, -1.388]; 
    circleNormal = [-0.2418,0.1877,0.9522]; 
end

%% Parameters
tool_diam = 1.8; % mm
safeRadius = 0.75*pupilRadius; 
pupilCenter = [0;0;0];
opticalCenter = [0;0;1];
th = 0; % deg (note: needs to be negative or 0)

sampleTime = 1e-3; % [s]
grooveTime = 3; % [s] 

%% Exterior capsule 
% calcs, based on model assumptions
a = 0.45 * pupilRadius;
r_ant = 1.52 * a; % dist from bag center to AC apex = minor ellipsoid axis of ant part of bag 
r_ant_ext = r_ant; 
r_post = 2.61 * a; % dist from bag center to PP = minor ellipsoid axis of the post part of bag 
r_equator = 1.05 * r_post; % bag equator radius = major ellipsoid axis 

% generate full ellipsoid, centered at origin, with correctly sized cap bag
% equator radius and posterior (minor axis) radius 
nPts = 100;
[Xpost_ext, Ypost_ext, Zpost_ext] = ellipsoid(0, 0, 0, r_equator, r_equator, r_post, nPts);
% do the same for the anterior part of the caps bag 
[Xant_ext, Yant_ext, Zant_ext] = ellipsoid(0, 0, 0, r_equator, r_equator, r_ant, nPts);

% remove the top portion of the ellipsoid since we only want half (the
% posterior part of the cap bag)
bpos = floor(nPts/2); % calc halfway point 
Xpost_ext(1:bpos,:) = [];
Ypost_ext(1:bpos,:) = [];
Zpost_ext(1:bpos,:) = [];
% do the same for the anterior part, but remove the other half
bant = ceil(nPts/2)+2;
Xant_ext(bant:end,:) = [];
Yant_ext(bant:end,:) = [];
Zant_ext(bant:end,:) = [];

% Obtain cross section 
Ipost = find(~Ypost_ext); 
Xpost_ext = Xpost_ext(Ipost); 
Zpost_ext = -Zpost_ext(Ipost); 

Iant = find(~Yant_ext); 
Xant_ext = Xant_ext(Iant);
Zant_ext = -Zant_ext(Iant); 

% Shift down 
Zpost_ext = Zpost_ext - r_ant; 
Zant_ext = Zant_ext - r_ant; 


%% Generate capsule-based boundary
% calcs, based on model assumptions
a = 0.45 * safeRadius;
r_ant = 1.52 * a; % dist from bag center to AC apex = minor ellipsoid axis of ant part of bag 
r_post = 2.61 * a; % dist from bag center to PP = minor ellipsoid axis of the post part of bag 
r_equator = 1.05 * r_post; % bag equator radius = major ellipsoid axis 

% to get the center of the caps bag, we start at p_eyeCenter and go a 
% distance down (positive) a along c
% TODO: ensure c points in the correct direction; 3d circ fit might not
% guarantee it does 
p_bc = pupilCenter + a * opticalCenter; % center of the capsular bag 

% generate full ellipsoid, centered at origin, with correctly sized cap bag
% equator radius and posterior (minor axis) radius 
nPts = 100;
[Xpost, Ypost, Zpost] = ellipsoid(0, 0, 0, r_equator, r_equator, r_post, nPts);
% do the same for the anterior part of the caps bag 
[Xant, Yant, Zant] = ellipsoid(0, 0, 0, r_equator, r_equator, r_ant, nPts);

% remove the top portion of the ellipsoid since we only want half (the
% posterior part of the cap bag)
bpos = floor(nPts/2); % calc halfway point 
Xpost(1:bpos,:) = [];
Ypost(1:bpos,:) = [];
Zpost(1:bpos,:) = [];
% do the same for the anterior part, but remove the other half
bant = ceil(nPts/2)+2;
Xant(bant:end,:) = [];
Yant(bant:end,:) = [];
Zant(bant:end,:) = [];

% Obtain cross section 
Ipost = find(~Ypost); 
Xpost = Xpost(Ipost); 
Zpost = -Zpost(Ipost); 

Iant = find(~Yant); 
Xant = Xant(Iant);
Zant = -Zant(Iant); 

% Shift down  
% Ensuring that the outer and inner capsules are "concentric" (2022-1-22) 
Zpost = Zpost - r_ant_ext; 
Zant = Zant - r_ant_ext; 
% Zpost = Zpost - r_ant; 
% Zant = Zant - r_ant;

% Obtain half capsule for interpolation purposes
Ihalf_post = find(Xpost > 0); 
Xq_post = Xpost(Ihalf_post); 
Zq_post = Zpost(Ihalf_post); 

Ihalf_ant = find(Xant > 0); 
Xq_ant = Xant(Ihalf_ant); 
Zq_ant = Zant(Ihalf_ant); 



%% Generate trajectory 
iris2PC = abs(min(Zpost)); 
lower_lim_factor = 0; % percent distance above iris
dist_between_grooves = 0.8*tool_diam;
grooveRadius = 0.25*dist_between_grooves; 
numGrooves = ceil(iris2PC*(1 - lower_lim_factor)/dist_between_grooves); 
numpts_groove = floor(grooveTime/sampleTime);

% Allocate pts to each segment of groove 
pts_segment12 = floor(2*numpts_groove/7); 
pts_segment23 = floor(numpts_groove/7); 
pts_segment34 = floor(2*numpts_groove/7); 
pts_segment46 = floor(2*numpts_groove/7); 
    
TrajY = []; 
TrajZ = [];
for i = 1:numGrooves
    
    % Each groove has six key points
    if i == 1
        point1_y(i) = -0.8*rhexisRadius; % Placing start location near the rhexis boundary (2022-01-03)  
        point1_z(i) = -tool_diam*0.3; % Placing first groove at 30% depth (2022-01-02) 

        %% Need to establish line of points for LHS limit of grooves  
        % Obtain rotation matrix 
        % Obtain unit rotation vector and angle for tilt
        if circleNormal(3) < 0
            circleNormal = -circleNormal;
        end

        rot_vector = cross([0;0;1], circleNormal); % Rotation vector obtained as the cross product between z-axis of {IRISS} and circleNormal
        rot_vector = rot_vector/norm(rot_vector); % Obtain unit rotation vector
        rot_angle = acos(dot([0;0;1], circleNormal)/norm(circleNormal)); % Letting dot(v1,v2) = norm(v1)*norm(v2)*cos(theta) and solving for
          % Construct rotation matrix for tilting trajectory
        ux = rot_vector(1); uy = rot_vector(2); uz = rot_vector(3);
        cost = cos(rot_angle); sint = sin(rot_angle);

        Rtilt = [cost + ux^2*(1-cost), ux*uy*(1-cost) - uz*sint, ux*uz*(1-cost) + uy*sint; ...
            uy*ux*(1-cost) + uz*sint, cost + uy^2*(1-cost), uy*uz*(1-cost) - ux*sint; ...
            uz*ux*(1-cost) - uy*sint, uz*uy*(1-cost) + ux*sint, cost + uz^2*(1-cost)];        
        
        
        RCM = -Rtilt'*centerLoc'; % RCM in traj frame
        RCMrot = RCM; RCMrot(2) = -RCMrot(2); % Need rotated RCM for purpose of traj generation 
        startLoc = [0; point1_y(i); point1_z(i)]; 
        
        vector = startLoc - RCMrot; % Vector from RCM to startLoc 
        rotMatrix = [1, 0, 0; 0, cosd(th), -sind(th); 0, sind(th), cosd(th)]; 
        % Want the vector that is th deg under this line 
        vector2 = rotMatrix*vector; 
        % Creating line in desired direction 
        line_param = linspace(0,20, 1000); 
        line_y = RCMrot(2) + vector2(2)*line_param; % Question: not sure yet if supposed to use RCMrot or startLoc as the pivot 
        line_z = RCMrot(3) + vector2(3)*line_param; 
        
    else
        point1_z(i) = point1_z(i-1) - dist_between_grooves;
        point1_y(i) = interp1(line_z,line_y,point1_z(i));  % Interpolate to get start location of the groove 
    end
    
    % Determining 2y
    if point1_z(i) >= max(Zant) % Making the first groove(s) across the rhexis 
        point2_y(i) = -point1_y(i);  
        point3_y(i) = point2_y(i); 
    
    elseif point1_z(i) >= -r_ant_ext % This is the cutoff depth between AC and PC 
        point3_y(i) = interp1(Zq_ant, Xq_ant, point1_z(i)+2*grooveRadius);
        point2_y(i) = point3_y(i);
    else
        point2_y(i) = interp1(Zq_post, Xq_post, point1_z(i));
        point3_y(i) = point2_y(i);
    end
        
    point2_z(i) = point1_z(i); 
    point3_z(i) = point2_z(i) + 2*grooveRadius;
   
    % Defining point6 before 4 and 5, so that we can shift those relative
    % to 6 
    point6_z(i) = point1_z(i) - dist_between_grooves; 
    point6_y(i) = interp1(line_z,line_y,point6_z(i)); % Fixing point6 location
    
    point4_y(i) = point6_y(i) + 0.2*abs(point6_y(i) - point3_y(i)); % Backward pass is being shortened 
    point4_z(i) = point3_z(i);
    
    point5_y(i) = point4_y(i) - grooveRadius; 
    point5_z(i) = point4_z(i) - grooveRadius; 
    
    % Define trajectories between key points
    segment12_y = linspace(point1_y(i),point2_y(i),pts_segment12); 
    segment12_z = linspace(point1_z(i),point2_z(i),pts_segment12); 
    
    center23_y = 0.5*(point2_y(i) + point3_y(i)); 
    center23_z = 0.5*(point2_z(i) + point3_z(i)); 
    th23 = linspace(-pi/2,pi/2,pts_segment23); 
    segment23_y = center23_y + grooveRadius*cos(th23);  
    segment23_z = center23_z + grooveRadius*sin(th23);
    
    segment34_y = linspace(point3_y(i),point4_y(i),pts_segment34); 
    segment34_z = linspace(point3_z(i),point4_z(i),pts_segment34); 
    
    spline_x = linspace(point6_z(i), point4_z(i), pts_segment46); % Creating a rotated spline in a fake (x,y) frame (to avoid spline issues) 
    spline_y = spline([point6_z(i), point5_z(i), point4_z(i)], [point6_y(i), point5_y(i), point4_y(i)], spline_x); 
    
    segment46_y = flip(spline_y); 
    segment46_z = flip(spline_x); 

    if ~isnan(point2_y(i))
        groove_y = [segment12_y segment23_y segment34_y segment46_y]; 
        groove_z = [segment12_z segment23_z segment34_z segment46_z]; 
    else
        %groove_y = [segment12_y segment23_y segment34_y]; 
        %groove_z = [segment12_z segment23_z segment34_z]; 
        groove_y = []; 
        groove_z = []; 
    end 
    
    TrajY = [TrajY groove_y]; % Concatenate onto the initially empty trajectory
    TrajZ = [TrajZ groove_z];
    
end
% Truncate extra segment 
TrajY = TrajY(1:end-length(segment46_y) - length(segment34_y)); 
TrajZ = TrajZ(1:end-length(segment46_z) - length(segment34_y));

% % Generate initial point from start location to start of the trajectory 
% startloc_y = -pupilRadius; 
% startloc_z = 2; 
% pts_start_segment = 20; 
% start_segment_y = linspace(startloc_y, point1_y(1),pts_start_segment); 
% start_segment_z = linspace(startloc_z, point1_z(1),pts_start_segment); 
% 
% % Generate end segment 
% pts_end_segment = 20; 
% end_segment_y = linspace(yTraj(end), startloc_y,  pts_end_segment); 
% end_segment_z = linspace(zTraj(end), startloc_z, pts_end_segment); 
% 
% yTraj = [start_segment_y yTraj end_segment_y];
% zTraj = [start_segment_z zTraj end_segment_z]; 

TrajX = zeros(1,length(TrajY)); 
if arm == 1
TrajY = -TrajY; % Flip to align y with {IRISS} 
end 

%% Add trajectory from end point to start point 
end2startX = linspace(TrajX(end), TrajX(1), numpts_groove); 
end2startY = linspace(TrajY(end), TrajY(1), numpts_groove); 
end2startZ = linspace(TrajZ(end), TrajZ(1), numpts_groove); 

TrajX = [TrajX end2startX]; 
TrajY = [TrajY end2startY]; 
TrajZ = [TrajZ end2startZ]; 

%% Transform to IRISS frame 
if arm == 0
    centerLoc(2) = -centerLoc(2); 
end
trajCenter = [centerLoc(1), centerLoc(2), centerLoc(3)]; 

traj_rot = Rtilt*[TrajX; TrajY; TrajZ]; % Apply tilting matrix to the 3d trajectory

TrajX = traj_rot(1,:) + trajCenter(1);
TrajY = traj_rot(2,:) + trajCenter(2);
TrajZ = traj_rot(3,:) + trajCenter(3);

% if arm == 0
%     TrajY = TrajY + 13;
% end
end