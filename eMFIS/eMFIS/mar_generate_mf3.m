% XXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_GENERATE_MF3 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Mario Hartanto
% Date      :   Jan 24 2014
% Function  :   generates MF
% Syntax    :   mar_generate_mf3(data_struct, data_value, current_count, default_width, phase)
% 
% data_struct - net.input or net.output
% data_value - value of data to generate MF for
% current_count - number of data processed so far
%
% 
% Algorithm -
% 1) Determines position of new MF by checking for max centroid < data_value
% 2) Create new MF structure by shifting MFs and making a hole for new MF (like a linked list)
% 3) Set the width by reversing the gaussian equation
% 4) Reassign structure and pass back to calling function
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = mar_generate_mf3(data_struct, data_value, current_count, default_width, phase)

    disp(['Generate MF3 ', num2str(current_count)]);
    
%    Alpha_phase1 = 200;
    Alpha_phase1 = 2;
    
    num_mf = size(data_struct.mf, 2);
    % determine placement of new MF (after left, becoming left + 1)
    left = 0;
    for i = 1 : num_mf
        current_centroid = data_struct.mf(i).params(2);
        if current_centroid < data_value
            left = i;
        else
            break;
        end
    end
    
    % shift and rename MF structure (left + 1 is now a hole)
    new_mf = left + 1;
    for i = 1 : num_mf        
        if i >= new_mf
            new_struct.mf(i + 1) = data_struct.mf(i);
            new_struct.mf(i + 1).name = ['mf', num2str(i + 1)];
        else
            new_struct.mf(i) = data_struct.mf(i);
        end
    end
	
    % generate new MF in hole by averaging widths using centroid distance
    % on either side
    new_struct.mf(new_mf).name = ['mf', num2str(new_mf)];
    new_struct.mf(new_mf).type = 'gauss2mf';
    new_struct.mf(new_mf).params = [default_width, data_value, default_width, data_value];
    
    if phase == 1
        for i = 1 : num_mf
            new_struct.mf(i).params(3) = abs( (new_struct.mf(i).params(4) - new_struct.mf(i+1).params(2)) / sqrt(2 * log(Alpha_phase1)) );
            new_struct.mf(i+1).params(1) = new_struct.mf(i).params(3);            
        end
        new_struct.mf(1).params(1) = new_struct.mf(1).params(3);
        new_struct.mf(num_mf+1).params(3) = new_struct.mf(num_mf+1).params(1);
    else
        if new_mf ~= 1
            new_struct.mf(new_mf).params(1) = abs((data_value - mean([new_struct.mf(new_mf - 1).params(4) data_value])) / sqrt(2 * log(2)));
            new_struct.mf(new_mf - 1).params(3) = new_struct.mf(new_mf).params(1);
        end
        if new_mf ~= num_mf + 1
            new_struct.mf(new_mf).params(3) =  abs((mean([new_struct.mf(new_mf + 1).params(2) data_value]) - data_value) / sqrt(2 * log(2)));
            new_struct.mf(new_mf + 1).params(1) = new_struct.mf(new_mf).params(3);
        end
    end
        
    % default values
    new_struct.mf(new_mf).stability = 0;
    new_struct.mf(new_mf).tw_sum = 0;
    new_struct.mf(new_mf).mf_currency = 0;
    new_struct.mf(new_mf).created_at = current_count;
    
    % reassign structure to pass back to caller
    left_range = new_struct.mf(1).params(2) - (sqrt(2 * log(100)) * new_struct.mf(1).params(1));
    right_range = new_struct.mf(num_mf + 1).params(4) + (sqrt(2 * log(100)) * new_struct.mf(num_mf + 1).params(3));
    new_struct.range = [left_range, right_range];
    
    D.name = data_struct.name;
    D.range = new_struct.range;
    D.min = data_struct.min;
    D.max = data_struct.max;
    D.phase = data_struct.phase;
    
    D.spatio_temporal_dist = data_struct.spatio_temporal_dist;
    D.sum_square = data_struct.sum_square;
    D.sum = data_struct.sum;
    D.currency = data_struct.currency;
    D.last_mf_won = data_struct.last_mf_won;
    D.age = data_struct.age;
    
    D.mf = new_struct.mf;
end