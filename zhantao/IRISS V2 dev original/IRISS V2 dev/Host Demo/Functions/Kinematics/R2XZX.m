function a = R2XZX(R)
    % 2023-02-03 Jason XZX Euler angles
    a = zeros(3,1);
    if R(1,1)==1
        a(1) = atan2(R(3,2),R(2,2));a(2) = 0;a(3) = 0;
    elseif R(1,1)==-1
        a(1) = atan2(-R(3,2),-R(2,2));a(2) = pi;a(3) = 0;
    else
        a(1) = atan2(R(3,1),R(2,1));
        a(2) = atan2(sqrt(R(1,2)^2+R(1,3)^2),R(1,1));
        a(3) = atan2(R(1,3),-R(1,2));
    end
end
