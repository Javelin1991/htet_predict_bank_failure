% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_ierspop XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using ieRSPOP++
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% diary SaFIN_Learning_Process_Trace;

clear;
clc;

load '5_Fold_CVs_with_top_3_features';

for cv_num = 1:5
  disp('');
  formatSpec = 'The current cv used is: %d';
  str = sprintf(formatSpec,cv_num)
  disp(str);

  % D0 = CV1{cv_num};
  % D1 = CV2{cv_num};
  % D2 = CV3{cv_num};

  % D0 = D0(:,[3:12 2]);
  % D1 = D1(:,[3:12 2]);
  % D2 = D2(:,[3:12 2]);
  %
  % D0 = D0(:,[3 7 10 2]);
  % D1 = D1(:,[3 7 10 2]);
  % D2 = D2(:,[3 7 10 2]);

  D0 = CV1_with_top_3_features{cv_num};
  D1 = CV2_with_top_3_features{cv_num};
  D2 = CV3_with_top_3_features{cv_num};

  D0 = D0(:,[3 4 5 2]);
  D1 = D1(:,[3 4 5 2]);
  D2 = D2(:,[3 4 5 2]);

  start_test = (size(D0, 1) * 0.2) + 1;
  window = 90;
  testData_D0 = D0(start_test:length(D0), 4);
  testData_D1 = D1(start_test:length(D1), 4);
  testData_D2 = D2(start_test:length(D2), 4);

  % last available record prediction
  data_input = D0(:,[1:3]);
  data_target = D0(:,4);
  % network prediction
  ensemble = update_ron_trainOnline(data_input, data_target, 'ierspop', window);
  predicted = ensemble.predicted(start_test:length(data_target),:);
  output = htet_find_optimal_cut_off(testData_D0, predicted, 0);
  result.net_out = predicted;
  result.net_structure = ensemble;
  result.output = output;
  net_result_for_last_record(cv_num) = result;
  clear data_input; clear data_target; clear ensemble; clear predicted; clear output; clear result;

  % one year prior record prediction
  data_input = D1(:,[1:3]);
  data_target = D1(:,4);
  % network prediction
  ensemble = update_ron_trainOnline(data_input, data_target, 'ierspop', window);
  predicted = ensemble.predicted(start_test:length(data_target),:);
  output = htet_find_optimal_cut_off(testData_D1, predicted, 0);
  result.net_out = predicted;
  result.net_structure = ensemble;
  result.output = output;
  net_result_for_one_year_prior(cv_num) = result;
  clear data_input; clear data_target; clear ensemble; clear predicted; clear output; clear result;

  % two year prior record prediction
  data_input = D1(:,[1:3]);
  data_target = D1(:,4);
  % network prediction
  ensemble = update_ron_trainOnline(data_input, data_target, 'ierspop', window);
  predicted = ensemble.predicted(start_test:length(data_target),:);
  output = htet_find_optimal_cut_off(testData_D2, predicted, 0);
  result.net_out = predicted;
  result.net_structure = ensemble;
  result.output = output;
  net_result_for_two_year_prior(cv_num) = result;
  clear data_input; clear data_target; clear ensemble; clear predicted; clear output; clear result;

  disp('Processing of one CV group has completed');
end
