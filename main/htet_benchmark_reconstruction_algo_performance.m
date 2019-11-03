% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_benchmark_reconstruction_algo_performance XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   generate and benchmark experiment results for reconstruction algorithm
% it takes 10.5 min to run this file
% Stars     :   *
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

clc;
clear;

load Lateral_Systems;
load Longitudinal_Systems;
load Reconstructed_Data_denfis;

load Prepared_data_for_reconstruction;
load FAILED_BANK_DATA_HORIZONTAL;
load SURVIVED_BANK_DATA_HORIZONTAL;


warning('off','all');
warning;

FB_Recon = RECONSTRUCTED_DATA{1, 1};
SB_Recon = RECONSTRUCTED_DATA{2, 1};

FB_Original_Full_Records = PREPARED_DATA{1, 5};
SB_Original_Full_Records = PREPARED_DATA{2, 5};


MAT = [];
MAT2 = [];
MAT3 = [];
MAT4 = [];

for k=1:length(FB_Original_Full_Records)
  mat = cell2mat(FB_Original_Full_Records(k));
  MAT = [MAT; mat];
end

for k=1:length(SB_Original_Full_Records)
  mat2 = cell2mat(SB_Original_Full_Records(k));
  MAT2 = [MAT2; mat2];
end

for k=1:length(FB_Recon)
  mat3 = cell2mat(FB_Recon(k));
  MAT3 = [MAT3; mat3];
end

for k=1:length(SB_Recon)
  mat4 = cell2mat(SB_Recon(k));
  MAT4 = [MAT4; mat4];
end

last_record_FB = htet_filter_bank_data_by_index(MAT, 0);
one_year_prior_FB = htet_filter_bank_data_by_index(MAT, 1);
two_year_prior_FB = htet_filter_bank_data_by_index(MAT, 2);

last_record_SB = htet_filter_bank_data_by_index(MAT2, 0);
one_year_prior_SB = htet_filter_bank_data_by_index(MAT2, 1);
two_year_prior_SB = htet_filter_bank_data_by_index(MAT2, 2);

last_record_FB_Recon = htet_filter_bank_data_by_index(MAT3, 0);
one_year_prior_FB_Recon = htet_filter_bank_data_by_index(MAT3, 1);
two_year_prior_FB_Recon = htet_filter_bank_data_by_index(MAT3, 2);

last_record_SB_Recon = htet_filter_bank_data_by_index(MAT4, 0);
one_year_prior_SB_Recon = htet_filter_bank_data_by_index(MAT4, 1);
two_year_prior_SB_Recon = htet_filter_bank_data_by_index(MAT4, 2);

out = process_bank_data(last_record_SB.result, last_record_SB_Recon.result, 0, length(last_record_FB.result));
SB = out.originalInput;
SB_recon = out.reconInput;

out_1 = process_bank_data(one_year_prior_SB.result, one_year_prior_SB_Recon.result, 0, length(one_year_prior_FB.result));
SB_1 = out_1.originalInput;
SB_recon_1 = out_1.reconInput;

out_2 = process_bank_data(two_year_prior_SB.result, two_year_prior_SB_Recon.result, 0, length(two_year_prior_FB.result));
SB_2 = out_2.originalInput;
SB_recon_2 = out_2.reconInput;

train = vertcat(last_record_FB.result, SB);
train_recon = vertcat(last_record_FB_Recon.result, SB_recon);

train_1 = vertcat(one_year_prior_FB.result, SB_1);
train_recon_1 = vertcat(one_year_prior_FB_Recon.result, SB_recon_1);

train_2 = vertcat(two_year_prior_FB.result, SB_2);
train_recon_2 = vertcat(two_year_prior_FB_Recon.result, SB_recon_2);

t = process_bank_data(train, train_recon, 1, 0);
train = t.originalInput;
train_recon = t.reconInput;

t1 = process_bank_data(train_1, train_recon_1, 1, 0);
train_1 = t1.originalInput;
train_recon_1 = t1.reconInput;

t2 = process_bank_data(train_2, train_recon_2, 1, 0);
train_2 = t2.originalInput;
train_recon_2 = t2.reconInput;

params.algo = 'emfis';
params.max_cluster = 40;
params.half_life = inf;
params.threshold_mf = 0.9999;
params.min_rule_weight = 0.7;
params.spec = 10;
params.ie_rules_no = 2;
params.create_ie_rule = 0;
params.use_top_features = false;
params.dummy_run = false;
params.do_not_use_cv = false;

net_result_for_last_record = htet_get_emfis_network_result(train, params);
net_result_for_last_record_recon = htet_get_emfis_network_result(train_recon, params);

net_result_for_one_year_prior = htet_get_emfis_network_result(train_1, params);
net_result_for_one_year_prior_recon = htet_get_emfis_network_result(train_recon_1, params);

net_result_for_two_year_prior = htet_get_emfis_network_result(train_2, params);
net_result_for_two_year_prior_recon = htet_get_emfis_network_result(train_recon_2, params);

% alarm sound to alert that the program has ended
load handel;
sound(y,Fs);

function sample = process_bank_data(input1, input2, data_percent, fixed_size)
  [m,n] = size(input1);
  if (fixed_size ~= 0)
    %sample size is fixed to 2000
    idx = randperm(m, fixed_size); %random permutation, sampling without replacement
    sample1 = input1(idx,:);
    sample2 = input2(idx,:);
  else
    idx = randperm(m, round(data_percent*m)); %random permutation,   sampling without replacement
    sample1 = input1(idx,:);
    sample2 = input2(idx,:);
  end
  sample.originalInput = sample1;
  sample.reconInput = sample2;
end
