% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Mar 3 2019
% Function  :
% Syntax    :   pre_process_bank_data(input, data_percent, total)
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function sample = pre_process_bank_data(input, data_percent, is_fixed_size)
  input(any(isnan(input), 2), :) = [];
  [m,n] = size(input);
  if (is_fixed_size)
    %sample size is fixed to 2000
    idx = randperm(m, 2000); %random permutation, sampling without replacement
    sample = input(idx,:);
  else
    idx = randperm(m, round(data_percent*m)); %random permutation,   sampling without replacement
    sample = input(idx,:);
  end
  sample = sortrows(sample, [1 n]); %sort based on first column, then use last column to break the ties
end
