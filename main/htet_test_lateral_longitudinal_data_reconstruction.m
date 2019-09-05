clc;
clear;

load Failed_Banks;
load Survived_Banks;

load Pre_trained_Systems_Lateral_Prediction;
load Pre_trained_Systems_Longitudinal_Prediction;


load Output_LL_S;
load Output_LL_F;
warning('off','all');
warning;

% lateral is x-direction and longitudinal is y-direction
% get full data records that are grouped by the bank ID
% backward_offset = 0;
% SB_Full_Records = [];
% FB_Full_Records = [];
%
% output_1 = htet_filter_bank_data_by_index(Survived_Banks(:,[1:3 7 10]), backward_offset);
% output_2 = htet_filter_bank_data_by_index(Failed_Banks(:,[1:3 7 10]), backward_offset);

Failed_Banks_top_3 = Failed_Banks(:,[1:3 7 10]);

SB_IDs = output_1.id;
FB_IDs = output_2.id;
SB_Full_Records = output_1.full_record;
FB_Full_Records = output_2.full_record;
RECONSTRUCTED_DATA = [];
TRC = [];
bank_type = [{FB_Full_Records}; {SB_Full_Records}];

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
    while (~isempty(is_reconst_complete.out_miss_2) || ~isempty(is_reconst_complete.out_miss_3))

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

        if ~isempty(is_reconst_complete.out_miss_2) || ~isempty(is_reconst_complete.out_miss_3)
          Data = MEAN_LL;
          MEAN_LL = [];
          RESULTS = [];
          state_after_step1 = [];
          state_after_step2 = [];
        end
    end

    D = [];
    for m=1:length(MEAN_LL)
      mat = cell2mat(MEAN_LL(m));
      D = [D; mat];
    end
    RECONSTRUCTED_DATA = [RECONSTRUCTED_DATA; {D}];
    trc.total_lat_construct = total_lat_construct;
    trc.total_long_construct = total_long_construct;
    TRC = [TRC; {trc}];
end

% alarm sound to alert that the program has ended
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
  anfis_lat_capade_regressor = SYSTEMS{bank_type, 1}{1, 3}.net;
  anfis_lat_plaqly_regressor = SYSTEMS{bank_type, 1}{2, 3}.net;
  anfis_lat_roe_regressor = SYSTEMS{bank_type, 1}{3, 3}.net;

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
          predicted_value = evalfis(record(:,[4 5])', anfis_lat_capade_regressor);
          record(1,3) = predicted_value;
          rc_count = rc_count + 1;

        elseif (isnan(record(:,4)))
          predicted_value = evalfis(record(:,[3 5])', anfis_lat_plaqly_regressor);
          record(1,4) = predicted_value;
          rc_count = rc_count + 1;

        else
          predicted_value = evalfis(record(:,[3 4])', anfis_lat_roe_regressor);
          record(1,5) = predicted_value;
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

% XXXXXXXXXXXXXXXXXXXXXXXXXXX do_longitudinal_prediction XXXXXXXXXXXXXXXXXXXXXXX
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function [result, rc2] = do_longitudinal_prediction(A, C, LONGITUDINAL_SYSTEMS, bank_type)

  rc_count = 0;

  anfis_long_capade_forward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_forward_CAPADE{3, 1}.net;
  anfis_long_plaqly_forward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_forward_PLAQLY{3, 1}.net;
  anfis_long_roe_forward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_forward_ROE{3, 1}.net;

  anfis_long_capade_backward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_backward_CAPADE{3, 1}.net;
  anfis_long_plaqly_backward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_backward_PLAQLY{3, 1}.net;
  anfis_long_roe_backward_regressor = LONGITUDINAL_SYSTEMS{bank_type, 1}.pretrained_backward_ROE{3, 1}.net;

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
              input_f = [record_after_step_1(xf_1,3), record_after_step_1(xf_2,3)];
              input_b = [record_after_step_1(xb_1,3), record_after_step_1(xb_2,3)];

              predicted_value_f = evalfis(input_f', anfis_long_capade_forward_regressor);
              predicted_value_b = evalfis(input_b', anfis_long_capade_backward_regressor);

              predicted_value = handle_isnan(predicted_value_f, predicted_value_b);
              rc_count = rc_count + 1;

            case  'F'
              input_f = [record_after_step_1(xf_1,3), record_after_step_1(xf_2,3)];
              predicted_value = evalfis(input_f', anfis_long_capade_forward_regressor);
              rc_count = rc_count + 1;

            case 'B'
              input_b = [record_after_step_1(xb_1,3), record_after_step_1(xb_2,3)];
              predicted_value = evalfis(input_b', anfis_long_capade_backward_regressor);
              rc_count = rc_count + 1;

            case 'Z'
              predicted_value = record_after_step_1(d,3);
          end
          % use the reconstructed value
          record(1,3) = predicted_value;
        end
        % PLAQLY is missing
        if (isnan(record(:,4)))

          method = check_suitable_reconstruction_method(1, d, size(A,1));
          switch (method)
            case  'FB'
              input_f = [record_after_step_1(xf_1,4), record_after_step_1(xf_2,4)];
              input_b = [record_after_step_1(xb_1,4), record_after_step_1(xb_2,4)];

              predicted_value_f = evalfis(input_f', anfis_long_plaqly_forward_regressor);
              predicted_value_b = evalfis(input_b', anfis_long_plaqly_backward_regressor);
              predicted_value = handle_isnan(predicted_value_f, predicted_value_b);
              rc_count = rc_count + 1;

            case  'F'
              input_f = [record_after_step_1(xf_1,4), record_after_step_1(xf_2,4)];
              predicted_value = evalfis(input_f', anfis_long_plaqly_forward_regressor);
              rc_count = rc_count + 1;

            case 'B'
              input_b = [record_after_step_1(xb_1,4), record_after_step_1(xb_2,4)];
              predicted_value = evalfis(input_b', anfis_long_plaqly_backward_regressor);
              rc_count = rc_count + 1;

            case 'Z'
                predicted_value = record_after_step_1(d,4);
          end
          % use the reconstructed value
          record(1,4) = predicted_value;
        end
        % ROE is missing
        if (isnan(record(:,5)))

          method = check_suitable_reconstruction_method(1, d, size(A,1));
          switch (method)
            case  'FB'
              input_f = [record_after_step_1(xf_1,5), record_after_step_1(xf_2,5)];
              input_b = [record_after_step_1(xb_1,5), record_after_step_1(xb_2,5)];

              predicted_value_f = evalfis(input_f', anfis_long_roe_forward_regressor);
              predicted_value_b = evalfis(input_b', anfis_long_roe_backward_regressor);
              predicted_value = handle_isnan(predicted_value_f, predicted_value_b);
              rc_count = rc_count + 1;

            case  'F'
              input_f = [record_after_step_1(xf_1,5), record_after_step_1(xf_2,5)];
              predicted_value = evalfis(input_f', anfis_long_roe_forward_regressor);
              rc_count = rc_count + 1;

            case 'B'
              input_b = [record_after_step_1(xb_1,5), record_after_step_1(xb_2,5)];
              predicted_value = evalfis(input_b', anfis_long_roe_backward_regressor);
              rc_count = rc_count + 1;

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