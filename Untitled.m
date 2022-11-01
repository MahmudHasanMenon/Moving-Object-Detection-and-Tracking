bg_TP = imread('input.jpg');    % Load Ground Truth for TP
bg_FP = imread('ground.png');    % Load Ground Truth for FP
TP = zeros;
FP = zeros;
TN = zeros;
FN = zeros;
fr_diff_F_TP = double(bg_TP) - double(fg_col);
fr_diff_F_FP = double(bg_FP) - double(fg_col);
fr_diff_F_FN = double(fg_col) - double(bg_FP);
fr_diff_F_TN = double(fg_col) - double(bg_TP);
      
for j=1:width
    for k=1:height
        if ((fr_diff_F_TP(k,j) == -255))
            TP = TP +1;
        else
            TP=TP; %#ok<ASGSL>
        end
        if ((fr_diff_F_FP(k,j) == -255))
            FP = FP +1;
        else
            FP=FP;
        end
        if ((fr_diff_F_FN(k,j) == -255))
            FN = FN +1;
        else
            FN=FN;
        end
        if ((fr_diff_F_TN(k,j) == -255))
            TN = TN +1;
        else
            TN=TN;
        end
    end
end
%-----Calculate: F-measure, Precision, Recall and ROC
PRs(N) = (TP)/(TP+FP);
PRs_inv = 1 - PRs;
RCl(N) = (TP)/(TP+FN);
FPR(N) = (FP)/(FP+TN);
F_mes(N)= (2*RCl(N)*PRs(N))/(RCl(N)+PRs(N));
ACC(N)=(TP+TN)/(TP+TN+FP+FN);


%-------------Plot F-measure, Precision, Recall-------- 
   figure(2),
     plot(F_mes,'DisplayName','F-measure','YDataSource','F-measure');
     title('F-Measure')
xlabel('Threshold')
ylabel('F-measure')
     hold all;
     plot(PRs,'DisplayName','Precision','YDataSource','Precision');
     plot(RCl,'DisplayName','Recall','YDataSource','Recall');
     hold off;
     
     %-------------Plot ROC---------------- 
     figure(3),
     plot(nonzeros(FPR),nonzeros(RCl),'DisplayName','ROC','YDataSource','Recall');
%      xlim([min(FPR) max(FPR)])
%      ylim([min(RCl) max(RCl)])
     title('ROC')
xlabel('False positive rate')
ylabel('True positive rate')

%------------- Plot Precision-Recall -------- 
figure(4),
     plot((PRs_inv),(RCl),'DisplayName','1-Precision','YDataSource','Recall');
%      xlim([min(FPR) max(FPR)])
%      ylim([min(RCl) max(RCl)])
     title('Recall-Pecision')
xlabel('1-Pecision')
ylabel('Recall')