I=imread('frame_272.jpg');

cform = makecform('srgb2lab');
lab_IMG = applycform(I,cform);
%lab_IMG=RGB2Lab(I);
L=lab_IMG(:,:,1);
A=lab_IMG(:,:,2);
B=lab_IMG(:,:,3);

[row ,col,NofCh]=size(lab_IMG);
MeanL= mean2(L);
MeanA= mean2(A);
MeanB= mean2(B);

Total=MeanA+MeanB;
display(MeanL);
display(MeanA);
display(MeanB);
display(Total);
SD=std2(double(L)/3);
display(SD);
SV=MeanL-SD;
%display(SV);
%display(MeanL)impixel(lab_IMG));
if Total>=256
    
    for i=1:row 
         for j=1:col
             
             if L(i,j)<=SV
                 pixel=256;
             else
                 pixel=0;
             end
             
             L(i,j)=pixel;
        end
    end
    
else
    for i=1:row 
         for j=1:col
             
             if L(i,j)<=SV
                 pixel=256;
             else
                 pixel=0;
             end
             
             L(i,j)=pixel;
        end
    end
    for i=1:row 
         for j=1:col
             
             if B(i,j)<=SV
                 pixel=256;
             else
                 pixel=0;
             end
             
             B(i,j)=pixel;
        end
    end
  
end

figure(1),subplot(2,2,1),imshow(lab_IMG);
title('Image in Lab Space ')

subplot(2,2,2),imshow(L);
title('shadow detected')
subplot(2,2,3),imshow(L+B);
title('L+B Components')
Image=imabsdiff(im2bw(B),im2bw(L));
Se=strel('square',2);
SE=strel('square',2);
I2=imerode(Image,Se);
I3=imdilate(I2,SE);
I4=imerode(I3,SE);

subplot(2,2,4),imshow(I3);
title('Removed Shadow'),