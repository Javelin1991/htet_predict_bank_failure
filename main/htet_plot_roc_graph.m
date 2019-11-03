% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_plot_roc_graph XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :
% Stars     :   
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clear;
clc;

load hcl_safin_frie_cv5_27_feat;

labels = BEST_SYSTEMS(1).testData(:,9);
scores = BEST_SYSTEMS(1).final_out;

fnr = [];
fpr = [];

RESOLUTION = 0.001;
cut_off = RESOLUTION;

% while (cut_off <=1)
[TP, FP, TN, FN, FNR, FPR, Acc] = htet_get_classification_results(labels, scores)


[X,Y] = perfcurve(labels,scores,1)

for i=1:size(Y,1)
  Y(i,:) = 1 - Y(i,:);
end

figure;
plot(X,Y);
xlabel('False positive rate')
ylabel('False negative rate')
title('ROC for Classification')
