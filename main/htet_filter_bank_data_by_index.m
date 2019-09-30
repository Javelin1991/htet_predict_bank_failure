% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_filter_bank_data_by_index XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   filter records based on the selected year
% Syntax    :   htet_filter_bank_data_by_index(input, offset, type)
%
% input - input matrix that contains all bank records
% offset - when set to 0 - the function will retrieve the last record (e.g. t = 1998)
% type - 3T means record from t,t-1 and t-2; 2T means record from t and t-1, 1T means record from the selected t
% when set to 1 - the function will retrieve the record from one prior year (e.g. t-1 = 1997)
% when set to 2 - the function will retrieve the record from two prior year (e.g. t-2 = 1996)
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_filter_bank_data_by_index(input, offset, type)
    out1 = [];
    out2 = [];
    out3 = [];
    out4 = [];

    is_nan_count = 0;

    [v,ic,id]=unique(input(:,1))
    for i=1:length(v)
      A = input(id==i,:);

      switch type
          case '3T'
            idx = size(A, 1) - 0;
            idx_1 = size(A, 1) - 1;
            idx_2 = size(A, 1) - 2;
            if (idx > 0 && idx_1 > 0 && idx_2 > 0)
                record = A(idx, :);
                record_1 = A(idx_1, :);
                record_2 = A(idx_2, :);

                last_col = size(record,2);
                diff_1 = record(:,last_col) - record_1(:,last_col);
                diff_2 = record_1(:,last_col) - record_2(:,last_col);

                if sum(isnan(record)) == 0 && sum(isnan(record_1)) == 0 && sum(isnan(record_2)) == 0 && diff_1 == 1 && diff_2 == 1
                    out1 = [out1; {[record; record_1; record_2]}];
                else
                    is_nan_count = is_nan_count + 1;
                end
            end

          case '3T_one'
            idx = size(A, 1) - 1;
            idx_1 = size(A, 1) - 2;
            idx_2 = size(A, 1) - 3;
            if (idx > 0 && idx_1 > 0 && idx_2 > 0)
                record = A(idx, :);
                record_1 = A(idx_1, :);
                record_2 = A(idx_2, :);

                last_col = size(record,2);
                diff_1 = record(:,last_col) - record_1(:,last_col);
                diff_2 = record_1(:,last_col) - record_2(:,last_col);

                if sum(isnan(record)) == 0 && sum(isnan(record_1)) == 0 && sum(isnan(record_2)) == 0 && diff_1 == 1 && diff_2 == 1
                    out1 = [out1; {[record; record_1; record_2]}];
                else
                    is_nan_count = is_nan_count + 1;
                end
            end

          case '3T_two'
            idx = size(A, 1) - 2;
            idx_1 = size(A, 1) - 3;
            idx_2 = size(A, 1) - 4;
            if (idx > 0 && idx_1 > 0 && idx_2 > 0)
                record = A(idx, :);
                record_1 = A(idx_1, :);
                record_2 = A(idx_2, :);

                last_col = size(record,2);
                diff_1 = record(:,last_col) - record_1(:,last_col);
                diff_2 = record_1(:,last_col) - record_2(:,last_col);

                if sum(isnan(record)) == 0 && sum(isnan(record_1)) == 0 && sum(isnan(record_2)) == 0 && diff_1 == 1 && diff_2 == 1
                    out1 = [out1; {[record; record_1; record_2]}];
                else
                    is_nan_count = is_nan_count + 1;
                end
            end

          case '2T'
            idx = size(A, 1) - 0;
            idx_1 = size(A, 1) - 1;
            if (idx > 0 && idx_1 > 0)
                record = A(idx, :);
                record_1 = A(idx_1, :);
                if sum(isnan(record)) == 0 && sum(isnan(record_1)) == 0
                    out1 = [out1; {[record; record_1]}];
                else
                    is_nan_count = is_nan_count + 1;
                end
            end
          case '1T'
            idx = size(A, 1) - offset;
            if (idx > 0)
                record = A(idx, :);
                if sum(isnan(record)) == 0
                    out1 = [out1; record];
                else
                    is_nan_count = is_nan_count + 1;
                end
            end
      end

      % optional
      % out2 = [out2; {A}]
      % out3 = [out3; A(1,1)]
      % out4 = [out4; [A(1,1), {A}]];
    end
    out.result = out1;
    % optional
    % out.full_record = out2;
    % out.id = out3;
    % out.id_full_record = out4;
    % out.is_nan_count = is_nan_count;
end
