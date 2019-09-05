clc;
clear;

load Failed_Banks;
load Survived_Banks;

% bank_type = [{Failed_Banks(1:20,:)}, {Survived_Banks(1:20,:)}];
bank_type = [{Failed_Banks}, {Survived_Banks}];

bank_type_name = {'Failed_Banks'; 'Survived_Banks'};
target_feature_name = {'CAPADE', 'PLAQLY', 'ROE'};
target_feature_col_no = [3; 7; 10];

FAILED_BANK_DATA_HORIZONTAL = [];
SURVIVED_BANK_DATA_HORIZONTAL = [];

FAILED_BANK_DATA_VERTICAL = [];
SURVIVED_BANK_DATA_VERTICAL = [];

TRAIN_DATA_TO_PREDICT_CAPADE = [];
TEST_DATA_TO_PREDICT_CAPADE = [];

TRAIN_DATA_TO_PREDICT_PLAQLY = [];
TEST_DATA_TO_PREDICT_PLAQLY = [];

TRAIN_DATA_TO_PREDICT_ROE = [];
TEST_DATA_TO_PREDICT_ROE = [];

for i=1:length(bank_type)
  disp(['Processing Bank Type : ', bank_type_name(i)]);
  % input data setup
  DATA_SET = {};
  DATA_SET_2 = {};

  input = cell2mat(bank_type(i));
  input_2 = input;
  input_with_NaN = input(any(isnan(input), 2), :);
  input(any(isnan(input), 2), :) = [];
  input_without_NaN = input;
  [m,n] = size(input);
  % get 20% of random data, and reserve for testing for all types of reconstruction
  idx = randperm(m, round(m*0.2)); %random permutation,   sampling without replacement
  test_sample = input(idx,:);
  input(idx,:) = [];
  train_sample = input;

  % longitudinal data includes full data for last three records, for CAPADE, PLAQLY and ROE respectively
  [longitudinal_train_data, lateral_train_data] = htet_prepare_data_for_longitudinal_construction(input_2);

  if i == 1
    FAILED_BANK_DATA_VERTICAL = {longitudinal_train_data};
  else
    SURVIVED_BANK_DATA_VERTICAL = {longitudinal_train_data};
  end

  for j=1:length(target_feature_col_no)
    feature_name = target_feature_name{j};
    y = target_feature_col_no(j);
    if y == 3
      x1 = 7; x2 = 10;
      train_data = train_sample(:,[1 x1 x2 y]);
      test_data = test_sample(:,[1 x1 x2 y]);

      DATA_SET.TRAIN_DATA_TO_PREDICT_CAPADE = train_data;
      DATA_SET.TEST_DATA_TO_PREDICT_CAPADE = test_data;
    elseif y == 7
      x1 = 3; x2 = 10;
      train_data = train_sample(:,[1 x1 x2 y]);
      test_data = test_sample(:,[1 x1 x2 y]);

      DATA_SET.TRAIN_DATA_TO_PREDICT_PLAQLY = train_data;
      DATA_SET.TEST_DATA_TO_PREDICT_PLAQLY = test_data;
    else
      x1 = 3; x2 = 7;
      train_data = train_sample(:,[1 x1 x2 y]);
      test_data = test_sample(:,[1 x1 x2 y]);

      DATA_SET.TRAIN_DATA_TO_PREDICT_ROE = train_data;
      DATA_SET.TEST_DATA_TO_PREDICT_ROE = test_data;
    end
  end

  if i == 1
    FAILED_BANK_DATA_HORIZONTAL = {DATA_SET};
  else
    SURVIVED_BANK_DATA_HORIZONTAL = {DATA_SET};
  end
end
