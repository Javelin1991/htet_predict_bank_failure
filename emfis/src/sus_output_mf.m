% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_output_mf XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   Check whether Actual and predicted have the same MF output
% Syntax    :   sus_output_mf(net, data_target, current_count)
% 
% algo-
% 
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function e = sus_output_mf(net, data_target, current_count)

%    disp('Online Rule');

    num_outputs = size(data_target, 2);
    
    % find fuzzy set the target data belongs to
    max_mf = zeros(1, num_outputs);
    max_set = zeros(1, num_outputs);
    for i = 1 : num_outputs
        num_mf = size(net.output(i).mf, 2);
        mf_values = zeros(1, num_mf);
        for j = 1 : num_mf
           if( net.output(i).mf(j).params(1) ~=0 &&  net.output(i).mf(j).params(3) ~=0 )
                mf_values(j) = gauss2mf(data_target(i), net.output(i).mf(j).params);
           end
        end
        % get winning membership values and winning fuzzy sets
        [max_mf(i), max_set(i)] = max(mf_values);

        
        net.output(i).mf(max_set(i)).num_invoked = net.output(i).mf(max_set(i)).num_invoked + 1;
    end
    % consequent is array with winning fuzzy set of each output
    consequent = max_set;
    e=0;
    
    if (net.interpolation.output(current_count,1)~= 0)
      if net.interpolation.rules(current_count,1).consequent ~= consequent
        e=1;
      end
      
    end
    end
