% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_pre_process_bank_data XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   pre process data by shuffling without replacement
% Syntax    :   htet_pre_process_bank_data(input, data_percent, fixed_size)
% input - any data set
% data_percent - determine how many percentage of the given data to be selected,
%                when set to 1, it will return all data with shuffled order
% fixed_size - when the fixed size is specified, the function will return
%              specified number of records that are randomly selected
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function sample = htet_pre_process_bank_data(input, data_percent, fixed_size)
  if ~iscell(input)
    input(any(isnan(input), 2), :) = [];
  end
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
