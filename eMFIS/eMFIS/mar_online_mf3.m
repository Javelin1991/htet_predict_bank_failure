% XXXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_ONLINE_MF3 XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Mario Hartanto
% Date      :   Jan 24 2014
% Function  :   creates membership functions incrementally
% Syntax    :   mar_online_mf3(net, data_input, data_target, current_count)
% 
% net - FIS network structure
% data_input - input data, can have multiple columns (attributes) but one row
% data_target - target data, can have multiple columns (outputs) but one row
% current_count - number of data processed
% 
% Algorithm (adapted DIC) -
% 1) Update spatio-temporal distance
% 2) If data's distance to the nearest centroid is less than the expandability, new MF is generated (see mar_generate_mf)
% 3) Update winning centroid and it's stability
% 4) Update mf slope
% 5) Else, if winning MF value is below 1 (i.e. not in kernel), expand MF kernel by plasticity * distance between centroid and data_value
% 6) Reduce plasticity by 2/3s, reduce tendency. If tendency <= 0, plasticity = 0
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = mar_online_mf3(net, data_input, data_target, current_count)
    global drift_track;
    disp('Online Fuzzy 3');
    num_attributes = size(data_input, 2);
    num_outputs = size(data_target, 2);
    
%     IT = 0.5;
%     OT = 0.5;
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
            net.input(i).mf(1).tw_sum = 0;
            net.input(i).mf(1).mf_currency = 0;
            
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
            net.output(i).mf(1).tw_sum = 0;
            net.output(i).mf(1).mf_currency = 0;
            
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
%        net.input(i).spatio_temporal_dist = 2 * (2*pi)^0.5 * ( (net.input(i).sum_square / net.input(i).currency) - (net.input(i).sum / net.input(i).currency)^2 ) ^ 0.5;
%        net.input(i).spatio_temporal_dist = 2 * (2* exp(1))^0.5 * ( (net.input(i).sum_square / net.input(i).currency) - (net.input(i).sum / net.input(i).currency)^2 ) ^ 0.5;
        net.input(i).spatio_temporal_dist = 4 * ( (net.input(i).sum_square / net.input(i).currency) - (net.input(i).sum / net.input(i).currency)^2 ) ^ 0.5;
        
        num_mf = size(net.input(i).mf, 2);
        dist_from_centroid = zeros(1, num_mf);
        for j = 1 : num_mf
            if(net.input(i).mf(j).params(1) ~= 0 && net.input(i).mf(j).params(3) ~= 0)
                dist_from_centroid(j) = abs( data_input(i) - ((net.input(i).mf(j).params(2) + net.input(i).mf(j).params(4))/2) );
            end
        end
        
        if( min(dist_from_centroid) > ( net.input(i).spatio_temporal_dist / (max_cluster - num_mf) ) || current_count == 1 )
        %if( min(dist_from_centroid) > ( net.input(i).spatio_temporal_dist / (num_mf*4/2.5) ) || current_count == 1 )
            % CREATE NEW CENTROID
            net.input(i) = mar_generate_mf(net.input(i), data_input(i), current_count);
        end
       
        % Update centroid and it's stability (Winner Takes All)
        mf_values = zeros(1, num_mf);
        for j = 1 : num_mf
            if(net.input(i).mf(j).params(1) ~= 0 && net.input(i).mf(j).params(3) ~= 0)
                mf_values(j) = gauss2mf(data_input(i), net.input(i).mf(j).params);
            end
        end
        max_index = find( mf_values == max(mf_values(:)));
        
        for m = 1 : size( max_index, 2)
            centroid = (net.input(i).mf(max_index(m)).params(2) + net.input(i).mf(max_index(m)).params(4)) / 2;
            centroid_width = net.input(i).mf(max_index(m)).params(4) - centroid;
            curr_stability = net.input(i).mf(max_index(m)).stability * forgettor;
            centroid = curr_stability * centroid + (1 - curr_stability) * data_input(i);
            net.input(i).mf(max_index(m)).params(2) = centroid - centroid_width;
            net.input(i).mf(max_index(m)).params(4) = centroid + centroid_width;

            net.input(i).mf(max_index(m)).mf_currency = net.input(i).mf(max_index(m)).mf_currency * forgettor + 1;
            net.input(i).mf(max_index(m)).tw_sum = net.input(i).mf(max_index(m)).tw_sum * forgettor + data_input(i);
%            tw_mean = net.input(i).mf(max_index(m)).tw_sum / net.input(i).mf(max_index(m)).mf_currency;
            net.input(i).mf(max_index(m)).stability = (curr_stability + max(mf_values)) / net.input(i).mf(max_index(m)).mf_currency;
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
%        net.output(i).spatio_temporal_dist = 2 * (2*pi)^0.5 * ( (net.output(i).sum_square / net.output(i).currency) - (net.output(i).sum / net.output(i).currency)^2 ) ^ 0.5;
%        net.output(i).spatio_temporal_dist = 2 * (2*exp(1))^0.5 * ( (net.output(i).sum_square / net.output(i).currency) - (net.output(i).sum / net.output(i).currency)^2 ) ^ 0.5;
        net.output(i).spatio_temporal_dist = 4 * ( (net.output(i).sum_square / net.output(i).currency) - (net.output(i).sum / net.output(i).currency)^2 ) ^ 0.5;
        
        num_mf = size(net.output(i).mf, 2);
        dist_from_centroid = zeros(1, num_mf);
        for j = 1 : num_mf
            if(net.output(i).mf(j).params(1) ~= 0 && net.output(i).mf(j).params(3) ~= 0)
                dist_from_centroid(j) = abs( data_target(i) - ((net.output(i).mf(j).params(2) + net.output(i).mf(j).params(4))/2) );
            end
        end
        
        if( min(dist_from_centroid) > ( net.output(i).spatio_temporal_dist / (max_cluster - num_mf) ) || current_count == 1 )
        %if( min(dist_from_centroid) > ( net.output(i).spatio_temporal_dist / (num_mf * 4/2.5) ) || current_count == 1 )
            % CREATE NEW CENTROID
            net.output(i) = mar_generate_mf(net.output(i), data_target(i), current_count);
            drift_track(size(drift_track,2) + 1) = current_count;
        end
        
        
        % Update centroid and it's stability (Winner Takes All)
        mf_values = zeros(1, num_mf);
        for j = 1 : num_mf
            if(net.output(i).mf(j).params(1) ~= 0 && net.output(i).mf(j).params(3) ~= 0)
                mf_values(j) = gauss2mf(data_target(i), net.output(i).mf(j).params);
            end
        end
        max_index = find( mf_values == max(mf_values(:)));
        
        for m = 1 : size( max_index, 2) 
            centroid = (net.output(i).mf(max_index(m)).params(2) + net.output(i).mf(max_index(m)).params(4)) / 2;
            centroid_width = net.output(i).mf(max_index(m)).params(4) - centroid;
            curr_stability = net.output(i).mf(max_index(m)).stability * forgettor;
            centroid = curr_stability * centroid + (1 - curr_stability) * data_target(i);
            net.output(i).mf(max_index(m)).params(2) = centroid - centroid_width;
            net.output(i).mf(max_index(m)).params(4) = centroid + centroid_width;

            net.output(i).mf(max_index(m)).mf_currency = net.output(i).mf(max_index(m)).mf_currency * forgettor + 1;
            net.output(i).mf(max_index(m)).tw_sum = net.output(i).mf(max_index(m)).tw_sum * forgettor + data_target(i);
%            tw_mean = net.output(i).mf(max_index(m)).tw_sum / net.output(i).mf(max_index(m)).mf_currency;
            net.output(i).mf(max_index(m)).stability = (curr_stability + max(mf_values)) / net.output(i).mf(max_index(m)).mf_currency;
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
        
    D = net;
end