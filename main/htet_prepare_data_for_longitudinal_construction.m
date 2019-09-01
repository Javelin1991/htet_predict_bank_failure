% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :
% Function  :
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function [Data_longitudinal, Data_lateral] = htet_prepare_data_for_longitudinal_construction(input)
    input(any(isnan(input), 2), :) = [];
    input_without_NaN = input;

    input_forward_CAPADE = [];
    input_backward_CAPADE = [];
    target_forward_CAPADE = [];
    target_backward_CAPADE = [];

    input_forward_PLAQLY = [];
    input_backward_PLAQLY = [];
    target_forward_PLAQLY= [];
    target_backward_PLAQLY = [];

    input_forward_ROE = [];
    input_backward_ROE = [];
    target_forward_ROE= [];
    target_backward_ROE= [];

    A = [];
    Data_lateral = [];
    [v,ic,id]=unique(input_without_NaN(:,1));

    % data cleaning for forward and backward reconstruction
    for i=1:length(v)
      A = input_without_NaN(id==i,:);

      if (size(A, 1) > 2)

          year = size(A, 2);

          % last record index
          idx_0 = size(A, 1);
          last_record = A(idx_0, year);

          % one year prior record index
          idx_1 = size(A, 1) - 1;
          one_year_prior = A(idx_1, year);

          % two year prior record index
          idx_2 = size(A, 1) - 2;
          two_year_prior = A(idx_2, year);

          x = last_record - one_year_prior;
          y = one_year_prior - two_year_prior;

          if (x == 1 && y == 1)
              out_forward= [A(idx_2, :); A(idx_1,:); A(idx_0,:)];
              out_backward = [A(idx_0, :); A(idx_1,:); A(idx_2,:)];

              bank_id = out_forward(1,1);
              input_forward_CAPADE = [input_forward_CAPADE; [bank_id, out_forward(1,3), out_forward(2,3)]];
              input_backward_CAPADE = [input_backward_CAPADE; [bank_id, out_backward(1,3), out_backward(2,3)]];
              target_forward_CAPADE = [target_forward_CAPADE; [bank_id, out_forward(3,3)]];
              target_backward_CAPADE = [target_backward_CAPADE; [bank_id, out_backward(3,3)]];

              input_forward_PLAQLY = [input_forward_PLAQLY; [bank_id, out_forward(1,7), out_forward(2,7)]];
              input_backward_PLAQLY = [input_backward_PLAQLY; [bank_id, out_backward(1,7), out_backward(2,7)]];
              target_forward_PLAQLY = [target_forward_PLAQLY; [bank_id, out_forward(3,7)]];
              target_backward_PLAQLY = [target_backward_PLAQLY; [bank_id, out_backward(3,7)]];

              input_forward_ROE = [input_forward_ROE; [bank_id, out_forward(1,10), out_forward(2,10)]];
              input_backward_ROE = [input_backward_ROE; [bank_id, out_backward(1,10), out_backward(2,10)]];
              target_forward_ROE = [target_forward_ROE; [bank_id, out_forward(3,10)]];
              target_backward_ROE = [target_backward_ROE; [bank_id, out_backward(3,10)]];

              Data_lateral = [Data_lateral; A];
          end
      end
    end

    Data_longitudinal.input_forward_CAPADE = input_forward_CAPADE;
    Data_longitudinal.input_backward_CAPADE = input_backward_CAPADE;
    Data_longitudinal.target_forward_CAPADE = target_forward_CAPADE;
    Data_longitudinal.target_backward_CAPADE = target_backward_CAPADE;

    Data_longitudinal.input_forward_PLAQLY = input_forward_PLAQLY;
    Data_longitudinal.input_backward_PLAQLY = input_backward_PLAQLY;
    Data_longitudinal.target_forward_PLAQLY= target_forward_PLAQLY;
    Data_longitudinal.target_backward_PLAQLY = target_backward_PLAQLY;

    Data_longitudinal.input_forward_ROE = input_forward_ROE;
    Data_longitudinal.input_backward_ROE = input_backward_ROE;
    Data_longitudinal.target_forward_ROE= target_forward_ROE;
    Data_longitudinal.target_backward_ROE= target_backward_ROE;
end
