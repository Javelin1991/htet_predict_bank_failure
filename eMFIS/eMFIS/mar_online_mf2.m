% XXXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_ONLINE_MF2 XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Mario Hartanto
% Date      :   Jan 24 2014
% Function  :   creates membership functions incrementally
% Syntax    :   mar_online_mf2(net, data_input, data_target, current_count)
% 
% net - FIS network structure
% data_input - input data, can have multiple columns (attributes) but one row
% data_target - target data, can have multiple columns (outputs) but one row
% current_count - number of data processed
% 
% Algorithm (two-phase DIC) -
% 1) For first data, generate Gaussian 2 MF using single point cluster
% 2) For second to clean_freq data, generate Gaussian 2 MF using DIC width formula
% 3) After clean_freq, if winning MF value is below new_threshold, new MF is generated (see mar_generate_mf)
% 4) Else, if winning MF value is below 1 (i.e. not in kernel), expand MF kernel by plasticity * distance between centroid and data_value
% 5) Recalculate cluster min and max and recalculate width using DIC slope formula adapated for gaussian
% 5) Reduce plasticity by 2/3s, reduce tendency. If tendency <= 0, plasticity = 0
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = mar_online_mf2(net, data_input, data_target, current_count)
  
    disp('Online Fuzzy 2');
    num_attributes = size(data_input, 2);
    num_outputs = size(data_target, 2);
    
    IT = 0.5;
    OT = 0.5;
    beta = 0.5;
    TD = 0.5;
    max_cluster = net.max_cluster;
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
            
            net.input(i).mf(1).name = 'mf1';
            net.input(i).mf(1).type = 'gauss2mf';
            net.input(i).mf(1).num_invoked = 1;
            default_width = 1e-10;
            net.input(i).mf(1).params = [default_width, data_input(i), default_width, data_input(i)];
            net.input(i).mf(1).stability = 0;
            
            % DIC Parameter
            net.input(i).mf(1).plasticity = beta;
            net.input(i).mf(1).tendency = TD;
            net.input(i).mf(1).num_expanded = 0;            
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
            
            net.output(i).mf(1).name = 'mf1';
            net.output(i).mf(1).type = 'gauss2mf';
            net.output(i).mf(1).num_invoked = 1;
            default_width = 1e-10;
            net.output(i).mf(1).params = [default_width, data_target(i), default_width, data_target(i)];
            net.output(i).mf(1).stability = 0;
            
            % DIC Parameter
            net.output(i).mf(1).plasticity = beta;
            net.output(i).mf(1).tendency = TD;
            net.output(i).mf(1).num_expanded = 0;            
        end        
    end
    
    % INPUT dimension
    for i = 1 : num_attributes
        net.input(i).sum_square = (net.input(i).sum_square * forgettor) + data_input(i) ^ 2;
        net.input(i).sum = (net.input(i).sum * forgettor) + data_input(i);
        net.input(i).currency = (net.input(i).currency * forgettor) + 1;
        net.input(i).spatio_temporal_dist = 2 * (2*pi)^0.5 * ( (net.input(i).sum_square / net.input(i).currency) - (net.input(i).sum / net.input(i).currency)^2 ) ^ 0.5;
        num_mf = size(net.input(i).mf, 2);
        dist_from_centroid = zeros(1, num_mf);
        for j = 1 : num_mf
            if(net.input(i).mf(j).params(1) ~= 0 && net.input(i).mf(j).params(3) ~= 0)
                dist_from_centroid(j) = abs( data_input(i) - ((net.input(i).mf(j).params(2) + net.input(i).mf(j).params(4))/2) );
            end
        end
        
        if( min(dist_from_centroid) > ( net.input(i).spatio_temporal_dist / (max_cluster - num_mf) ) || current_count == 1 )
            % CREATE NEW CENTROID
            net.input(i) = mar_generate_mf(net.input(i), data_input(i), current_count);
        end

        
        % Update centroid and it's stability 
        numerator = zeros(num_mf, 1);
        alpha = zeros(num_mf, 1);
        zero_dist = false;
        for j = 1 : num_mf
            distance = data_input(i) - ((net.input(i).mf(j).params(2) + net.input(i).mf(j).params(4))/2);
            numerator(j) = 1 / distance ^ 2;
            if (distance == 0)
                zero_dist = true;
            end
        end
        if zero_dist
            for j = 1 : num_mf
                if numerator(j) == inf
                    alpha(j) = 1;
                else
                    alpha(j) = 0;
                end
            end
        else
            denominator = sum(numerator);
            alpha = numerator / denominator;
        end        
                
        % Update centroid and it's stability 
        for j = 1 : num_mf
%             numerator = 1 + ( data_input(i) - ((net.input(i).mf(j).params(2) + net.input(i).mf(j).params(4))/2) )^2;
%             inverse_alpha = 0;
%             for k = 1 : num_mf
%                 denominator = 1 + ( data_input(i) - ((net.input(i).mf(k).params(2) + net.input(i).mf(k).params(4))/2) )^2;
%                 inverse_alpha = inverse_alpha + numerator / denominator;
%             end
%             alpha = 1 / inverse_alpha;
            net.input(i).mf(j).params(2) = forgettor * net.input(i).mf(j).stability * net.input(i).mf(j).params(2) + alpha(j) * data_input(i);
            net.input(i).mf(j).params(4) = forgettor * net.input(i).mf(j).stability * net.input(i).mf(j).params(4) + alpha(j) * data_input(i);
            net.input(i).mf(j).stability = net.input(i).mf(j).stability * forgettor + alpha(j);
        end
        
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
        net.output(i).spatio_temporal_dist = 2 * (2*pi)^0.5 * ( (net.output(i).sum_square / net.output(i).currency) - (net.output(i).sum / net.output(i).currency)^2 ) ^ 0.5;
        
        num_mf = size(net.output(i).mf, 2);
        dist_from_centroid = zeros(1, num_mf);
        for j = 1 : num_mf
            if(net.output(i).mf(j).params(1) ~= 0 && net.output(i).mf(j).params(3) ~= 0)
                dist_from_centroid(j) = abs( data_target(i) - ((net.output(i).mf(j).params(2) + net.output(i).mf(j).params(4))/2) );
            end
        end
        
        if( min(dist_from_centroid) > ( net.output(i).spatio_temporal_dist / (max_cluster - num_mf) ) || current_count == 1 )
            % CREATE NEW CENTROID
            net.output(i) = mar_generate_mf(net.output(i), data_target(i), current_count);
        end
        
        % Calculate centroid and its stability
        numerator = zeros(num_mf, 1);
        alpha = zeros(num_mf, 1);
        zero_dist = false;
        for j = 1 : num_mf
            distance = data_target(i) - ((net.output(i).mf(j).params(2) + net.output(i).mf(j).params(4))/2);
            numerator(j) = 1 / distance ^ 2;
            if (distance == 0)
                zero_dist = true;
            end
        end
        
        if zero_dist
            for j = 1 : num_mf
                if numerator(j) == inf
                    alpha(j) = 1;
                else
                    alpha(j) = 0;
                end
            end
        else
            denominator = sum(numerator);
            alpha = numerator / denominator;
        end 
        
        for j = 1 : num_mf
%             numerator = 1 + ( data_target(i) - ((net.output(i).mf(j).params(2) + net.output(i).mf(j).params(4))/2) )^2;
%             inverse_alpha = 0;
%             for k = 1 : num_mf
%                 denominator = 1 + ( data_target(i) - ((net.output(i).mf(k).params(2) + net.output(i).mf(k).params(4))/2) )^2;
%                 inverse_alpha = inverse_alpha + numerator / denominator;
%             end
%             alpha = 1 / inverse_alpha;
            net.output(i).mf(j).params(2) = forgettor * net.output(i).mf(j).stability * net.output(i).mf(j).params(2) + alpha(j) * data_target(i);
            net.output(i).mf(j).params(4) = forgettor * net.output(i).mf(j).stability * net.output(i).mf(j).params(4) + alpha(j) * data_target(i);
            net.output(i).mf(j).stability = net.output(i).mf(j).stability * forgettor + alpha(j);
        end 
        
        % Update variance
        for j = 1 : (num_mf - 1)
            stability_gap = abs(net.output(i).mf(j+1).params(2) - net.output(i).mf(j).params(4)) / (net.output(i).mf(j).stability + net.output(i).mf(j+1).stability);
            net.output(i).mf(j).params(3) = stability_gap * net.output(i).mf(j+1).stability;
            net.output(i).mf(j+1).params(1) = stability_gap * net.output(i).mf(j).stability;
        end
        net.output(i).mf(1).params(1) = net.output(i).mf(1).params(3);
        net.output(i).mf(num_mf).params(3) = net.output(i).mf(num_mf).params(1);
    end
    
    % XXXXXXXXXXXXXXXXXXXXXXXXX SECOND DATA ONWARDS XXXXXXXXXXXXXXXXXXXXXXX
%     elseif current_count > 1
%         % input attributes
%         max_mf = zeros(1, num_attributes);
%         max_set = zeros(1, num_attributes);
%         for i = 1 : num_attributes
%             
%             if data_input(i) < net.input(i).min
%                 net.input(i).min = data_input(i);
%             end
%             if data_input(i) > net.input(i).max
%                 net.input(i).max = data_input(i);
%             end
%             
%             num_mf = size(net.input(i).mf, 2);
%             mf_values = zeros(1, num_mf);
%             for j = 1 : num_mf
%                 if(net.input(i).mf(j).params(1) ~= 0 && net.input(i).mf(j).params(3) ~= 0)
%                     mf_values(j) = gauss2mf(data_input(i), net.input(i).mf(j).params);
%                 end
%             end
%             % get MF value of the winning fuzzy set (max mf value)
%             [max_mf(i), max_set(i)] = max(mf_values);
%             % if highest MF value below set threshold, generate new MF
%             if max_mf(i) <= IT
%                 net.input(i) = mar_generate_mf(net.input(i), data_input(i), current_count);
%             % if highest MF value above tendency but not in kernel
%             elseif max_mf(i) > IT && max_mf(i) < 1
%                 plasticity = net.input(i).mf(max_set(i)).plasticity;
%                 tendency = net.input(i).mf(max_set(i)).tendency;
%                 if plasticity > 0
%                     left_centroid = net.input(i).mf(max_set(i)).params(2);
%                     right_centroid = net.input(i).mf(max_set(i)).params(4);
%                     % shift centroid closer to data_input according to
%                     % plasticity parameter
%                     if left_centroid > data_input(i)
%                         left_centroid = left_centroid - (plasticity * abs(left_centroid - data_input(i)));
%                         if max_set(i) == 1
%                             net.input(i).range(1) = net.input(i).range(1) - (plasticity * abs(left_centroid - data_input(i)));
%                         end
%                     elseif right_centroid < data_input(i)
%                         right_centroid = right_centroid + (plasticity * abs(right_centroid - data_input(i)));
%                         if max_set(i) == num_mf
%                             net.input(i).range(2) = net.input(i).range(2) + (plasticity * abs(right_centroid - data_input(i)));
%                         end
%                     end
%                     net.input(i).mf(max_set(i)).params(2) = left_centroid;
%                     net.input(i).mf(max_set(i)).params(4) = right_centroid;
%                 
%                     % decrease plasticity parameter by 2/3s                
%                     net.input(i).mf(max_set(i)).plasticity = plasticity * 2/3;
%                     % increase num_expanded
%                     net.input(i).mf(max_set(i)).num_expanded = net.input(i).mf(max_set(i)).num_expanded + 1;
%                     % decrease tendency parameter
%                     net.input(i).mf(max_set(i)).tendency = tendency + (-0.5 * tendency) * (1 - max_mf(i))^2;
%                     if net.input(i).mf(max_set(i)).tendency <= 0
%                         net.input(i).mf(max_set(i)).plasticity = 0;
%                     end
%                 end
%             end
%         end
%         
%         % output attributes
%         max_mf = zeros(1, num_outputs);
%         max_set = zeros(1, num_outputs);
%         for i = 1 : num_outputs
%             if data_target(i) < net.output(i).min
%                 net.output(i).min = data_target(i);
%             end
%             if data_target(i) > net.output(i).max
%                 net.output(i).max = data_target(i);
%             end
%             
%             num_mf = size(net.output(i).mf, 2);
%             mf_values = zeros(1, num_mf);
%             for j = 1 : num_mf
%                 if( net.output(i).mf(j).params(1) ~= 0 &&  net.output(i).mf(j).params(3) ~= 0)
%                 mf_values(j) = gauss2mf(data_target(i), net.output(i).mf(j).params);
%                 end
%             end
%             % get MF value of the winning fuzzy set (max mf value)
%             [max_mf(i), max_set(i)] = max(mf_values);
%             % if highest MF value below set threshold, generate new MF            
%             if max_mf(i) <= OT
%                 net.output(i) = mar_generate_mf(net.output(i), data_target(i), current_count);
%             % if highest MF value above tendency but not in kernel
%             elseif max_mf(i) > OT && max_mf(i) < 1
%                 plasticity = net.output(i).mf(max_set(i)).plasticity;
%                 tendency = net.output(i).mf(max_set(i)).tendency;
%                 if plasticity > 0
%                     left_centroid = net.output(i).mf(max_set(i)).params(2);
%                     right_centroid = net.output(i).mf(max_set(i)).params(4);
%                     % shift centroid closer to data_input according to
%                     % plasticity parameter
%                     if left_centroid > data_target(i)
%                         left_centroid = left_centroid - (plasticity * abs(left_centroid - data_target(i)));
%                         if max_set(i) == 1
%                             net.output(i).range(1) = net.output(i).range(1) - (plasticity * abs(left_centroid - data_target(i)));
%                         end
%                     elseif right_centroid < data_target(i)
%                         right_centroid = right_centroid + (plasticity * abs(right_centroid - data_target(i)));
%                         if max_set(i) == num_mf
%                             net.output(i).range(2) = net.output(i).range(2) + (plasticity * abs(right_centroid - data_target(i)));
%                         end
%                     end
%                     net.output(i).mf(max_set(i)).params(2) = left_centroid;
%                     net.output(i).mf(max_set(i)).params(4) = right_centroid;
%                 
%                     % decrease plasticity parameter by 2/3s                
%                     net.output(i).mf(max_set(i)).plasticity = plasticity * 2/3;
%                     % increase num_expanded
%                     net.output(i).mf(max_set(i)).num_expanded = net.output(i).mf(max_set(i)).num_expanded + 1;
%                     % decrease tendency parameter
%                     net.output(i).mf(max_set(i)).tendency = tendency + (-0.5 * tendency) * (1 - max_mf(i))^2;
%                     if net.output(i).mf(max_set(i)).tendency <= 0
%                         net.output(i).mf(max_set(i)).plasticity = 0;
%                     end
%                 end
%             end
%         end
%    end    
    
    D = net;
end