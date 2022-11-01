% RGB to YCbCr with Matlab
I = imread('Image.png');
figure(1), imshow(I);
% RGB to YCbCr with Matlab
R = I(:,:,1);
G = I(:,:,2); 
B = I(:,:,3); 
figure(2),subplot(2,2,1), imshow(R);
subplot(2,2,2),imshow(G);
subplot(2,2,3), imshow(B);
% RGB to YCbCr with Matlab
I2 = rgb2ycbcr(I);
Y = I2(:,:,1); 
Cb = I2(:,:,2); 
Cr = I2(:,:,3); 
figure(1),subplot(2,2,1),imshow(I2);
subplot(2,2,2),imshow(Y);
subplot(2,2,3), imshow(Cb);
figure(7), imshow(Cb);
figure(8), imshow(Cb);