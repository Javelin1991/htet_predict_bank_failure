% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :
% Function  :
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clc;
clear;
load '5_Fold_CV_Bank_Classification';

data = CV1{1};
start_test = length(data)*0.2 + 1;
target_data = data(start_test:length(data),2);

all_output_data = net_result_for_last_record(1).after_threshold{1};
predicted_data = all_output_data(start_test:length(all_output_data),:);

trueMat = target_data;
predictedMat = predicted_data;

TN = 0; TP = 0; FN = 0; FP = 0;

adder = trueMat + predictedMat;
TN = length(find(adder == 0));
TP = length(find(adder == 2));
subtr = trueMat - predictedMat;
FN = length(find(subtr == -1));
FP = length(find(subtr == 1));

FNR = FN/(TP + FN) * 100;
FPR = FP/(TN + FP) * 100;
