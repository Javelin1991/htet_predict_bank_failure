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

function D = update_ron_trainOnline(data_input, data_target, algo, window, varargin)

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
        ensemble.net_struct(1).net.lastLearned = 0;
        ensemble.net_struct(1).net.learned = 0;
        ensemble.net_struct(1).net.winner = 0;
        ensemble.net_struct(1).net.belong = 1;
        current_network = 1;
        errorReduce = 0;
        ensemble.errorUp = 0;
        ensemble.error = 0;
        ensemble.rateError = 0;
        ensemble.dataProcessed = 0;
        ensemble.predicted = zeros(size(data_target));
        fixWindowSize = window;
        ensemble.fixWindowSize = fixWindowSize;
        windowSize =window;
        windowCount = 0;
        ensemble.maxSize = 4;
        spikeUp = false;
        last_create = 0;
        added = 0;
        ensemble.ruleCount = zeros(size(data_target,1), 1);
        ensemble.ruleCount(1) = 0;
    end

    for i = 1 : size(data_target, 1)

        ensemble.dataProcessed = ensemble.dataProcessed + 1;
        current_count = ensemble.dataProcessed;
        windowCount = windowCount + 1;
        current_network = size(ensemble.net_struct, 2);

            disp(['Processing ', num2str(current_count)]);

        if isfield(ensemble, 'cache')
            ensemble = checkCache(ensemble, data_input(i,:));
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
                    if isnan( ensemble.predicted(current_count, :))
                        hit = true;
                    end
                end
            end
        end

        % XXXXXXXXXXXXXXXXXXXXXXXXXXXX STORE HISTORICAL DATA XXXXXXXXXXXXXXXXXXXXXXXXXXXX

        if isfield(ensemble, 'stored_input')
            num_stored = size(ensemble.stored_input, 1);
        else
            num_stored = 0;
        end
        if(windowCount <= windowSize)
            ensemble.stored_input(windowCount, :) = data_input(i, :);
            ensemble.stored_targets(windowCount, :) = data_target(i, :);
        elseif(windowCount > windowSize && windowCount <= 3*windowSize)
            ensemble.stored_input(windowCount, :) = data_input(i, :);
            ensemble.stored_targets(windowCount, :) = data_target(i, :);
            windowSize = windowSize + 1;
        end

        if current_count > 1
            ensemble = ron_normalize_networks(ensemble);
        end


        old_error = ensemble.error;
        old_rateError = ensemble.rateError;
        ensemble.error = ((ensemble.error * (current_count - 1)) +  (ensemble.predicted(current_count, :) - data_target(i, :))^2) / current_count;
        ensemble.rateError = abs(ensemble.error - old_error);

        if 1.5 * old_error < ensemble.error && spikeUp == false && current_count > 1
            spikeUp = true;
            spikeUpIndex = current_count;
            ensemble.errorUp = ensemble.errorUp + 1;
        elseif old_error < ensemble.error && spikeUp==false
            if(ensemble.rateError > 1.5 * old_rateError)
                ensemble.errorUp = ensemble.errorUp + 1;
            else
                ensemble.errorUp = ensemble.errorUp + 0;
            end
        elseif old_error > ensemble.error && spikeUp == false
             if(ensemble.rateError > 1.5 * old_rateError)
                ensemble.errorUp = ensemble.errorUp - 1;
            else
                ensemble.errorUp = ensemble.errorUp + 0;
             end
            if(ensemble.errorUp <0)
            ensemble.errorUp = 0;
            errorReduce = errorReduce + 1;
                if(errorReduce > 0.1*windowSize)
                windowSize = floor(windowSize + 0.1* windowSize);
                errorReduce = 0;
                end
            end
        end
        if(spikeUp == true && spikeUpIndex < current_count)
             if(ensemble.error < old_error && ensemble.rateError < 1.5 * old_rateError)
                 ensemble.errorUp = ensemble.errorUp + 1;
             elseif(ensemble.error > old_error)
                 ensemble.errorUp = ensemble.errorUp + 1;
             else
                 ensemble.errorUp = ensemble.errorUp - 1;
                 spikeUp = false;
             end
        end

        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXX PERFORM ONLINE LEARNING XXXXXXXXXXXXXXXXXXXXXXXXX

        %if(current_count <= start_test)
        % only learn if training is required i.e. no ensemble is provided
        if isempty(varargin)
            net = ensemble.net_struct(current_network).net;
            % take the input data and train - first generate MF
            net = ron_online_mf2(net, data_input(i, :), data_target(i, :), current_count);
            % look at rules and determine whether to generate new rule
            net = update_ron_online_rule(net, data_input(i, :), data_target(i, :), current_count);
            %net = ron_online_backprop(net, data_input(i, :), data_target(i, :),  net.predicted(current_count, :));

            % merge mfs that are too close
            [net mm] = ron_clean_mf(net);
            % if mm = 1, some mfs were merged and thus rule base must be
            % cleaned
            if mm
                disp(['Cleaning rules at ', num2str(current_count)]);
                net = ron_clean_pop(net);
            end
            num_rules = 0;
            if(current_count > 1)
            for j = 1 : size(ensemble.net_struct)
            num_rules = num_rules + (size(ensemble.net_struct(j).net.rule, 2) * ensemble.net_struct(j).net.weight);
            end
            ensemble.ruleCount(current_count) = num_rules;
            end

            errorUp = false;
            % if error goes up too many times
            if((ensemble.errorUp >= 0.1 * windowSize && spikeUp == true) ||  (ensemble.errorUp >= 0.2 * windowSize) ...
                || (current_count - last_create) > 3 * fixWindowSize)
                errorUp = true;
            end

            if (errorUp==true)
                windowCount = 0;
                ensemble.errorUp = 0;
                spikeUp = false;
                errorReduce = 0;
                % perform rough set reduction
                disp(['Reduction count ', num2str(rs_reduction_count), ' at data no. ', num2str(current_count)]);
                rs_reduction_count = rs_reduction_count + 1;
                net = ron_rs_reduction(net, ensemble.stored_input);
                net = ron_clean_pop(net);
                last_create = current_count;

                if strcmp(algo, 'ierspop') == 1
                    % generate new network for ensemble
                    ensemble.net_struct(current_network).net = net;
                    ensemble.net_struct(current_network).net.lastLearned = current_count;
                    current_network = current_network + 1;
                    ensemble.net_struct(current_network).net.learned= current_count;
                    disp(['Create network ', num2str(current_network)]);
                    ensemble.net_struct(current_network).net = net;
                    ensemble.net_struct(current_network).net.name = 'ieRSPOP';
                    ensemble.net_struct(current_network).net.type = 'mamdani';
                    ensemble.net_struct(current_network).net.andMethod = 'min';
                    ensemble.net_struct(current_network).net.orMethod = 'max';
                    ensemble.net_struct(current_network).net.defuzzMethod = 'centroid';
                    ensemble.net_struct(current_network).net.impMethod = 'min';
                    ensemble.net_struct(current_network).net.aggMethod = 'max';
                     ensemble.net_struct(current_network).net.winner = 0;
                    ensemble.net_struct(current_network).net.lastLearned = current_count;
                    ensemble.net_struct(current_network).net.weight = 1;
                    ensemble.net_struct(current_network).net.predicted = net.predicted;
                    ensemble.net_struct(current_network).net.belong = current_network + added;

                    net = ensemble.net_struct(current_network).net;

                    stored_input = ensemble.stored_input(floor(size(ensemble.stored_input, 1)*0.85)+1:size(ensemble.stored_input, 1), :);
                    stored_targets = ensemble.stored_targets(floor(size(ensemble.stored_targets, 1)*0.85)+1:size(ensemble.stored_targets, 1), :);
                    ensemble.stored_input = circshift(ensemble.stored_input, -floor(size(ensemble.stored_input, 1)*0.85));
                    ensemble.stored_targets = circshift(ensemble.stored_targets, -floor(size(ensemble.stored_targets, 1)*0.85));

                    for j= 1:size(stored_input, 1)
                        % take the input data and train - first generate MF
                        net = ron_online_mf2(net, stored_input(j, :), stored_targets(j, :), j);
                        % look at rules and determine whether to generate new rule
                        net = update_ron_online_rule(net, stored_input(j, :), stored_targets(j, :), j);
                        % merge mfs that are too close
                        [net mm] = ron_clean_mf(net);
                        % if mm = 1, some mfs were merged and thus rule base must be
                        % cleaned
                        if mm
                            disp(['Cleaning rules at ', num2str(current_count)]);
                            net = ron_clean_pop(net);
                        end
                    end

                 if(windowSize > 3*fixWindowSize)
                    windowSize = fixWindowSize;
                 end
                 ensemble.net_struct(current_network).net = net;
                 ensemble = ron_normalize_networks(ensemble);
                 if size(ensemble.net_struct,2) > ensemble.maxSize
                    added = added + 1;
                    leastweight = inf;
                    index = 0;
                    for k=1: current_network-1
                        if(ensemble.net_struct(k).net.weight < leastweight)
                            index = k;
                        end
                    end

                    if(ensemble.net_struct(index).net.weight < 1/ensemble.maxSize)
                        if ~(isfield(ensemble, 'cache'))
                            ensemble.cache.net_struct(1).belong = current_count;
                            ensemble.cache.net_struct(1).net = ensemble.net_struct(1,index).net;
                        else
                            cache = size(ensemble.cache.net_struct,2)+1;
                            ensemble.cache.net_struct(cache).belong = current_count;
                            ensemble.cache.net_struct(cache).net = ensemble.net_struct(1,index).net;
                        end
                        for m=1:size(ensemble.net_struct(index).net.input,2)
                                ensemble.cache.net_struct(size(ensemble.cache.net_struct,2)).input(m) = sum(ensemble.net_struct(index).net.input(1,m).range)/2;
                        end

                        if(index == 1)
                            ensemble.net_struct = ensemble.net_struct(2:current_network);
                        else
                        ensemble.net_struct = [ensemble.net_struct(1:index-1) ensemble.net_struct(index+1:current_network)];
                        end
                    end
                end
                ensemble = ron_normalize_networks(ensemble);
                end
            else
                ensemble.net_struct(current_network).net = net;
            end
        end
        end
    %end
    net1 = ensemble.net_struct(current_network).net;
    net1 = ron_rs_reduction(net1, ensemble.stored_input);
    net1 = ron_clean_pop(net1);
    ensemble.net_struct(current_network).net = net1;
    ensemble = cleanRuleEnsemble(ensemble);
    ensemble = delete_orphan_labels(ensemble);
    ensemble = semanticRules(ensemble);
    D = ensemble;

end
