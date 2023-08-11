function [X, Y, Z] = fitendo(endo_pts_mm, surffit_endo)
%2021-10-04 MJG get endopt surface for plotting 
% take endo pts [mm] from data, fit a surface, and output the pts for
% plotting

% roughly calculate the center of the fit 
endocenter = mean([endo_pts_mm(:,1) endo_pts_mm(:,2)]);

% how far to each side to plot (too far will look weird/bad) 
edge = 4;
inc = 0.1;

% build XY values 
[X, Y] = meshgrid(endocenter(1)-edge:inc:endocenter(1)+edge, ...
                  endocenter(2)-edge:inc:endocenter(2)+edge);

% calc Z at each XY value 
Z = surffit_endo(X, Y);


end