function [cx, cy, r] = max_inscribed_circle(pupilBlob)
% TODO: REALLY need to clean this up... MJG 2021-09-08 

% get convex hull of this shape... 
CH = bwconvhull(pupilBlob);
% figure(23); clf; imshow(CH); 


padding = 0;
% rep the top/bot-most rows 
toprep = repmat(CH(1,:), padding, 1);
botrep = repmat(CH(end,:), padding, 1);
% add to orig
paddedCH = [toprep; CH; botrep];
leftrep = repmat(paddedCH(:,1), 1, padding);
migirep = repmat(paddedCH(:,end), 1, padding);
paddedCH = [leftrep paddedCH migirep];
% figure; imshow(paddedCH)


[B, ~] = bwboundaries(paddedCH); %, 'noholes');
blank = false(size(paddedCH));

   boundary = B{1};
   
   for jj = 1:size(boundary,1)

   blank(boundary(jj,1), boundary(jj,2)) = true;
   end
% figure; imshow(blank);


% 
[y,x] = find(blank);
% 
% res = max_inscribed_circle2(x,y);
% 
% 
% figure(1); clf; imagesc(blank); hold on;
% plot(res.yc,res.xc,'r+');
%     theta = [linspace(0,2*pi) 0];
%     plot(sin(theta)*res.r + res.yc, cos(theta)*res.r + res.xc, 'color','g','LineWidth', 2);
%     
%     
%     
    
 

% get the contour
% sz=size(ContourImage);
% [Y,X]=find(ContourImage==255,1, 'first');
% ContourImage = ContourImage(:,:,1)==255;
% contour = bwtraceboundary(ContourImage, [Y(1), X(1)], 'W', 8);
% X=contour(:,2);
% Y=contour(:,1);
bw = bwdist(blank);
% figure; imshow(bw,[]);

% find the maximum inscribed circle:
% The point that has the maximum distance inside the given contour is the
% center. The distance of to the closest edge (tangent edge) is the radius.
% tic();
% BW=bwdist(logical(ContourImage));
[Mx, My] = meshgrid(1:size(blank,1), 1:size(blank,2));

p = [Mx(:), My(:)];
nodes = [x y];
in = inpoly(p, nodes);

% pins = [Mx(in), My(in)];
% figure; plot(pins(:,1), pins(:,2), 'r.')

% ndx = sub2ind([400 400], Mx(in), My(in));

masker = zeros(size(blank));
idx = sub2ind(size(blank), My(in), Mx(in));
masker(idx) = 1;
% figure;imshow(masker)

gg = masker .* bw;
% figure; imagesc(gg)


[r, rind] = max(gg(:));

% [r, rind] = max(bw(in));


% inds = sub2ind([400 400], My(in), Mx(in));

%   in = inpoly(p,node);
%
%   p   : The points to be tested as an Nx2 array [x1 y1; x2 y2; etc].
%   node: The vertices of the polygon as an Mx2 array [X1 Y1; X2 Y2; etc].
%         The standard syntax assumes that the vertices are specified in
%         consecutive order.

% [Vin, Von] = inpoly([Mx(:), My(:)], [x, y]);

% [r, rind] = max(bw(ndx));
r = r(1); 
rind = rind(1);

% bw(ind)

% cx = Mx(rind);
% cy = My(rind);
% [cy, cx] = p(rind,:);
cx = p(rind,2);
cy = p(rind,1);


% [cy, cx] = ind2sub(size(bw), in(rind));

% [R RInd]=max(BW(ind)); 
% R=R(1); RInd=RInd(1); % handle multiple solutions: Just take first.
% [cy cx]=ind2sub(sz, ind(RInd));
% toc();
% display result
% if (~exist('display','var'))
%     display=1;
% end
% if (display)
% figure(1); clf; imagesc(bw); hold on;
% plot(cy, cx,'r+');
% 
%     theta = [linspace(0,2*pi) 0];
% 
%     plot(sin(theta)*r + cy, cos(theta)*r + cx, 'color','g','LineWidth', 2);
%     
%     
    cy = cy - padding;
    cx = cx - padding;
    
end
