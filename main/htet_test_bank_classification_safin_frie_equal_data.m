% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_safin_frie_equal_data XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using SaFIN_FRIE with balanced data set
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% diary SaFIN_Learning_Process_Trace;

clear;
clc;

% load Sampled_Data_Equal_FB_SB;
load Failed_Banks;
load Survived_Banks;

warning('off');

Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];

FB = htet_pre_process_bank_data(Failed_Banks,1,0);
SB = htet_pre_process_bank_data(Survived_Banks,1,0);

for k = 1:1
  backward_offset = k-1;
  Failed_Banks_Group_By_Bank_ID = [];
  Survived_Banks_Group_By_Bank_ID = [];

  output_1 = htet_filter_bank_data_by_index(FB, backward_offset);
  output_2 = htet_filter_bank_data_by_index(SB, backward_offset);

  Failed_Banks_Group_By_Bank_ID = output_1.result;
  Survived_Banks_Group_By_Bank_ID = output_2.result;
end


ratio = length(Failed_Banks_Group_By_Bank_ID)/length(Survived_Banks_Group_By_Bank_ID);
required_size = ratio * length(Failed_Banks_Group_By_Bank_ID);

[sampled_FB, fb_idx] = datasample(Failed_Banks_Group_By_Bank_ID,100, 'Replace',false);
[sampled_SB, sb_idx] = datasample(Survived_Banks_Group_By_Bank_ID,100, 'Replace',false);

trainData = datasample(vertcat(sampled_FB,sampled_SB),200, 'Replace',false);
trainData = trainData(:,[3:12 2]);

Failed_Banks_Group_By_Bank_ID(fb_idx,:) = [];
Survived_Banks_Group_By_Bank_ID(sb_idx,:) = [];

[test_FB, fb_idx] = datasample(Failed_Banks_Group_By_Bank_ID,length(Failed_Banks_Group_By_Bank_ID), 'Replace',false);
[test_SB, sb_idx] = datasample(Survived_Banks_Group_By_Bank_ID,length(Survived_Banks_Group_By_Bank_ID), 'Replace',false);

testData = datasample(vertcat(test_FB,test_SB),length(test_FB)+length(test_SB), 'Replace',false);
testData = testData(:,[3:12 2]);

Epochs = 0;
Eta = 0.05;
Sigma0 = sqrt(0.16);
Forgetfactor = 0.99;
Lamda = 0.3;
Rate = 0.25;
Omega = 0.7;
Gamma = 0.1;
forget = 1;
tau = 0.2;
threshold = 0;
IND = 10;
OUTD = 1;


% network prediction
[net_out, net_structure] = Run_SaFIN_FRIE(1, trainData,testData,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);
output = htet_find_optimal_cut_off(testData(:,4), net_out, threshold)
