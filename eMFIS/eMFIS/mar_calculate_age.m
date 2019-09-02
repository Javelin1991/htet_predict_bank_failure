function [drift_detected, neuron] = mar_calculate_age( neuron, data, threshold_mf, current_count, end_of_phase_1 )
    
    num_mf = size(neuron.mf, 2); 
    mf_values = zeros(1, num_mf);
    for j = 1 : num_mf
        if(neuron.mf(j).params(1) ~= 0 && neuron.mf(j).params(3) ~= 0)
            mf_values(j) = gauss2mf(data, neuron.mf(j).params);
            neuron.mf(j).age(current_count, :) = neuron.mf(j).age(current_count-1, :) + ( 1 - mf_values(j) );
        end
    end
    [max_mf_value, max_index] = max(mf_values);
    second_diff_age = diff(diff(neuron.mf(max_index).age));
    
    drift_detected = false;
    
    if current_count < end_of_phase_1
        if max_mf_value < 0.5
            drift_detected = true;
        end            
        return;
    end
    
    if (current_count - neuron.mf(max_index).created_at) < 3
        if max_mf_value < 0.5
            drift_detected = true;
        end  
        return;
    end
        
    if (second_diff_age(current_count - 2) > second_diff_age(current_count - 3) && max_mf_value < threshold_mf && max_index == neuron.last_mf_won )
%    if second_diff_age(current_count - 2) > second_diff_age(current_count - 3) && second_diff_age(current_count - 2) > 0.1 && max_index == neuron.last_mf_won
        drift_detected = true;
    end
    
end

