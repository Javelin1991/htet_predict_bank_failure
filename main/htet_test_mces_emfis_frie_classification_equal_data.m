% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_mces_emfis_frie_classification_equal_data XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using eMFIS_FRIE with balanced data set
% Stars     :
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% diary SaFIN_Learning_Process_Trace;

clear;
clc;

% load Sampled_Data_Equal_FB_SB;
load Last_Avail_Top_3_Feat;

warning('off');

Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
%
% FB = htet_pre_process_bank_data(Failed_Banks(:,[1 2 3 7 10]),1,0);
% SB = htet_pre_process_bank_data(Survived_Banks(:,[1 2 3 7 10]),1,0);
%
% for k = 1:1
%   backward_offset = k-1;
%   Failed_Banks_Group_By_Bank_ID = [];
%   Survived_Banks_Group_By_Bank_ID = [];
%
%   output_1 = htet_filter_bank_data_by_index(FB, backward_offset);
%   output_2 = htet_filter_bank_data_by_index(SB, backward_offset);
%
%   last_available_FB = output_1.result;
%   last_available_SB = output_2.result;
% end
%
%
% ratio = length(last_available_FB)/length(last_available_SB);
% required_size = ratio * length(last_available_FB);

[sampled_FB, fb_idx] = datasample(last_available_FB,200, 'Replace',false);
[sampled_SB, sb_idx] = datasample(last_available_SB,200, 'Replace',false);

trainData = datasample(vertcat(sampled_FB,sampled_SB),400, 'Replace',false);
trainData = trainData(:,[3:5 2]);

last_available_FB(fb_idx,:) = [];
last_available_SB(sb_idx,:) = [];

[test_FB, fb_idx] = datasample(last_available_FB,length(last_available_FB), 'Replace',false);
[test_SB, sb_idx] = datasample(last_available_SB,length(last_available_SB), 'Replace',false);

testData = datasample(vertcat(test_FB,test_SB),length(test_FB)+length(test_SB), 'Replace',false);
testData = testData(:,[3:5 2]);

data_input = vertcat(trainData(:,[1:3]),testData(:,[1:3]))
data_target = vertcat(trainData(:,4),testData(:,4));

start_test = size(trainData,1) + 1;
max_cluster = 13;
half_life = inf;
threshold_mf = 0.9999;
min_rule_weight = 0.1;
algo = 'emfis'
ie_rules_no = 2;
create_ie_rule = 0;

% network prediction
net = mar_trainOnline(ie_rules_no ,create_ie_rule,data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight)
net_predicted = net.predicted(start_test:size(data_target,1),:);
output = htet_find_optimal_cut_off(testData(:,4), net_predicted, 0)
