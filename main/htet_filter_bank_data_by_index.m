% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_filter_bank_data_by_index XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   filter records based on the selected year
% Syntax    :   htet_filter_bank_data_by_index(input, offset)
%
% input - input matrix that contains all bank records
% offset - when set to 0 - the function will retrieve the last record (e.g. t = 1998)
% when set to 1 - the function will retrieve the record from one prior year (e.g. t-1 = 1997)
% when set to 2 - the function will retrieve the record from two prior year (e.g. t-2 = 1996)
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_filter_bank_data_by_index(input, offset)
    out1 = [];
    out2 = [];
    out3 = [];
    out4 = [];

    is_nan_count = 0;

    [v,ic,id]=unique(input(:,1))
    for i=1:length(v)
      A = input(id==i,:);
      idx = size(A, 1) - offset;
      if (idx > 0)
          record = A(idx, :);
          if sum(isnan(record)) == 0
              out1 = [out1; record];
          else
              is_nan_count = is_nan_count + 1;
          end
      end
      out2 = [out2; {A}]
      out3 = [out3; A(1,1)]
      out4 = [out4; [A(1,1), {A}]];
    end
    out.result = out1;
    out.full_record = out2;
    out.id = out3;
    out.id_full_record = out4;
    out.is_nan_count = is_nan_count;
end
