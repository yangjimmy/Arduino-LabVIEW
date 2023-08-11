function [vacf] = vacuumSchedule(z,zp,z_thld,vac_bnd)

z_dist2post = (z-zp); 
vacf = zeros(1,length(z));
for k = 1:length(z)
    if      z_dist2post(k) < z_thld(1)
        vacf(k) = vac_bnd(1);
    elseif  z_dist2post(k) > z_thld(1) && z_dist2post(k) < z_thld(2)
        vacf(k) = (z_dist2post(k)-z_thld(1)) * (vac_bnd(2)-vac_bnd(1))/(z_thld(2)-z_thld(1)) + vac_bnd(1);
    else
        vacf(k) = vac_bnd(2);
    end
end

end