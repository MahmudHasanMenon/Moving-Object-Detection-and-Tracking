I=imread('illu.png');
I1=im2bw(I);
[gX, gY]=imgradientxy(I1);
%Im=imread('la.png');
I4=imcomplement(imabsdiff(gX,gY));

I2=imread('ob.png');
I3=im2bw(I2);

[gx,gy]=imgradientxy(I3);
I5=imcomplement(imabsdiff(gx,gy));
figure(1),
subplot(2,2,1),imshow(I);
title('Background')
subplot(2,2,2),imshow(I4);
title('Gradient Difference Of Background')
subplot(2,2,3),imshow(I2);
title('Current Frame')
subplot(2,2,4),imshow(I5);
title('Gradient Difference of Current image')

