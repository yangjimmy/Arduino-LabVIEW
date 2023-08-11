function [ori,pos]=fwd_kmtcs_rev2(th1,th2,th3,th4,gst0)
% INPUTS:
% th1, th2, th3, and th4 are joint inputs
% th1, th2, and th4 are in deg while th3 is in mm
% default origin is [0 0 0]'
% gst0 = starting orientation position in XYZ coordinate
%
% OUTPUTS:
% ori means the tool orienation/posture while pos is tool tip position

if nargin < 5
    gst0=eye(4);    % default gst0
else
    gst=gst0;
end

th1=degtorad(th1);
th2=degtorad(th2);
th4=degtorad(th4);

T1=[1 0 0 0;
   0 cos(th1) -sin(th1) 0;
   0 sin(th1) cos(th1) 0;
   0 0 0 1];
T2=[cos(th2) 0 sin(th2) 0;
   0 1 0 0;
   -sin(th2) 0 cos(th2) 0;
   0 0 0 1];
T3=eye(4); T3(3,4)=th3;
T4=[cos(th4) -sin(th4) 0 0;
    sin(th4) cos(th4) 0 0;
    0 0 1 0;
    0 0 0 1];

gst=T1*T2*T3*T4*gst0;
ori=gst(1:3,1:3);   % tool orientation
pos=gst(1:3,4);  % tool tip position

end
