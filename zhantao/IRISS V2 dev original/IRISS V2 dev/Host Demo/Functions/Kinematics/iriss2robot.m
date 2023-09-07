function vb = iriss2robot(vI,armID)
% pb = robot2Iriss(pI,armID)
% Tb = robot2Iriss(TI,armID)
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

RbI = rotx(-rotAngleX) * roty(90);
pbI = [0; 0; 0];
TbI = [RbI pbI; 0 0 0 1];

switch size(vI,1)
    case 3
        
        pI = vI;
        pb = RbI*pI + pbI;
        vb = pb;
        
    case 4
        
        TI = vI;    
        Tb = TbI*TI;
        vb = Tb;     
end



end