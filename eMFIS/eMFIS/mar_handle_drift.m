% XXXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_HANDLE_DRIFT XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Mario Hartanto
% Date      :   Feb 12 2014
% Function  :   handle concept drift
% Syntax    :   mar_handle_drift(ensemble, algo)
% 
% net - FIS network structure
% data_input - input data, can have multiple columns (attributes) but one row
% data_target - target data, can have multiple columns (outputs) but one row
% current_count - number of data processed
% 
% Algorithm -
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


function [D, net, cn] = mar_handle_drift( ensemble, net, current_count, data_input, data_target )

    disp('Handle Drift');
    old_network = size(ensemble.net_struct, 2);

    ensemble.net_struct(old_network).net = net;
    ensemble.net_struct(old_network).net.lastLearned = current_count;
    
    current_network = old_network + 1;
    
    % generate new network for ensemble
    disp(['Create network ', num2str(current_network)]);
    ensemble.total_network = ensemble.total_network + 1;
    ensemble.net_struct(current_network).net = net;
    ensemble.net_struct(current_network).net.created = current_count;
    ensemble.net_struct(current_network).net.weight = 1;
    ensemble.net_struct(current_network).net.id = ensemble.total_network;
    ensemble.net_struct(current_network).net.benchmark_dev = net.benchmark_dev;
    ensemble.net_struct(current_network).net.benchmark_mean = net.benchmark_mean;
    
    % Refresh Spatio-Temporal Distance
    num_attributes = size(net.input, 2);
    num_outputs = size(net.output, 2);
    
    for i = 1 : num_attributes
        ensemble.net_struct(current_network).net.input(i).sum_square = data_input(i) ^ 2;
        ensemble.net_struct(current_network).net.input(i).sum = data_input(i);
        ensemble.net_struct(current_network).net.input(i).currency = 1;
        ensemble.net_struct(current_network).net.input(i).spatio_temporal_dist = 0;
    end
    
    for i = 1 : num_outputs
        ensemble.net_struct(current_network).net.output(i).sum_square = data_target(i) ^ 2;
        ensemble.net_struct(current_network).net.output(i).sum = data_target(i);
        ensemble.net_struct(current_network).net.output(i).currency = 1;
        ensemble.net_struct(current_network).net.output(i).spatio_temporal_dist = 0;
    end
    
    ensemble = mar_normalize_networks(ensemble); 
    
    % Put network into cache, if ensemble size exceeds limit
    if size(ensemble.net_struct,2) > ensemble.maxSize
        least_weight = ensemble.net_struct(1).net.weight;
        index = 1;
        for k = 2 : (current_network - 1)
            if(ensemble.net_struct(k).net.weight < least_weight)
                index = k;
                least_weight = ensemble.net_struct(k).net.weight;
            end
        end
        
        if ~(isfield(ensemble, 'cache'))
            cache_index = 1;
        else
            cache_index = size(ensemble.cache.net_struct, 2) + 1;
        end
        ensemble.cache.net_struct(cache_index).net = ensemble.net_struct(1,index).net;
        
        for m = 1 : size(ensemble.net_struct(index).net.input,2)
            ensemble.cache.net_struct(cache_index).input(m) = mean(ensemble.net_struct(index).net.input(1,m).range);
        end
 
        if(index == 1)
            ensemble.net_struct = ensemble.net_struct(2:current_network);
        else
            ensemble.net_struct = [ensemble.net_struct(1 : index-1) ensemble.net_struct(index+1 : current_network)];
        end
        
        ensemble = mar_normalize_networks(ensemble);
        current_network = size(ensemble.net_struct,2);
    end
 
    D = ensemble;
    net = ensemble.net_struct(current_network).net;
    cn = current_network;
end

