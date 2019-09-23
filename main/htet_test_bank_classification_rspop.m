% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_bank_classification_rspop XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to test bank failure prediction/classification using RSPOP
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clear;
clc;

load '5_Fold_CVs_with_top_3_features';

for cv_num = 1:1
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

  testData_D0 = D0(start_test:length(D0), :);
  testData_D1 = D1(start_test:length(D1), :);
  testData_D2 = D2(start_test:length(D2), :);

  % last available record prediction
  data_input = D0(:,[1:3]);
  data_target = D0(:,4);
  net = member('gen', 'spsec', data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));

  [net Ot] = popfnn('train', 'rspop', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));
  [net Ot] = popfnn('train', 'reduce1', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :), [0 NaN]);
  clear Ot;
  Ot = popfnn('compute', net, data_input(1 : start_test - 1, :));
  Oc = popfnn('compute', net, data_input(start_test : size(data_target, 1), :));

  train_predicted = Ot;
  test_predicted = Oc;

  output = htet_find_optimal_cut_off(testData_D0(:,4), test_predicted, 0);
  result.net_out = test_predicted;
  result.net_structure = net;
  result.output = output;
  net_result_for_last_record(cv_num) = result;

  % one year prior record prediction
  data_input = D1(:,[1:3]);
  data_target = D1(:,4);
  start_test = (size(D1, 1) * 0.2) + 1;
  net = member('gen', 'spsec', data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));

  [net Ot] = popfnn('train', 'rspop', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));
  [net Ot] = popfnn('train', 'reduce1', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :), [0 NaN]);
  clear Ot;

  Ot = popfnn('compute', net, data_input(1 : start_test - 1, :));
  Oc = popfnn('compute', net, data_input(start_test : size(data_target, 1), :));

  train_predicted = Ot;
  test_predicted = Oc;

  output = htet_find_optimal_cut_off(testData_D1(:,4), test_predicted, 0);
  result.net_out = test_predicted;
  result.net_structure = net;
  result.output = output;
  net_result_for_one_year_prior(cv_num) = result;

  % two year prior record prediction
  data_input = D2(:,[1:3]);
  data_target = D2(:,4);
  start_test = (size(D2, 1) * 0.2) + 1;
  net = member('gen', 'spsec', data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));

  [net Ot] = popfnn('train', 'rspop', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :));
  [net Ot] = popfnn('train', 'reduce1', net, data_input(1 : start_test - 1, :), data_target(1 : start_test - 1, :), [0 NaN]);
  clear Ot;

  Ot = popfnn('compute', net, data_input(1 : start_test - 1, :));
  Oc = popfnn('compute', net, data_input(start_test : size(data_target, 1), :));

  train_predicted = Ot;
  test_predicted = Oc;

  output = htet_find_optimal_cut_off(testData_D2(:,4), test_predicted, 0);
  result.net_out = test_predicted;
  result.net_structure = net;
  result.output = output;
  net_result_for_two_year_prior(cv_num) = result;

  disp('Processing of one CV group has completed');
end
