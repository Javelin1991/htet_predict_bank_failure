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

last_record = htet_filter_bank_data_by_index(SB_Full_Records, 0);
one_year_prior = htet_filter_bank_data_by_index(SB_Full_Records, 1);
two_year_prior = htet_filter_bank_data_by_index(SB_Full_Records, 2);


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
