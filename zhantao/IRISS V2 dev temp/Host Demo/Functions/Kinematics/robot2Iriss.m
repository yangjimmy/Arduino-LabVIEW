function vI = robot2Iriss(vb,armID)
% pI = robot2Iriss(pb,armID)
% TI = robot2Iriss(Tb,armID)
% pb: position in base frame (3xN)
% pI: position in IRISS frame (3xN)
% Tb: transformation matrix relative to base frame (4x4)
% TI: transformation matrix relative to IRISS frame (4x4)

% NOTE: rotation angle depends on the mounting. If the mounting angle is
% different then the angle should change accordingly
if armID == 0 % left arm (currently being used)
    rotAngleX = -25;
elseif armID == 1 % right arm
    rotAngleX = 25;
end

RIb = roty(-90)*rotx(rotAngleX);
pIb = [0; 0; 0];
TIb = [RIb pIb; 0 0 0 1];

switch size(vb,1)
    case 3
        
        pb = vb;
        pI = RIb*pb + pIb;
        vI = pI;
        
    case 4
        
        Tb = vb;    
        TI = TIb*Tb;
        vI = TI;     
end



end