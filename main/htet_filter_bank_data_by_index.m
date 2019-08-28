% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :
% Function  :
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_filter_bank_data_by_index(input, offset)
    out1 = [];
    out2 = [];
    [v,ic,id]=unique(input(:,1))
    for i=1:length(v)
      A = input(id==i,:);
      idx = size(A, 1) - offset;
      if (idx > 0)
          record = A(idx, :);
          if sum(isnan(record)) == 0
              out1 = [out1; record];
          end
      end
      out2 = [out2; {A}]
    end
    out.result = out1;
    out.full_record = out2;
end
