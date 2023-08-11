function clabelMask = getCorneaMask(cctop,ccbot)
%getCorneaMask 2021-09-06 MJG 
% take the top&bot surface curves (pclouds) and generate a 3d mask


% --- create a position mask
% reshape both curves into matrices 
% ccbot = round(reshape(corneaCurve_bot, 400, 400));
% 
% loop through the surfaces and generate a positive mask
clabelMask = zeros([376 400 100]);
% NOTE: to remove outliers here, can check the distance bt cctop and ccbot
% in each A-scan and compare it with the corneaThickness+padding 
for yy = 1:400
    for xx = 1:400
        clabelMask(cctop(yy,xx):ccbot(yy,xx), yy, xx) = 1;
    end
end
% hj = pbin3(clabelMask);

% maintain binary 
clabelMask = logical(clabelMask);


end

