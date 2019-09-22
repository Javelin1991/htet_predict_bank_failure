% XXXXXXXXXXXXXXXXXXXXXXXXXXX RON_GENERATE_MF XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Jan 28 2010
% Function  :   generates MF
% Syntax    :   ron_generateMF(data_struct, data_value, current_count)
% 
% data_struct - net.input or net.output
% data_value - value of data to generate MF for
% current_count - number of data processed so far
%
% Note - if current_count > clean_freq, phase 2. Else phase 1.
% 
% Algorithm -
% 1) Determines position of new MF by checking for max centroid < data_value
% 2) Create new MF structure by shifting MFs and making a hole for new MF (like a linked list)
% 3) Generate new MF by reversing the gaussian equation, u(x) = e^(-(point - centroid)^2 / 2*width^2)
% 4) Phase 1 width uses slope equation 
% 5) Phase 2 width is midpoint between data_value and centroid of adjacent MF function, u(x) is 0.5 (intersect at mid-height)
% 5) Reassign structure and pass back to calling function
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_generate_mf(data_struct, data_value, current_count)

    disp('Generate MF');
    slope = 0.5;
    stop_phase1_at = 10;
    
    if data_struct.max == data_struct.min
        data_struct.phase = 0;
    else
        data_struct.phase = 1;
    end
        
    if (current_count >= stop_phase1_at) && data_struct.phase
        phase = 1;
    else
        phase = 0;
    end
    
    num_mf = size(data_struct.mf, 2);
    % determine placement of new MF (after left, becoming left + 1)
    left = 0;
    for i = 1 : num_mf
        current_centroid = data_struct.mf(i).params(2);
        if num_mf == 1
            if current_centroid < data_value
                left = 1;
            end
        else
            if current_centroid < data_value
                left = i;
            else
                break;
            end
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
    if new_mf == 1
        if phase
            width = abs((((new_struct.mf(2).params(2) + data_value) / 2) - new_struct.mf(2).params(2)) / sqrt(2 * log(2)));
            new_struct.mf(new_mf).params = [width, data_value, width, data_value];
        else
            width = (slope * (data_struct.max - data_struct.min)) / sqrt(2 * log(100));
            for i = 1 : num_mf + 1
                if i == new_mf
                    new_struct.mf(i).params = [width, data_value, width, data_value];
                else
                    new_struct.mf(i).params(1) = width;
                    new_struct.mf(i).params(3) = width;
                end
            end
        end        
    elseif new_mf == num_mf + 1
        if phase
            width = abs((((new_struct.mf(num_mf).params(2) + data_value) / 2) - new_struct.mf(num_mf).params(2)) / sqrt(2 * log(2)));
            new_struct.mf(new_mf).params = [width, data_value, width, data_value];
        else
            width = (slope * (data_struct.max - data_struct.min)) / sqrt(2 * log(100));
            for i = 1 : num_mf + 1
                if i == new_mf
                    new_struct.mf(i).params = [width, data_value, width, data_value];
                else
                    new_struct.mf(i).params(1) = width;
                    new_struct.mf(i).params(3) = width;
                end
            end
        end
    else
        if phase
            left_width = abs((((new_struct.mf(left).params(2) + data_value) / 2) - new_struct.mf(left).params(2)) / sqrt(2 * log(2)));
            right_width = abs((((new_struct.mf(left + 2).params(2) + data_value) / 2) - new_struct.mf(left + 2).params(2)) / sqrt(2 * log(2)));
            new_struct.mf(new_mf).params = [left_width, data_value, right_width, data_value];
        else
            width = (slope * (data_struct.max - data_struct.min)) / sqrt(2 * log(100));
            for i = 1 : num_mf + 1
                if i == new_mf
                    new_struct.mf(i).params = [width, data_value, width, data_value];
                else
                    new_struct.mf(i).params(1) = width;
                    new_struct.mf(i).params(3) = width;
                end
            end
        end
    end
    
    % default values
    new_struct.mf(new_mf).plasticity = 0.5;
    new_struct.mf(new_mf).tendency = 0.5;
    new_struct.mf(new_mf).num_expanded = 0;
    
    new_struct.name = data_struct.name;
    new_struct.min = data_struct.min;
    new_struct.max = data_struct.max;
    new_struct.phase = data_struct.phase;
    
    % reassign structure to pass back to caller
    left_range = new_struct.mf(1).params(2) - (sqrt(2 * log(100)) * new_struct.mf(1).params(1));
    right_range = new_struct.mf(num_mf + 1).params(2) + (sqrt(2 * log(100)) * new_struct.mf(num_mf + 1).params(3));
    new_struct.range = [left_range, right_range];
    
    O.name = new_struct.name;
    O.range = new_struct.range;
    O.min = new_struct.min;
    O.max = new_struct.max;
    O.phase = new_struct.phase;
    O.mf = new_struct.mf;    
    
    D = O;
end