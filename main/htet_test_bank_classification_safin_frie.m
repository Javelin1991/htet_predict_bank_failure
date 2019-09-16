% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_safin_frie XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using SaFIN(FRIE)
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clear;
clc;

load CV1_Classification;

% data preparation
D = CV1{1,1};
data_target = D(:,2);
D = D(:,[3 7 10 2]);
start_test = (size(D, 1) * 0.2) + 1;
target_size = length(D);
trainData = D(1:start_test-1,:);
testData = D(start_test:length(D), :);
IND = 3;
OUTD = 1;
Alpha = 0.25;
Beta = 0.65;
Eta = 0.05;
Forgetfactor = 0.99;
Epochs = 300;

% network prediction
[net_out, net_structure] = Run_SaFIN(trainData,testData,IND,OUTD,Alpha,Beta,Epochs,Eta,Forgetfactor);

output = htet_find_optimal_cut_off(testData(:,4), net_out);

load handel
sound(y,Fs)
