% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_mces_safin_frie_classification XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to select important features using MCES and SaFIN_FRIE for bank failure classification
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

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


% ratio = length(Failed_Banks_Group_By_Bank_ID)/length(Survived_Banks_Group_By_Bank_ID);
% required_size = ratio * length(Failed_Banks_Group_By_Bank_ID);

sampled_FB = datasample(Failed_Banks_Group_By_Bank_ID,length(Failed_Banks_Group_By_Bank_ID), 'Replace',false);
sampled_SB = datasample(Survived_Banks_Group_By_Bank_ID, length(Failed_Banks_Group_By_Bank_ID), 'Replace',false);
%
% sampled_FB = Failed_Banks_Group_By_Bank_ID;
% sampled_SB = Survived_Banks_Group_By_Bank_ID;

total_length = length(sampled_FB) + length(sampled_SB);

D = datasample(vertcat(sampled_FB, sampled_SB), total_length, 'Replace',false);

% D = Sampled_Data_Equal_FB_SB;
D = D(:,[3:12 2]); % dummy run
start_test = (size(D, 1) * 0.2) + 1;
trainData_D0 = D(1:start_test-1,:);
testData_D0 = D(start_test:size(D, 1), :);

ite = 6;
induction = 'SaFIN_FRIE';
params = [];
% weight ranking of the features
[weight, net] = evalsel(trainData_D0(:,1:10),trainData_D0(:,11),ite,induction, params);
weight = weight(:,2);

ranking = weight';
%%% mces feature selection using five folds %%%

% plot bar graph for weight ranking
figure;
bar(ranking); % plot the matrix
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
title('Bank Failure Classification Features Weight Ranking', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme

[~,inx]=sort(ranking, 'descend');
sorted_labels = Labels(:, inx);
EER = [];
%%% iterate through each feature starting from the higest rank to lowest rank %%%
%%% using single fold %%%

input_feat_train = trainData_D0(:,1:10);
input_feat_test = testData_D0(:,1:10);

sorted_train_data = input_feat_train(:,inx);
sorted_test_data = input_feat_test(:,inx);

TRAIN = []; TEST = [];
RESULT = [];
TOTAL_OUTPUT = [];

for itr = 1: 10
    curr_train = [sorted_train_data(:,1:itr) trainData_D0(:,11)];
    curr_test = [sorted_test_data(:,1:itr) testData_D0(:,11)];

    TRAIN = [TRAIN; {curr_train}];
    TEST = [TEST; {curr_test}];

    IND = itr;
    OUTD = 1;
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

    [net_out_0, net_structure_0] = Run_SaFIN_FRIE(1, curr_train,curr_test,IND,OUTD,Epochs,Eta,Sigma0,Forgetfactor, forget,Lamda, tau,Rate, Omega, Gamma);

    output_0 = htet_find_optimal_cut_off(testData_D0(:,11), net_out_0, threshold);
    EER = [EER output_0.MIN_EER(1,1)];
    RESULT = [RESULT; {[net_out_0 testData_D0(:,11)]}];
    TOTAL_OUTPUT = [TOTAL_OUTPUT; {output_0}];
end

figure;
plot(EER');
set(gca, 'XTick', 1:10); % center x-axis ticks on bins
set(gca, 'XTickLabel', sorted_labels); % set x-axis labels
title('EER produced by ranked features (highest-lowest)', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme

load handel;
sound(y,Fs);
