
yy=400;

slice = vscan(:,:,yy);
figure(1); clf; imshow(slice); 

c = cornLabels(:,:,yy);

% fix c
nn = 7;
c = (c + [c(nn:end,:); zeros(nn-1,size(c,2))] ) >0;

i = irisLabels(:,:,yy);

label = zeros(size(slice)) + 2*c + 3*i;
% figure(2); clf; imagesc(label);

figure(10); clf; 
imshow(labeloverlay(slice, label, 'Transparency', 0.7));