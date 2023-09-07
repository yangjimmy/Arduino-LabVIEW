function [xp, yp, zp] = updateBagModel(xp, yp, zp, p_bc, newEquator)
%2021-10-11 MJG 
% update caps bag model as the bag equator is changed

    % calc metrics/scaling -
    ds = vecnorm([xp(:,1) yp(:,1) zp(:,1)]' - p_bc);
    old_equator = max(ds);
    old_rpost = min(ds); % not strictly accurate, but fine
    new_rpost = newEquator * old_rpost / old_equator;
    % crit; how to scaling pts based on new equator radius 
    scaling = (newEquator - new_rpost) * (ds - old_rpost)/(old_equator-old_rpost) + new_rpost;
    % loop through all points and scale appropriately 
    for ii = 1:size(xp,1)
        for jj = 1:size(xp,2)
            direction = [xp(ii,jj); yp(ii,jj); zp(ii,jj)] - p_bc;
            direction = direction / norm(direction);
            new_pt = p_bc + scaling(ii) * direction; 
            xp(ii,jj) = new_pt(1);
            yp(ii,jj) = new_pt(2);
            zp(ii,jj) = new_pt(3);
        end
    end
end