% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_get_cv_data XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   retrieve records that are flagged as "1" and get the relevant record from the reference group
% Syntax    :   htet_get_cv_data(input, ref_group)
% input - matlab cvpartition produces 1 and 0 to indicate whether to include a record in the data set or not
% ref_group - reference group to retrieve data
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_get_cv_data(input, ref_group)
  out = [];
  for j = 1:length(input)
      if input(j,:) == 1
        out = [out; ref_group(j, :)];
      end
  end
end
