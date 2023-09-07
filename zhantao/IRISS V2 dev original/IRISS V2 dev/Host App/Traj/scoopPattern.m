function [z] = scoopPattern(z_ofst,z_start,za,zp,n_flr,s,w)

for k = 1:length(z_ofst)
    if z_ofst(k) >= 0
        z_ofst(k) = abs(za(k)-z_start);
    else
        z_ofst(k) = abs(zp(k)-z_start);
    end
end
z = z_start-z_ofst.*sin(n_flr*s).*w;
end