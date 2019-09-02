% XXXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_ONLINE_MF4 XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Mario Hartanto
% Date      :   Jan 24 2014
% Function  :   creates membership functions incrementally
% Syntax    :   mar_online_mf4(net, data_input, data_target, current_count)
% 
% net - FIS network structure
% data_input - input data, can have multiple columns (attributes) but one row
% data_target - target data, can have multiple columns (outputs) but one row
% current_count - number of data processed
% 
% 
% Algorithm (2-SIC) -
% 1) Update spatio-temporal distance
% 2) Detect drift
% 3) Generate new MF if drift is detected
% 4) Update MF centroid and width
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = mar_online_mf4(net, data_input, data_target, current_count)
    
    stop_phase1_at = 10;
    default_width_input = 1;
    default_width_output = 0.01;
    
    if current_count >= stop_phase1_at
        phase = 2;
    else
        phase = 1;
    end
    
%    disp('Online Fuzzy 4');
    num_attributes = size(data_input, 2);
    num_outputs = size(data_target, 2);
    forgettor = net.forgettor;
    
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXX FIRST DATA XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    
    if current_count == 1
        % generate input structure
        for i = 1 : num_attributes
            net.input(i).name = ['X_', num2str(i)];
            net.input(i).range = [data_input(i), data_input(i)];
            net.input(i).min = data_input(i);
            net.input(i).max = data_input(i);
            net.input(i).phase = 0;
            
            net.input(i).spatio_temporal_dist = 0;
            net.input(i).sum_square = 0;
            net.input(i).sum = 0;
            net.input(i).currency = 0;
            net.input(i).last_mf_won = 0;
            net.input(i).age = 0;
            
            net.input(i).mf(1).name = 'mf1';
            net.input(i).mf(1).type = 'gauss2mf';
            net.input(i).mf(1).num_invoked = 1;
            net.input(i).mf(1).params = [default_width_input, data_input(i), default_width_input, data_input(i)];
            net.input(i).mf(1).stability = 0;
            net.input(i).mf(1).tw_sum = 0;
            net.input(i).mf(1).mf_currency = 0;
            net.input(i).mf(1).created_at = 1;
                      
        end
        % generate output structure
        for i = 1 : num_outputs
            net.output(i).name = ['Y_', num2str(i)];
            net.output(i).range = [data_target(i), data_target(i)];
            net.output(i).min = data_target(i);
            net.output(i).max = data_target(i);
            net.output(i).phase = 0;

            net.output(i).spatio_temporal_dist = 0;
            net.output(i).sum_square = 0;
            net.output(i).sum = 0;
            net.output(i).currency = 0;
            net.output(i).last_mf_won = 0;
            net.output(i).age = 0;
            
            net.output(i).mf(1).name = 'mf1';
            net.output(i).mf(1).type = 'gauss2mf';
            net.output(i).mf(1).num_invoked = 1;
            net.output(i).mf(1).params = [default_width_output, data_target(i), default_width_output, data_target(i)];
            net.output(i).mf(1).stability = 0;
            net.output(i).mf(1).tw_sum = 0;
            net.output(i).mf(1).mf_currency = 0;
            net.output(i).mf(1).created_at = 1;
                      
        end        
    end
    
    % INPUT dimension
    for i = 1 : num_attributes
        net.input(i).sum_square = (net.input(i).sum_square * forgettor) + data_input(i) ^ 2;
        net.input(i).sum = (net.input(i).sum * forgettor) + data_input(i);
        net.input(i).currency = (net.input(i).currency * forgettor) + 1;
        net.input(i).spatio_temporal_dist = 4 * ( (net.input(i).sum_square / net.input(i).currency) - (net.input(i).sum / net.input(i).currency)^2 ) ^ 0.5;
        
        drift_detected = false;
        
        if current_count > 1 
            % Observe Cluster age increase
            %[drift_detected, neuron] = mar_calculate_age(net.input(i), data_input(i), net.threshold_mf, current_count, stop_phase1_at);
            [drift_detected, neuron] = mar_calculate_age2(net.input(i), data_input(i), net.threshold_mf, current_count, stop_phase1_at);
            net.input(i) = neuron;
        end
        
        if drift_detected 
           % CREATE NEW CENTROID
%           net.input(i) = mar_generate_mf2(net.input(i), data_input(i), current_count, data_size, default_width_input);
           net.input(i) = mar_generate_mf3(net.input(i), data_input(i), current_count, default_width_input, phase);
        end
        
        num_mf = size(net.input(i).mf, 2);
        
        % Update centroid and it's stability
        mf_values = zeros(1, num_mf);
        for j = 1 : num_mf
%            if(net.input(i).mf(j).params(1) ~= 0 && net.input(i).mf(j).params(3) ~= 0)
                membership = gauss2mf(data_input(i), net.input(i).mf(j).params);
                mf_values(j) = membership;
                centroid = (net.input(i).mf(j).params(2) + net.input(i).mf(j).params(4)) / 2;
                centroid_width = net.input(i).mf(j).params(4) - centroid;        
                curr_stability = net.input(i).mf(j).stability * forgettor;
                centroid = (curr_stability * centroid + membership * data_input(i)) / (curr_stability + membership );
                net.input(i).mf(j).params(2) = centroid - centroid_width;
                net.input(i).mf(j).params(4) = centroid + centroid_width;
                net.input(i).mf(j).stability = curr_stability + membership;
%            end
        end
        [max_value, max_index] = max(mf_values);
        
        net.input(i).last_mf_won = max_index;

        % Update variance
        for j = 1 : (num_mf - 1)
            stability_gap = abs(net.input(i).mf(j+1).params(2) - net.input(i).mf(j).params(4)) / (net.input(i).mf(j).stability + net.input(i).mf(j+1).stability);
            net.input(i).mf(j).params(3) = stability_gap * net.input(i).mf(j+1).stability;
            net.input(i).mf(j+1).params(1) = stability_gap * net.input(i).mf(j).stability;
        end
        net.input(i).mf(1).params(1) = net.input(i).mf(1).params(3);
        net.input(i).mf(num_mf).params(3) = net.input(i).mf(num_mf).params(1);
    end
    
    
    % OUTPUT dimension
    for i = 1 : num_outputs
        net.output(i).sum_square = (net.output(i).sum_square * forgettor) + data_target(i) ^ 2;
        net.output(i).sum = (net.output(i).sum * forgettor) + data_target(i);
        net.output(i).currency = (net.output(i).currency * forgettor) + 1;
        net.output(i).spatio_temporal_dist = 4 * ( (net.output(i).sum_square / net.output(i).currency) - (net.output(i).sum / net.output(i).currency)^2 ) ^ 0.5;
        
        drift_detected = false;
        if current_count > 1 
            % Observe Cluster age increase
%             [drift_detected, neuron] = mar_calculate_age(net.output(i), data_target(i), net.threshold_mf, current_count, stop_phase1_at);
            [drift_detected, neuron] = mar_calculate_age2(net.output(i), data_target(i), net.threshold_mf, current_count, stop_phase1_at);
            net.output(i) = neuron;
        end
        
        if( drift_detected )
           % CREATE NEW CENTROID
%           net.output(i) = mar_generate_mf2(net.output(i), data_target(i), current_count, data_size, default_width_output);
           net.output(i) = mar_generate_mf3(net.output(i), data_target(i), current_count, default_width_output, phase);
        end
        
       num_mf = size(net.output(i).mf, 2);
       
        % Update centroid and it's stability
        mf_values = zeros(1, num_mf);
        for j = 1 : num_mf
%            if(net.output(i).mf(j).params(1) ~= 0 && net.output(i).mf(j).params(3) ~= 0)
                mf_values(j) = gauss2mf(data_target(i), net.output(i).mf(j).params);
                
                centroid = (net.output(i).mf(j).params(2) + net.output(i).mf(j).params(4)) / 2;
                centroid_width = net.output(i).mf(j).params(4) - centroid;
                curr_stability = net.output(i).mf(j).stability * forgettor;
                centroid = ( curr_stability * centroid + mf_values(j) * data_target(i) ) / ( curr_stability + mf_values(j) );
                net.output(i).mf(j).params(2) = centroid - centroid_width;
                net.output(i).mf(j).params(4) = centroid + centroid_width;
                net.output(i).mf(j).stability = curr_stability + mf_values(j);
%            end
        end
        [max_value, max_index] = max(mf_values);
        
        net.output(i).last_mf_won = max_index;
        
        % Update variance
        for j = 1 : (num_mf - 1)
            stability_gap = abs(net.output(i).mf(j+1).params(2) - net.output(i).mf(j).params(4)) / (net.output(i).mf(j).stability + net.output(i).mf(j+1).stability);
            net.output(i).mf(j).params(3) = stability_gap * net.output(i).mf(j+1).stability;
            net.output(i).mf(j+1).params(1) = stability_gap * net.output(i).mf(j).stability;
        end
        net.output(i).mf(1).params(1) = net.output(i).mf(1).params(3);
        net.output(i).mf(num_mf).params(3) = net.output(i).mf(num_mf).params(1);
    end
        
    D = net;
end