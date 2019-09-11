% XXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_lateral_longitudinal_data_reconstruction_denfis XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   performs missing data imputation using lateral and longitudinal predictions
%
% Reconstruction process is done separately for failed banks and survived banks
% since they share different properties during financial distress
% Algorithm -
% 1) Filter out corner cases such as bank records that has all missing values
%    and those that has only one available record, reconstruction can't be performed on those banks
% 2) Perform lateral reconstruction
% 3) Perform longitudinal reconstruction
% 4) Calculate the mean values between predicted results from Step 2 and  predicted results from Step 3
%    (when calculating mean values, need to handle NaN cases, refer to the FYP for more details)
% 5) Check if there is still any missing data in the data set
% 6) If there is still missing data, update the current data set with the partially reconstructed data set from Step 4
%    Then, go back to Step 2 to continue the reconstruction process
% 7) Algorithm will terminate when there is no more missing data left
%
% The postfix "_denfis" in the filename indicates the pretrained systems that are used for reconstruction is of DENFIS
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clc;
clear;

load Lateral_Systems;
load Longitudinal_Systems;

load Prepared_data_for_reconstruction;

load FAILED_BANK_DATA_HORIZONTAL;
load SURVIVED_BANK_DATA_HORIZONTAL;


warning('off','all');
warning;


FB_Full_Records = PREPARED_DATA{1, 2};
SB_Full_Records = PREPARED_DATA{2, 2};

Failed_IDs = PREPARED_DATA{1, 4};
Survived_IDs = PREPARED_DATA{2, 4};

FB_Original_Full_Records = PREPARED_DATA{1, 5};
SB_Original_Full_Records = PREPARED_DATA{2, 5};

%
% SB_Full_Records = output_1.full_record;
% FB_Full_Records = output_2.full_record;

RECONSTRUCTED_DATA = [];
TRC = [];
% bank_type = [{output_1.full_records}; {SB_Records}];
bank_type = [{FB_Full_Records}; {SB_Full_Records}];

unseen_testData_1 = FAILED_BANK_DATA_HORIZONTAL{1, 1}.TEST_DATA_TO_PREDICT_ROE
unseen_testData_2 = SURVIVED_BANK_DATA_HORIZONTAL{1, 1}.TEST_DATA_TO_PREDICT_ROE

for n=1:2
    banks = bank_type(n);
    BANK = banks{1};

    % step 1 is lateral single feature reconstruction
    state_after_step1 = [];
    % step 2 is longitudinal single feature reconstruction
    state_after_step2 = [];
    % step 3 is longitudinal single feature reconstruction
    % repeat the process again until no more missing feature left

    RESULTS = [];
    MEAN_LL = [];
    Data = [];
    H = [];
    total_lat_construct = 0;
    total_long_construct = 0;
    % pre-filtering data for corner cases where reconstruction could not take place
    for i=1:length(BANK)
      t = filter(BANK(i));
      H = [H; t];
    end

    Data = H;

    not_done_yet = true;
    counter = 0;

    is_reconst_complete = test(Data);
    % repeat the process again until no more missing feature left
    while (has_missing_items(is_reconst_complete))
        disp('Performing reconstruction process.....');

        for i=1:size(Data,1)
          A = cell2mat(Data(i));

          % lateral reconstruction intra-bank
          [state_after_step1, rc1] = do_lateral_prediction(A, SYSTEMS, n);
          C = state_after_step1;
          total_lat_construct = total_lat_construct + rc1;

          % longitudinal reconstruction intra-bank
          [state_after_step2, rc2] = do_longitudinal_prediction(A, C, LONGITUDINAL_SYSTEMS, n);
          total_long_construct = total_long_construct + rc2;

          % RESULTS = [RESULTS; {[state_after_step1, state_after_step2]}];
          MEAN_LL = [MEAN_LL; find_mean({[state_after_step1, state_after_step2]})];
        end

        % for k=1:length(RESULTS)
        %   % find mean value of lateral and longitudinal reconstruction
        %   % mean ll stands for mean longitudinal and lateral
        %   MEAN_LL = [MEAN_LL; find_mean(RESULTS(k))];
        % end

        % check if the reconstruction completed
        is_reconst_complete = test(MEAN_LL);

        if has_missing_items(is_reconst_complete)
          Data = MEAN_LL;
          MEAN_LL = [];
          RESULTS = [];
          state_after_step1 = [];
          state_after_step2 = [];
        end
    end

    D = [];
    % for m=1:length(MEAN_LL)
    %   mat = cell2mat(MEAN_LL(m));
    %   % D = [D; mat]; % to display consecutively in rows
    % end
    RECONSTRUCTED_DATA = [RECONSTRUCTED_DATA; {MEAN_LL}];
    trc.total_lat_construct = total_lat_construct;
    trc.total_long_construct = total_long_construct;
    TRC = [TRC; {trc}];
end

A1 = PREPARED_DATA{1, 1};
A2 = PREPARED_DATA{2, 1};

B1 = RECONSTRUCTED_DATA{1, 1};
B2 = RECONSTRUCTED_DATA{2, 1};

Z1 = htet_htet_get_predicted_and_ground_truth_values(unseen_testData_1, A1, B1, FB_Original_Full_Records, Failed_IDs);
Z1_Results = htet_calculate_errors(Z1(:,2), Z1(:,3));
Z2 = htet_htet_get_predicted_and_ground_truth_values(unseen_testData_2, A2, B2, SB_Original_Full_Records, Survived_IDs);
Z2_Results = htet_calculate_errors(Z2(:,2), Z2(:,3));

% alarm sound to alert that the program has ended
load handel;
sound(y,Fs);

% XXXXXXXXXXXXXXXXXXXXXXXXXXX has_missing_items XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = has_missing_items(is_reconst_complete)
  has_one_missing_items = ~isempty(is_reconst_complete.out3_C) || ~isempty(is_reconst_complete.out3_P) || ~isempty(is_reconst_complete.out3_R);
  has_two_or_three_missing_items = ~isempty(is_reconst_complete.out_miss_2) || ~isempty(is_reconst_complete.out_miss_3);
  out = has_one_missing_items || has_two_or_three_missing_items;
end

% XXXXXXXXXXXXXXXXXXXXXXXXXXX find_mean XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = find_mean(cell)
  D = cell2mat(cell);
  T = [];
  for i=1:size(D,1)
    record = zeros(1, 5);
    for j=1:5
      d1 = D(i, j);
      d2 = D(i, j+5);
      record(1,j) = handle_isnan(d1, d2);
    end
    T = [T; record];
  end
  out = {T};
end

% XXXXXXXXXXXXXXXXXXXXXXXXXXX do_lateral_prediction XXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function [result, rc1] = do_lateral_prediction(A, SYSTEMS, bank_type)


  % for Pre_trained_Systems_Lateral_Prediction
  % to retreat the best pretrained system which is ANFIS
  % if the missing data is CAPADE, use {1,3};
  % if the missing data is PLAQLY, use {2,3};
  % if the missing data is ROE, use {3,3};
  denfis_lat_capade_regressor = SYSTEMS{bank_type, 1}{1, 2}.net;
  denfis_lat_plaqly_regressor = SYSTEMS{bank_type, 1}{2, 2}.net;
  denfis_lat_roe_regressor = SYSTEMS{bank_type, 1}{3, 2}.net;

  result = [];
  B = [];
  rc_count = 0;

  for d=1:size(A,1)
    % lateral reconstruction
    record = A(d,:);

    % if there is one missing value
    if sum(isnan(record)) == 1

        disp('Performing Lateral Reconstruction process.....');

        if (isnan(record(:,3)))
          predicted_value = denfiss(record(:,[4 5 3]), denfis_lat_capade_regressor);
          record(1,3) = predicted_value.Out';
          rc_count = rc_count + 1;

        elseif (isnan(record(:,4)))
          predicted_value = denfiss(record(:,[3 5 4]), denfis_lat_plaqly_regressor);
          record(1,4) = predicted_value.Out';
          rc_count = rc_count + 1;

        else
          predicted_value = denfiss(record(:,[3 4 5]), denfis_lat_roe_regressor);
          record(1,5) = predicted_value.Out';
          rc_count = rc_count + 1;

        end
    end

    B = [B; record];
  end
  result = B;
  rc1 = rc_count;
end


% XXXXXXXXXXXXXXXXXXXXXXXXXXX check_suitable_reconstruction_method XXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = check_suitable_reconstruction_method(start_idx, curr_idx, last_idx)
  diff_1 = curr_idx - start_idx;
  diff_2 = last_idx - curr_idx;

  if (diff_1 >=2 && diff_2 >= 2)
    out = 'FB';
  elseif (diff_1 >= 2)
    out = 'F';
  elseif (diff_2 >= 2)
    out = 'B';
  elseif (last_idx <= 2)
    % Replace using the value from step 1, if the number of records is less than three for longitudinal prediction;
    out = 'Z';
  else
    disp('curr_idx'); disp(curr_idx);
    disp('last_idx'); disp(last_idx);
    out = 'Z';
  end
end

% XXXXXXXXXXXXXXXXXXXXXXXXXXX handle_isnan XXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = filter(D)
  C = D;
  count = 0;
  Z = [];
  for i=1:size(D,1)
    A = cell2mat(D(i));
    TMP = A;
    A = A(:,3:5);

    for j=1:size(A,1)
      count = count + sum(isnan(A(j,:)));
    end

    dm = size(A,1) * size(A,2)
    diff = dm - count;

    % if all data are missing in the given bank
    if count == dm
      C(i,:) = [];
    end

    % the difference between no.of missing records and no.total records in the given bank is only 3 or below
    if  diff <= 3 && diff > 0
      C(i,:) = {TMP(size(TMP,1),:)};
    end
    count = 0;
  end
  out = C;
end

% XXXXXXXXXXXXXXXXXXXXXXXXXXX handle_isnan XXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = handle_isnan(x, y)
  if (isnan(x) && ~isnan(y))
    out = y;
  elseif (~(isnan(x)) && isnan(y))
    out = x;
  elseif (isnan(x) && isnan(y))
    out = x;
  else
    out = (y + x)/2;
  end
end

% XXXXXXXXXXXXXXXXXXXXXXXXXXX look_up_from_prev_state_if_nan_present XXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
function [v1, v2] = look_up_from_prev_state_if_nan_present(a, b, a_prev, b_prev)

  if isnan(a)
    v1 = a_prev;
  else
    v1 = a;
  end

  if isnan(b)
    v2 = b_prev;
  else
    v2 = b;
  end
end

% XXXXXXXXXXXXXXXXXXXXXXXXXXX do_longitudinal_prediction XXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function [result, rc2] = do_longitudinal_prediction(A, C, LONGITUDINAL_SYSTEMS, bank_type)

  rc_count = 0;

  denfis_long_capade_forward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_forward_CAPADE{2, 1}.net;
  denfis_long_plaqly_forward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_forward_PLAQLY{2, 1}.net;
  denfis_long_roe_forward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_forward_ROE{2, 1}.net;

  denfis_long_capade_backward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_backward_CAPADE{2, 1}.net;
  denfis_long_plaqly_backward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_backward_PLAQLY{2, 1}.net;
  denfis_long_roe_backward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_backward_ROE{2, 1}.net;

  result = [];
  B = [];

  for d=1:size(A,1)
    % Longitudinal reconstruction
    record = A(d,:);
    proceed = true;

    method = check_suitable_reconstruction_method(1, d, size(A,1));
    xf_1 = 0; xf_2 = 0; xb_1 = 0; xb_2 = 0;


    xf_1 = d-2;
    xf_2 = d-1;
    xb_1 = d+2;
    xb_2 = d+1;

    % if it has one missing feature
    if sum(isnan(record)) ~= 0
        disp('Performing Longitudinal Reconstruction process.....');

        % CAPADE is missing
        if (isnan(record(:,3)))
          % could use reconstructed data from step 1
          % check if the data can be reconstructed by using forward or backward or both
          method = check_suitable_reconstruction_method(1, d, size(A,1));

          switch (method)
            case  'FB'
              a = A(xf_1,3); b = A(xf_2,3); c = C(xf_1,3); d = C(xf_2,3);
              w = A(xb_1,3); x = A(xb_2,3); y = C(xb_1,3); z = C(xb_2,3);

              [f1,f2] = look_up_from_prev_state_if_nan_present(a, b, c, d);
              [b1,b2] = look_up_from_prev_state_if_nan_present(w, x, y, z);

              input_f = [f1, f2, record(:,3)];
              input_b = [b1, b2, record(:,3)];

              predicted_value_f = denfiss(input_f, denfis_long_capade_forward_regressor);
              predicted_value_b = denfiss(input_b, denfis_long_capade_backward_regressor);

              predicted_value = handle_isnan(predicted_value_f.Out', predicted_value_b.Out');
              rc_count = rc_count + 1;

            case  'F'
              a = A(xf_1,3); b = A(xf_2,3); c = C(xf_1,3); d = C(xf_2,3);

              [f1,f2] = look_up_from_prev_state_if_nan_present(a, b, c, d);
              input_f = [f1, f2, record(:,3)];

              pv = denfiss(input_f, denfis_long_capade_forward_regressor);
              predicted_value = pv.Out';
              rc_count = rc_count + 1;

            case 'B'

              w = A(xb_1,3); x = A(xb_2,3); y = C(xb_1,3); z = C(xb_2,3);

              [b1,b2] = look_up_from_prev_state_if_nan_present(w, x, y, z);
              input_b = [b1, b2, record(:,3)];

              pv = denfiss(input_b, denfis_long_capade_backward_regressor);
              predicted_value = pv.Out';
              rc_count = rc_count + 1;

            case 'Z'
              predicted_value = C(d,3);
          end
          % use the reconstructed value
          record(1,3) = predicted_value;
        end
        % PLAQLY is missing
        if (isnan(record(:,4)))

          method = check_suitable_reconstruction_method(1, d, size(A,1));
          switch (method)
            case  'FB'
              a = A(xf_1,4); b = A(xf_2,4); c = C(xf_1,4); d = C(xf_2,4);
              w = A(xb_1,4); x = A(xb_2,4); y = C(xb_1,4); z = C(xb_2,4);

              [f1,f2] = look_up_from_prev_state_if_nan_present(a, b, c, d);
              [b1,b2] = look_up_from_prev_state_if_nan_present(w, x, y, z);

              input_f = [f1, f2, record(:,4)];
              input_b = [b1, b2, record(:,4)];

              predicted_value_f = denfiss(input_f, denfis_long_plaqly_forward_regressor);
              predicted_value_b = denfiss(input_b, denfis_long_plaqly_backward_regressor);
              predicted_value = handle_isnan(predicted_value_f.Out', predicted_value_b.Out');
              rc_count = rc_count + 1;

            case  'F'
              a = A(xf_1,4); b = A(xf_2,4); c = C(xf_1,4); d = C(xf_2,4);

              [f1,f2] = look_up_from_prev_state_if_nan_present(a, b, c, d);
              input_f = [f1, f2, record(:,4)];

              pv = denfiss(input_f, denfis_long_plaqly_forward_regressor);
              predicted_value = pv.Out';
              rc_count = rc_count + 1;

            case 'B'
              w = A(xb_1,4); x = A(xb_2,4); y = C(xb_1,4); z = C(xb_2,4);

              [b1,b2] = look_up_from_prev_state_if_nan_present(w, x, y, z);
              input_b = [b1, b2, record(:,4)];

              pv = denfiss(input_b, denfis_long_plaqly_backward_regressor);
              predicted_value = pv.Out';
              rc_count = rc_count + 1;

            case 'Z'
                predicted_value = C(d,4);
          end
          % use the reconstructed value
          record(1,4) = predicted_value;
        end
        % ROE is missing
        if (isnan(record(:,5)))

          method = check_suitable_reconstruction_method(1, d, size(A,1));
          switch (method)
            case  'FB'
              a = A(xf_1,5); b = A(xf_2,5); c = C(xf_1,5); d = C(xf_2,5);
              w = A(xb_1,5); x = A(xb_2,5); y = C(xb_1,5); z = C(xb_2,5);

              [f1,f2] = look_up_from_prev_state_if_nan_present(a, b, c, d);
              [b1,b2] = look_up_from_prev_state_if_nan_present(w, x, y, z);

              input_f = [f1, f2, record(:,5)];
              input_b = [b1, b2, record(:,5)];

              predicted_value_f = denfiss(input_f, denfis_long_roe_forward_regressor);
              predicted_value_b = denfiss(input_b, denfis_long_roe_backward_regressor);
              predicted_value = handle_isnan(predicted_value_f.Out', predicted_value_b.Out');
              rc_count = rc_count + 1;

            case  'F'
              a = A(xf_1,5); b = A(xf_2,5); c = C(xf_1,5); d = C(xf_2,5);

              [f1,f2] = look_up_from_prev_state_if_nan_present(a, b, c, d);
              input_f = [f1, f2, record(:,5)];
              pv = denfiss(input_f, denfis_long_roe_forward_regressor);
              predicted_value = pv.Out';
              rc_count = rc_count + 1;

            case 'B'
              w = A(xb_1,5); x = A(xb_2,5); y = C(xb_1,5); z = C(xb_2,5);

              [b1,b2] = look_up_from_prev_state_if_nan_present(w, x, y, z);
              input_b = [b1, b2, record(:,5)];
              pv = denfiss(input_b, denfis_long_roe_backward_regressor);
              predicted_value = pv.Out';
              rc_count = rc_count + 1;

            case 'Z'
              predicted_value = C(d,5);
            end
          % use the reconstructed value
          record(1,5) = predicted_value;
        end
    end
    B = [B; record];
  end

  result = B;
  rc2 = rc_count;
end

% XXXXXXXXXXXXXXXXXXXXXXXXXXX test XXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = test(B)
  out3_C = [];
  out3_P = [];
  out3_R = [];
  out_miss_2 = [];
  out_miss_3 = [];
  out_no_miss = [];

  for i=1:length(B)
    A = cell2mat(B(i));
    for d=1:size(A,1)
      record = A(d,:);
      if sum(isnan(record)) == 1
          if (isnan(record(1,3)))
            out3_C = [out3_C; record];
          elseif (isnan(record(1,4)))
            out3_P = [out3_P; record];
          else
            out3_R = [out3_R; record];
          end
      elseif sum(isnan(record)) == 2
        out_miss_2 = [out_miss_2; record];
      elseif sum(isnan(record)) == 3
        out_miss_3 = [out_miss_3; record];
      else
        out_no_miss = [out_no_miss; record];
      end
    end
  end
  out.out3_C = out3_C;
  out.out3_P = out3_P;
  out.out3_R = out3_R;
  out.out_miss_2 = out_miss_2;
  out.out_miss_3 = out_miss_3;
  out.out_no_miss = out_no_miss;
end
