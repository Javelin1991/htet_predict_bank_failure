clear;
clc;

load CV1_Classification;
load CV2_Classification;
load CV3_Classification;
load Survived_Banks;
load Failed_Banks;

for k = 1:3
  backward_offset = k-1;
  Failed_Banks_Group_By_Bank_ID = [];
  Survived_Banks_Group_By_Bank_ID = [];

  output_1 = htet_filter_bank_data_by_index(Survived_Banks, backward_offset);
  output_2 = htet_filter_bank_data_by_index(Failed_Banks, backward_offset);

  Survived_Banks_Group_By_Bank_ID = output_1.result;
  SB_IDs = output_1.IDs;

  Failed_Banks_Group_By_Bank_ID = output_2.result;
  FB_IDs = output_2.IDs;

  SB = cvpartition(length(SB_IDs),'KFold',5);
  FB = cvpartition(length(FB_IDs),'KFold',5);

  if k == 1
    CV1 = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5);
  elseif k == 2
    CV2 = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5);
  else
    CV3 = htet_generate_cross_validation_data(Survived_Banks_Group_By_Bank_ID, Failed_Banks_Group_By_Bank_ID, 5);
  end
end

params.algo = 'emfis';
params.max_cluster = 40;
params.half_life = inf;
params.threshold_mf = 0.9999;
params.min_rule_weight = 0.7;
params.spec = 10;
params.ie_rules_no = 2;
params.create_ie_rule = 0;

for cv_num = 1:5
  net_result_for_last_record(cv_num) = htet_get_emfis_network_result(CV1{cv_num}, params);
  net_result_for_one_year_prior(cv_num) = htet_get_emfis_network_result(CV2{cv_num}, params);
  net_result_for_two_year_prior(cv_num) = htet_get_emfis_network_result(CV3{cv_num}, params);
end

RESULT_0 = htet_find_average(net_result_for_last_record, 5);
RESULT_1 = htet_find_average(net_result_for_one_year_prior, 5);
RESULT_2 = htet_find_average(net_result_for_two_year_prior, 5);

Labels = ["Last Available", "One Year Prior", "Two Year Prior"];
Acc = [RESULT_0.Accuracy; RESULT_1.Accuracy; RESULT_2.Accuracy];

figure;
bar(Acc); % plot the matrix
set(gca, 'XTick', 1:3); % center x-axis ticks on bins
set(gca, 'XTickLabel', Labels); % set x-axis labels
title('Bank Failure Classification Accuracy', 'FontSize', 14); % set title
colormap('jet'); % set the colorscheme
