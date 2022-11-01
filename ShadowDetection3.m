 function [shadows_remove,maskbw] = ShadowDetection(I)
    YCBCR = rgb2ycbcr(I);
    IY = YCBCR(:,:,1);
    ICb = YCBCR(:,:,2);
    ICr = YCBCR(:,:,3);
    Yavg = mean2(IY);
    mask = zeros(size(IY));
    for i = 1:size(IY,1);
        for j = 1:size(IY,2);        
            pixel = IY(i,j);                    
            if(pixel > Yavg) %black
                newpixel = 0;
            else  %white
                newpixel = 1;
            end
            mask(i,j) = newpixel;
        end
    end
    maskbw = mask;
    mask = uint8(maskbw);
    figure,imshow(mask)

    se = [0 1 1 1 0; 1 1 1 1 1; 1 1 1 1 1; 1 1 1 1 1; 0 1 1 1 0];   
    % mask morphological operation
    shadow_core = uint8(imerode(mask, se));
    nonshadow_core = uint8(imerode(1-mask, se));
%     figure,subplot(1,2,1),imshow(shadow_core)
%            subplot(1,2,2),imshow(nonshadow_core)   
        % mean channel values in YCbCr
        shadowavg_Y = sum(sum(IY.*shadow_core)) / sum(sum(shadow_core));
        shadowavg_Cb = sum(sum(ICb.*shadow_core)) / sum(sum(shadow_core));
        shadowavg_Cr = sum(sum(ICr.*shadow_core)) / sum(sum(shadow_core));
        nonshadowavg_Y = sum(sum(IY.*nonshadow_core)) / sum(sum(nonshadow_core));
        nonshadowavg_Cb = sum(sum(ICb.*nonshadow_core)) / sum(sum(nonshadow_core));
        nonshadowavg_Cr = sum(sum(ICr.*nonshadow_core)) / sum(sum(nonshadow_core));        
        % computing ratio, and difference in ycbcr space
        diff_Y = nonshadowavg_Y - shadowavg_Y;
        ratio_Cb = nonshadowavg_Cb/shadowavg_Cb;
        ratio_Cr = nonshadowavg_Cr/shadowavg_Cr;
        % y channel additive correction
        % cb, and cr channels correction
        Y = IY + mask * diff_Y;
        Cb = ICb.*(1-mask) + mask.*ratio_Cb.*ICb;
        Cr = ICr.*(1-mask) + mask.*ratio_Cr.*ICr;      
        %merge 3 channels
        shadows_remove = cat(3,Y,Cb,Cr);
        %convert back 
        shadows_remove = ycbcr2rgb(shadows_remove);
        figure,imshow(shadows_remove)
end

