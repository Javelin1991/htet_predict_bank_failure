% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Mar 3 2019
% Function  :
% Syntax    :   pre_process_bank_data(input, data_percent, total)
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function sample = htet_pre_process_bank_data(input, data_percent, fixed_size)
  input(any(isnan(input), 2), :) = [];
  [m,n] = size(input);
  if (fixed_size ~= 0)
    %sample size is fixed to 2000
    idx = randperm(m, fixed_size); %random permutation, sampling without replacement
    sample = input(idx,:);
  else
    idx = randperm(m, round(data_percent*m)); %random permutation,   sampling without replacement
    sample = input(idx,:);
  end
  % sample = sortrows(sample, [1 n]); %sort based on first column, then use last column to break the ties
end
