% XXXXXXXXXXXXXXXXXXXXXXXXXXX RON_TRAINONLINE XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Feb 18 2010
% Function  :   performs complete online training
% Syntax    :   ron_trainOnline (data_input, data_target, 
%                                      store_count, algo, varargin)
% 
% data_input - input data, can have multiple columns (attributes) but one row
% data_target - target data, can have multiple columns (outputs) but one row
% store_count - how much data to store. once data is full perform rough set reduction and create new network
% algo - 'ierspop' or 'irspop'
% varargin - takes in an optional ensemble in case evaluation wants to be done without training
% 
% Algorithm -
% 1) Generates network
% 2) Stores historical data up to store_count amount. If necessary,
%    generate new network and normalize network weights
%    (see ron_normalize_networks)
% 3) Performs CRI inference for output evaluation (see ron_cri)
% 4) Performs online MF generation (see ron_online_mf)
% 5) Performs online rule generation (see ron_online_rule)
% 6) Performs membership function reduction using merging (see ron_clean_mf)
% 7) Performs rule reduction using POP (see ron_clean_pop)
% When historical data is full
% 8) Performs rough set attribute reduction
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_trainOnline(data_input, data_target, algo, varargin)
    
    rs_reduction_count = 1;    
    
    if isempty(varargin)
        disp(['Create network ', num2str(1)]);
        ensemble.net_struct(1).net.name = 'ieRSPOP';
        ensemble.net_struct(1).net.type = 'mamdani';
        ensemble.net_struct(1).net.andMethod = 'min';
        ensemble.net_struct(1).net.orMethod = 'max';
        ensemble.net_struct(1).net.defuzzMethod = 'centroid';
        ensemble.net_struct(1).net.impMethod = 'min';
        ensemble.net_struct(1).net.aggMethod = 'max';
        ensemble.net_struct(1).net.weight = 1;
        ensemble.net_struct(1).net.dataProcessed = 0;
        current_network = 1;
        
        ensemble.errorUp = 0;
        ensemble.error = 0;
        ensemble.errorBefore = 0;
        ensemble.dataProcessed = 0;
        ensemble.predicted = zeros(size(data_target));
    else
        ensemble = varargin{1};
        current_network = size(ensemble.net_struct, 2);
    end
    
    for i = 1 : size(data_target, 1)

        ensemble.dataProcessed = ensemble.dataProcessed + 1;
        current_count = ensemble.dataProcessed;
        
        if mod(current_count, 100) == 0
            disp(['Processing ', num2str(current_count)]);
        end
               
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX PREDICT RESULT XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        
        if current_count == 1
            ensemble.net_struct(1).net.predicted(current_count, :) = 0;
        else
            % predict result of each component network individually
            for num = 1 : size(ensemble.net_struct, 2)
                ensemble.net_struct(num).net.predicted(current_count, :) = ron_cri(data_input(i, :), ensemble.net_struct(num).net);
            end
            ensemble.predicted(current_count, :) = 0;
            % ensemble prediction is weighted average of individual
            % prediction
            for num = 1 : size(ensemble.net_struct, 2)
                if isnan(ensemble.net_struct(num).net.predicted(current_count, :))
                    continue;
                else
                    ensemble.predicted(current_count, :) = ensemble.predicted(current_count, :) + ...
                        ensemble.net_struct(num).net.predicted(current_count, :) * ensemble.net_struct(num).net.weight;
                end
            end
        end
        
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXX STORE HISTORICAL DATA XXXXXXXXXXXXXXXXXXXXXXXXXXXX
        
        if isfield(ensemble, 'stored_input')
            num_stored = size(ensemble.stored_input, 1);
        else
            num_stored = 0;
        end
        ensemble.stored_input(num_stored + 1, :) = data_input(i, :);
        ensemble.stored_targets(num_stored + 1, :) = data_target(i, :);
        
        if current_count > 1
            ensemble = ron_normalize_networks(ensemble);
        end
        
        % calculate error post learning
        old_error = ensemble.error;

        ensemble.error = ((ensemble.error * (current_count - 1)) +  (ensemble.predicted(current_count, :) - data_target(i, :))^2) / current_count;

%         if old_error < ensemble.error && ensemble.errorUp == 0 && current_count > 1
%             ensemble.errorUp = 1;
%             ensemble.errorBefore = old_error;
%         elseif old_error < ensemble.error && ensemble.errorUp > 0
%             ensemble.errorUp = ensemble.errorUp + 1;
%         elseif old_error > ensemble.error
%             ensemble.errorUp = 0;
%         end
        
        if old_error < ensemble.error && ensemble.errorUp == 0 && current_count > 1
            ensemble.errorUp = 1;
            ensemble.errorBefore = old_error;
        elseif old_error < ensemble.error && ensemble.errorUp > 0
            ensemble.errorUp = ensemble.errorUp + 1;
        elseif old_error > ensemble.error && ensemble.errorUp > 0
            ensemble.errorUp = ensemble.errorUp - 1;
        end
        
        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXX PERFORM ONLINE LEARNING XXXXXXXXXXXXXXXXXXXXXXXXX
        
        % only learn if training is required i.e. no ensemble is provided
        if isempty(varargin)            
            net = ensemble.net_struct(current_network).net;
            % take the input data and train - first generate MF
            net = ron_online_mf2(net, data_input(i, :), data_target(i, :), current_count);
            % look at rules and determine whether to generate new rule
            net = ron_online_rule(net, data_input(i, :), data_target(i, :));
            % merge mfs that are too close
            [net mm] = ron_clean_mf(net);
            % if mm = 1, some mfs were merged and thus rule base must be
            % cleaned
            if mm
                disp(['Cleaning rules at ', num2str(current_count)]);
                net = ron_clean_pop(net);
            end
            % if error goes up too many times
            if ensemble.errorUp >= 3 && (ensemble.errorBefore / ensemble.error) < (0.5)
                
                % perform rough set reduction
                disp(['Reduction count ', num2str(rs_reduction_count), ' at data no. ', num2str(current_count)]);
                rs_reduction_count = rs_reduction_count + 1;
                net = ron_rs_reduction(net, ensemble.stored_input);
                net = ron_clean_pop(net);
                    
                if strcmp(algo, 'ierspop') == 1
                    % generate new network for ensemble
                    ensemble.net_struct(current_network).net = net;
                    current_network = current_network + 1;
                    disp(['Create network ', num2str(current_network)]);
                    ensemble.net_struct(current_network).net = net;
                    ensemble = ron_normalize_networks(ensemble);
                elseif strcmp(algo, 'irspop') == 1
                    ensemble.net_struct(current_network).net = net;
                end  
               
                % reduce data stored by half
                ensemble.stored_input = ensemble.stored_input(1 : floor(size(ensemble.stored_input, 1) / 2), :);
                ensemble.stored_targets = ensemble.stored_targets(1 : floor(size(ensemble.stored_targets, 1) / 2), :);
                ensemble.errorUp = 0;
            else
                ensemble.net_struct(current_network).net = net;
            end
        end
    end

    D = ensemble;
    
end