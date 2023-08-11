function endoPts = getEndoPts(corneaCap)
%getEndoPts 2021-09-06 MJG 
% find bottom-most points of the cornea cap and export as an nx3 array of
% endothelium points 


% find botmost points (endothelium guesses)
% [~, botmostPoints] = max(flipud(cleanCornCap), [], 1);
[~, botmostPoints] = max(flipud(corneaCap), [], 1);

% create x and y pts 
xi = repmat((1:1:400)', 400, 1);
yi = repelem((1:1:400)', 400);

% convert to xyz; must flipud the pts 
endoPts = [xi yi 377-botmostPoints(:)];

% remove all rows (xyz pts) where z == 376
endoPts(endoPts(:,3) == 376,:) = [];

% NOTE: I didn't ensure the 1-indexing is correct here, so the actual
% values may be +/- 1 px from what's calculated; it doesn't really matter
% though

end

