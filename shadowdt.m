clear all
close all
clc

%% Read Images:

im = imread('frame_105.jpg');
figure, imshow(im);

% NOTE: You might need different median filter size for your test image.
r = medfilt2(double(im(:,:,1)), [3,3]); 
g = medfilt2(double(im(:,:,2)), [3,3]);
b = medfilt2(double(im(:,:,3)), [3,3]);

%% Calculate Shadow Ratio:

shadow_ratio = ((4/pi).*atan(((b-g))./(b+g)));
figure, imshow(shadow_ratio, []); colormap(jet); colorbar;

% NOTE: You might need a different threshold value for your test image.
% You can also consider using automatic threshold estimation methods.
shadow_mask = shadow_ratio>0.2;
figure, imshow(shadow_mask, []); 

shadow_mask(1:5,:) = 0;
shadow_mask(end-5:end,:) = 0;
shadow_mask(:,1:5) = 0;
shadow_mask(:,end-5:end) = 0;

% NOTE: Depending on the shadow size that you want to consider,
% you can change the area size threshold
shadow_mask = bwareaopen(shadow_mask, 100);
[x,y] = find(imdilate(shadow_mask,strel('disk',2))-shadow_mask);

figure, imshow(im); hold on,
plot(y,x,'.b'), title('Shadow Boundaries');

%%