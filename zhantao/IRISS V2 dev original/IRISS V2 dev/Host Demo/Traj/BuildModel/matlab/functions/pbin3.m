function h = pbin3(invol)
%PBIN3 Input is a 3D matrix of binary; this code simply plots it as a 3d
%plot with the Z axis reversed (for ThorLabs OCT data), with 100,000 pts
% and with [376 400 400] zxy limits

[z, x, y] = ind2sub(size(invol), find(invol));

if size(x,1) > 100000
    n = round(size(x,1) / 100000);
else
    n = 1;
end
xyz = downsample([x y z], n);

h = figure; 
plot3(xyz(:,1), xyz(:,2), xyz(:,3), 'k.', 'MarkerSize', 1); 
hold on; axis equal; grid on;
set(gca, 'zdir', 'reverse');
xlabel('x [px]'); ylabel('y [px]'); zlabel('z [px]');
xlim([0 400]); ylim([0 400]); zlim([0 376]);

end

