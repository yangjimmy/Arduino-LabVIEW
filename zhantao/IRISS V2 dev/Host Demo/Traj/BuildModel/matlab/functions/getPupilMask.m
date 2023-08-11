function pupilMask = getPupilMask(pupil_pts_mm)
%getPupilMask 2021-09-09 MJG 
% generate a 2D pupil mask to, uh, mask out the iris (sorry, bad naming
% convention). 

% convert pupil_pts to [px]
pupil_pts_px = round(pupil_pts_mm / 0.025);
% figure(14); clf;
% plot(pupil_pts_px(:,2), pupil_pts_px(:,1), 'ro'); hold on; grid on; 

% convert those points to binary image... 
pupilDots = zeros(400); 
idx = sub2ind(size(pupilDots), pupil_pts_px(:,1), pupil_pts_px(:,2));
pupilDots(idx) = 1;
% figure; imshow(pupilDots);

% get convexhull 
pupilHull = bwconvhull(pupilDots);
% figure; imshow(pupilHull);

% shrink the convexhull a bit by eroding it;
% note: this is to ensure we really don't capture any of the iris 
se = strel('disk', 12, 6);
pupilMask = imerode(pupilHull, se);
% figure; imshow(erodedPupil);


end

