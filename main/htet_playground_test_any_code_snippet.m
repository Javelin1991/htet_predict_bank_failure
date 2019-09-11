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


FB_Full_Records = PREPARED_DATA{1, 2};
SB_Full_Records = PREPARED_DATA{2, 2};
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

% for k=1:length(FB_Recon)
%   % find mean value of lateral and longitudinal reconstruction
%   % mean ll stands for mean longitudinal and lateral
%   mat3 = cell2mat(FB_Recon(k));
%   MAT3 = [MAT3; mat3];
% end
%
% for k=1:length(SB_Recon)
%   % find mean value of lateral and longitudinal reconstruction
%   % mean ll stands for mean longitudinal and lateral
%   mat4 = cell2mat(SB_Recon(k));
%   MAT4 = [MAT4; mat4];
% end

last_record_FB = htet_filter_bank_data_by_index(MAT, 0);
one_year_prior_FB = htet_filter_bank_data_by_index(MAT, 1);
two_year_prior_FB = htet_filter_bank_data_by_index(MAT, 2);

last_record_SB = htet_filter_bank_data_by_index(MAT2, 0);
one_year_prior_SB = htet_filter_bank_data_by_index(MAT2, 1);
two_year_prior_SB = htet_filter_bank_data_by_index(MAT2, 2);
