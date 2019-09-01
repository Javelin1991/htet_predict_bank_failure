clc;
clear;

load Failed_Banks;
load Survived_Banks;

% lateral is x-direction and longitudinal is y-direction
% get full data records that are grouped by the bank ID
backward_offset = 0;
SB_Full_Records = [];
FB_Full_Records = [];

output_1 = htet_filter_bank_data_by_index(Survived_Banks(:,[1:3 7 10]), backward_offset);
output_2 = htet_filter_bank_data_by_index(Failed_Banks(:,[1:3 7 10]), backward_offset);

SB_IDs = output_1.id;
FB_IDs = output_2.id;
SB_Full_Records = output_1.full_record;
FB_Full_Records = output_2.full_record;


% for Pre_trained_Systems_Lateral_Prediction
% to retreat the best pretrained system which is ANFIS
% if the missing data is CAPADE, use (1,3);
% if the missing data is PLAQLY, use (2,3);
% if the missing data is ROE, use (3,3);

load Pre_trained_Systems_Lateral_Prediction;
load Pre_trained_Systems_Longitudinal_Prediction;

% step 1 is lateral single feature reconstruction
FB_after_step1 = [];
% step 2 is longitudinal single feature reconstruction
FB_after_step2 = [];
% step 3 is longitudinal single feature reconstruction
FB_after_step3 = [];
% after step 1 and 2, we have eradicated the problem of single feature missing
% hence, the problem of two missing features has been reduced to one missing feature missing now
% dynamic_programming_inspired
% repeat the process again until no more missing feature left

RESULTS = [];
MEAN_LL = [];
S1 = [];
S2 = [];
% A = cell2mat(FB_Full_Records(i));
Data = FB_Full_Records;

for i=1:size(FB_Full_Records,1)
  A = cell2mat(Data(i));
  % single feature lateral reconstruction intra-bank
  FB_after_step1 = do_lateral_prediction(A, SYSTEMS, 1);
  C = FB_after_step1;
  S1 = [S1; FB_after_step1];

  % single feature longitudinal reconstruction intra-bank
  FB_after_step2 = do_longitudinal_prediction(A, C, LONGITUDINAL_SYSTEMS, 1);
  S2 = [S2; FB_after_step2];

  % find mean value of lateral and longitudinal reconstruction
  % mean ll stands for mean longitudinal and lateral
  RESULTS = [RESULTS; {[FB_after_step1, FB_after_step2]}];
end

for k=1:length(RESULTS)
  MEAN_LL = [MEAN_LL; find_mean(RESULTS(k))];
end
% mean ll stands for mean longitudinal and lateral
% MEAN_LL = find_mean(RESULTS)
Test_step1 = test(S1);
Test_step2 = test(S2);
TEST = test(MEAN_LL);
load handel;
sound(y,Fs);

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

      if (isnan(d1))
        avg = NaN;
      elseif (isnan(d2) && ~isnan(d1))
        avg = d1;
      elseif (~isnan(d2) && isnan(d1))
        avg = d2;
      else
        avg = (d1 + d2)/2;
      end
      record(1,j) = avg;
    end
    T = [T; record];
  end
  out = {T};
end

% XXXXXXXXXXXXXXXXXXXXXXXXXXX do_lateral_prediction XXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function result = do_lateral_prediction(A, SYSTEMS, bank_type)

  anfis_lat_fb_capade_regressor = SYSTEMS{bank_type, 1}{1, 3}.net;
  anfis_lat_fb_plaqly_regressor = SYSTEMS{bank_type, 1}{2, 3}.net;
  anfis_lat_fb_roe_regressor = SYSTEMS{bank_type, 1}{3, 3}.net;

  result = [];
  B = [];

  for d=1:size(A,1)
    % lateral reconstruction
    record = A(d,:);

    % if there is one missing value
    if sum(isnan(record)) == 1
        if (isnan(record(:,3)))
          predicted_value = evalfis(record(:,[4 5])', anfis_lat_fb_capade_regressor);

          record(1,3) = predicted_value;
        elseif (isnan(record(:,4)))
          predicted_value = evalfis(record(:,[3 5])', anfis_lat_fb_plaqly_regressor);
          record(1,4) = predicted_value;
        else
          predicted_value = evalfis(record(:,[3 4])', anfis_lat_fb_roe_regressor);
          record(1,5) = predicted_value;
        end
    end
    % if there is two missing value

    % if there is three missing value

    B = [B; record];
  end
  result = B;
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
    disp('Replace using the value from step 1, if the number of records is less than three for longitudinal prediction');
    out = 'Z';
  else
    disp('ERROR =====>>> Invalid length');
    disp('curr_idx'); disp(curr_idx);
    disp('last_idx'); disp(last_idx);
    out = 'Z';
  end
end

% XXXXXXXXXXXXXXXXXXXXXXXXXXX do_longitudinal_prediction XXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function result = do_longitudinal_prediction(A, C, LONGITUDINAL_SYSTEMS, bank_type)

  anfis_long_fb_capade_forward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_forward_CAPADE{3, 1}.net;
  anfis_long_fb_plaqly_forward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_forward_PLAQLY{3, 1}.net;
  anfis_long_fb_roe_forward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_forward_ROE{3, 1}.net;

  anfis_long_fb_capade_backward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_backward_CAPADE{3, 1}.net;
  anfis_long_fb_plaqly_backward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_backward_PLAQLY{3, 1}.net;
  anfis_long_fb_roe_backward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_backward_ROE{3, 1}.net;

  result = [];
  record_after_step_1 = C;
  B = [];

  for d=1:size(A,1)
    % Longitudinal reconstruction
    record = A(d,:);
    proceed = true;

    method = check_suitable_reconstruction_method(1, d, size(A,1));
    xf_1 = 0; xf_2 = 0; xb_1 = 0; xb_2 = 0;

    switch (method)
      case  'FB'
        xf_1 = d-2;
        xf_2 = d-1;
        xb_1 = d+2;
        xb_2 = d+1;
      case  'F'
        xf_1 = d-2;
        xf_2 = d-1;
      case  'B'
        xb_1 = d+2;
        xb_2 = d+1;
      case 'Z'
        replace_zero = 0;
    end
    disp('HN DEBUG size'); disp(size(A,1));
    disp('HN DEBUG curr_idx'); disp(d);
    disp('HN DEBUG xf_1'); disp(xf_1);
    disp('HN DEBUG xb_1'); disp(xb_1);
    disp('HN DEBUG xf_2'); disp(xf_2);
    disp('HN DEBUG xb_2'); disp(xb_2);

    % if it has one missing feature
    if sum(isnan(record)) == 1
        % CAPADE is missing
        if (isnan(record(:,3)))
          % could use reconstructed data from step 1
          % check if the data can be reconstructed by using forward or backward or both
          method = check_suitable_reconstruction_method(1, d, size(A,1));
          switch (method)
            case  'FB'
              input_f = [record_after_step_1(xf_1,3), record_after_step_1(xf_2,3)];
              input_b = [record_after_step_1(xb_1,3), record_after_step_1(xb_2,3)];

              predicted_value_f = evalfis(input_f', anfis_long_fb_capade_forward_regressor);
              predicted_value_b = evalfis(input_b', anfis_long_fb_capade_backward_regressor);
              predicted_value = (predicted_value_f + predicted_value_b)/2;
            case  'F'
              input_f = [record_after_step_1(xf_1,3), record_after_step_1(xf_2,3)];
              predicted_value = evalfis(input_f', anfis_long_fb_capade_forward_regressor);
            case 'B'
              input_b = [record_after_step_1(xb_1,3), record_after_step_1(xb_2,3)];
              predicted_value = evalfis(input_b', anfis_long_fb_capade_backward_regressor);
            case 'Z'
              predicted_value = record_after_step_1(d,3);
          end
          % use the reconstructed value
          record(1,3) = predicted_value;

        % PLAQLY is missing
        elseif (isnan(record(:,4)))

          method = check_suitable_reconstruction_method(1, d, size(A,1));
          switch (method)
            case  'FB'
              input_f = [record_after_step_1(xf_1,4), record_after_step_1(xf_2,4)];
              input_b = [record_after_step_1(xb_1,4), record_after_step_1(xb_2,4)];

              predicted_value_f = evalfis(input_f', anfis_long_fb_plaqly_forward_regressor);
              predicted_value_b = evalfis(input_b', anfis_long_fb_plaqly_backward_regressor);
              predicted_value = (predicted_value_f + predicted_value_b)/2;
            case  'F'
              input_f = [record_after_step_1(xf_1,4), record_after_step_1(xf_2,4)];
              predicted_value = evalfis(input_f', anfis_long_fb_plaqly_forward_regressor);
            case 'B'
              input_b = [record_after_step_1(xb_1,4), record_after_step_1(xb_2,4)];
              predicted_value = evalfis(input_b', anfis_long_fb_plaqly_backward_regressor);
            case 'Z'
                predicted_value = record_after_step_1(d,4);
          end
          % use the reconstructed value
          record(1,4) = predicted_value;

        % ROE is missing
        else

          method = check_suitable_reconstruction_method(1, d, size(A,1));
          switch (method)
            case  'FB'
              input_f = [record_after_step_1(xf_1,5), record_after_step_1(xf_2,5)];
              input_b = [record_after_step_1(xb_1,5), record_after_step_1(xb_2,5)];

              predicted_value_f = evalfis(input_f', anfis_long_fb_roe_forward_regressor);
              predicted_value_b = evalfis(input_b', anfis_long_fb_roe_backward_regressor);
              predicted_value = (predicted_value_f + predicted_value_b)/2;
            case  'F'
              input_f = [record_after_step_1(xf_1,5), record_after_step_1(xf_2,5)];
              predicted_value = evalfis(input_f', anfis_long_fb_roe_forward_regressor);
            case 'B'
              input_b = [record_after_step_1(xb_1,5), record_after_step_1(xb_2,5)];
              predicted_value = evalfis(input_b', anfis_long_fb_roe_backward_regressor);
            case 'Z'
              predicted_value = record_after_step_1(d,5);
          end
          % use the reconstructed value
          record(1,5) = predicted_value;
        end
    end
    B = [B; record];
  end
  result = B;
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
    if isa(B(i),'cell')
      A = cell2mat(B(i));
    else
      A = B;
    end
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
