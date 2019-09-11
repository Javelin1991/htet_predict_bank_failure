% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_playground_test_any_code_snippet XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   dummy file that is used to test any code snippet in matlab
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

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


% FB_Full_Records = PREPARED_DATA{1, 2};
% SB_Full_Records = PREPARED_DATA{2, 2};
%
% Failed_IDs = PREPARED_DATA{1, 4};
% Survived_IDs = PREPARED_DATA{2, 4};

FB_Original_Full_Records = PREPARED_DATA{1, 5};
SB_Original_Full_Records = PREPARED_DATA{2, 5};


MAT = [];
MAT2 = [];
MAT3 = [];
MAT4 = [];

for k=1:length(FB_Original_Full_Records)
  % find mean value of lateral and longitudinal reconstruction
  % mean ll stands for mean longitudinal and lateral
  mat = cell2mat(FB_Original_Full_Records(k));
  MAT = [MAT; mat];
end

for k=1:length(SB_Original_Full_Records)
  % find mean value of lateral and longitudinal reconstruction
  % mean ll stands for mean longitudinal and lateral
  mat2 = cell2mat(SB_Original_Full_Records(k));
  MAT2 = [MAT2; mat2];
end

for k=1:length(FB_Recon)
  % find mean value of lateral and longitudinal reconstruction
  % mean ll stands for mean longitudinal and lateral
  mat3 = cell2mat(FB_Recon(k));
  MAT3 = [MAT3; mat3];
end

for k=1:length(SB_Recon)
  % find mean value of lateral and longitudinal reconstruction
  % mean ll stands for mean longitudinal and lateral
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
last_record_SB_Recon = htet_filter_bank_data_by_index(MAT4, 0);

SB = htet_pre_process_bank_data(last_record_SB.result, 0, length(last_record_FB.result));

train = vertcat(last_record_FB.result, SB);
train = htet_pre_process_bank_data(train, 1, 0);

SB_recon = htet_pre_process_bank_data(last_record_SB_Recon.result, 0, length(last_record_FB_Recon.result));
train_recon = vertcat(last_record_FB_Recon.result, SB_recon);
train_recon = htet_pre_process_bank_data(train_recon, 1, 0);


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
%
% % Labels = ["CAPADE", "OLAQLY", "PROBLO", "ADQLLP", "PLAQLY", "NIEOIN", "NINMAR", "ROE", "LIQUID", "GROWLA"];
% % xdatatemp = xdata(:,[77:83 86 end end:-1:end-5])
% % That is, of course, if you wanted columns 77 to 83, then 86, then the last column, then the last 5 columns counted backwards ;)
%
net_result_for_last_record = htet_get_emfis_network_result(train, params);
net_result_for_last_record_recon = htet_get_emfis_network_result(train_recon, params);
% net_result_for_one_year_prior(cv_num) = htet_get_emfis_network_result(CV2_with_top_3_features{cv_num}, params);
% net_result_for_two_year_prior(cv_num) = htet_get_emfis_network_result(CV3_with_top_3_features{cv_num}, params);



% not_done_yet = true;
% counter = 0;
%
% is_reconst_complete = test(FB_Full_Records);


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
