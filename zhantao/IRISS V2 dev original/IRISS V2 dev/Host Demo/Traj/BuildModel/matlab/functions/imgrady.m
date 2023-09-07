function Gy = imgrady(I)
%imgrady find the y gradient of an image
% MJG 2021-08-25; this does the same thing as imgradientxy, but simpler 
% and faster; uses sobel method; input must be double

% get gradient
% h = -fspecial('sobel');
Gy = imfilter(I, [-1 -2 -1; 0 0 0; 1 2 1], 'replicate');
            
end