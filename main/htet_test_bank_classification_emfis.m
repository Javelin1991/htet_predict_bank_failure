% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_emfis XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using eMFIS(FRIE)
% CV refers to cross validation and 5-fold CV is used below for:
% last year (t) prediction
% one year prior (t-1) prediction
% two year prior (t-2) prediction
% It takes around 70 min to run this file
% Stars     :
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clear;
clc;

load CV1_Classification;

% load Reconstructed_Data_LL;
% FB = RECONSTRUCTED_DATA{1,1};
% SB = RECONSTRUCTED_DATA{2,1};
%
% for k = 1:3
%   backward_offset = k-1;
%   Failed_Banks_Group_By_Bank_ID = [];
%   Survived_Banks_Group_By_Bank_ID = [];
%
%   output_1 = htet_filter_bank_data_by_index(SB, backward_offset);
%   output_2 = htet_filter_bank_data_by_index(FB, backward_offset);
%
%   Survived_Banks_Group_By_Bank_ID = output_1.result;
%   Failed_Banks_Group_By_Bank_ID = output_2.result;
%
%   if k == 1
%     CV1_with_top_3_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   elseif k == 2
%     CV2_with_top_3_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   else
%     CV3_with_top_3_features = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5, true);
%   end
% end

params.algo = 'emfis';
params.max_cluster = 13;
params.half_life = inf;
params.threshold_mf = 0.8;
params.min_rule_weight = 0.1;
params.spec = 10;
params.ie_rules_no = 2;
params.create_ie_rule = 0;
params.use_top_features = false;
params.dummy_run = false;
params.do_not_use_cv = false;

% % Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
% % xdatatemp = xdata(:,[77:83 86 end end:-1:end-5])
% % That is, of course, if you wanted columns 77 to 83, then 86, then the last column, then the last 5 columns counted backwards ;)
%
for cv_num = 1:1
  net_result_for_last_record(cv_num) = htet_get_emfis_network_result(CV1{cv_num,1}, params);
  % net_result_for_one_year_prior(cv_num) = htet_get_emfis_network_result(CV2_with_top_3_features{cv_num}, params);
  % net_result_for_two_year_prior(cv_num) = htet_get_emfis_network_result(CV3_with_top_3_features{cv_num}, params);
end

% RESULT_0 = htet_find_average(net_result_for_last_record, 5);
% RESULT_1 = htet_find_average(net_result_for_one_year_prior, 5);
% RESULT_2 = htet_find_average(net_result_for_two_year_prior, 5);
%
% Labels = ["Last Available", "One Year Prior", "Two Year Prior"];
% Acc = [RESULT_0.Accuracy; RESULT_1.Accuracy; RESULT_2.Accuracy];

figure;
bar(Acc); % plot the matrix
set(gca, 'XTick', 1:3); % center x-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
title('Bank Failure Classification Accuracy', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme

load handel
sound(y,Fs)
