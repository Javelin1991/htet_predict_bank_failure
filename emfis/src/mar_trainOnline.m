% XXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_TRAINONLINE XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Mario Hartanto ; Susanti
% Date      :   Jan 24 2014; Aug 1 2014
% Function  :   performs complete online training
% Syntax    :   mar_trainOnline (ie_rules_no ,create_ie_rule,data_input, data_target, algo, varargin)
%
% ie_rules_no - state number of rules used for interpolation and
%               extrapolation
% create_ie_rule - add interpolation or extrapolation rule into rule base-
%                   0 indicates no, 1 indicates yes.
% data_input - input data, can have multiple columns (attributes) but one row
% data_target - target data, can have multiple columns (outputs) but one row
% algo - 'emfis'
% varargin - takes in an optional ensemble in case evaluation wants to be done without training
%
% Algorithm -
% 1) Generates network
% 2) Performs CRI inference for output evaluation (see mar_cri)
% 3) Performs online MF generation (see mar_online_mf4)
% 4) Performs online rule generation (see mar_online_rule)
% 5) Performs online rule selection (see mar_pseudo_prune_rule)
% 6) Performs membership function reduction using merging (see mar_clean_mf)
% 7) If there is merging, performs rule reduction using POP (see mar_clean_pop)
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = mar_trainOnline(ie_rules_no ,create_ie_rule,data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight, varargin)


    if isempty(varargin)
        disp(['Create network ', num2str(1)]);
        system.total_network = 1;
        system.net.name = 'eMFIS';
        system.net.type = 'mamdani';
        system.net.andMethod = 'min';
        system.net.orMethod = 'max';
        system.net.defuzzMethod = 'centroid';
        system.net.impMethod = 'min';
        system.net.aggMethod = 'max';
        system.net.weight = 1;
        system.net.lastLearned = 0;
        system.net.created = 1;
        system.net.winner = 0;
        system.net.id = 1;
        system.net.max_cluster = max_cluster;
        system.net.half_life = half_life;
        system.net.forgettor = 0.5 ^ (1 / half_life);
        system.net.num_active_rules = 0;
        system.net.threshold_mf = threshold_mf;
        system.net.min_rule_weight = min_rule_weight;
        system.dataProcessed = 0;
        system.interpolationNo = 0;
        system.net.interpolation.ie_rules_no = ie_rules_no;
        system.net.interpolation.create_ie_rule = create_ie_rule;
        system.predicted = zeros(size(data_target));

        % Information below is for results analysis
        system.net.ruleCount = zeros(size(data_target,1), 1);% 1,150-2,1

        system.net.outputClusterCount = zeros(size(data_target,1), 1);
        system.net.spatioTemporal = zeros(size(data_target,1), 1);
    end

    for i = 1 : size(data_target, 1)

        system.dataProcessed = system.dataProcessed + 1;
        current_count = system.dataProcessed;

        disp(['Processing ', num2str(current_count)]);

        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX PREDICT RESULT XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        if current_count == 1
            system.net.predicted(current_count, :) = 0;
            system.predicted(current_count, :) = 0;
        end

        % XXXXXXXXXXXXXXXXXXXXXXXXXXXXX PERFORM ONLINE LEARNING XXXXXXXXXXXXXXXXXXXXXXXXX

        %if(current_count <= start_test)
        % only learn if training is required i.e. no system is provided
        if ~isempty(varargin)
            continue;
        end

        net = system.net;

        % take the input data and train MF
        net = mar_online_mf4(net, data_input(i, :), data_target(i, :), current_count);

        % if drift occurs, get the result from inter or extrapolation.
        if (net.interpolation.output(current_count,1)~= 0)
            system.predicted(current_count, :) = net.interpolation.output(current_count,1);
            system.interpolationNo = system.interpolationNo+1;
        else
        % inference result as normal
            system.net.predicted(current_count, :) = mar_cri(data_input(i, :), net);

            if isnan(system.net.predicted(current_count, :))
                system.net.predicted(current_count, :) = 0;
                system.predicted(current_count, :) = 0;

                continue;
            else
                % system prediction is weighted average of individual prediction
                system.predicted(current_count, :) =  system.net.predicted(current_count, :);

            end
        end


        % look at rules and determine whether to generate new rule
         net = mar_online_rule(net, data_input(i, :), data_target(i, :), current_count);


        % Online selection of rules
        net = mar_pseudo_prune_rule(net, current_count);

        % merge mfs if they are reducible
        [net, merged] = mar_clean_mf(net);

        % if merged = 1, some mfs were merged and thus rule base must be cleaned
        if merged
            disp(['MF merged at ', num2str(current_count)]);
            net = mar_clean_pop(net, current_count);
            net = mar_pseudo_prune_rule(net, current_count);
        end

        net.ruleCount(current_count) = net.num_active_rules;

        net.outputClusterCount(current_count) = size(net.output.mf,2);
        net.spatioTemporal(current_count) = net.output.spatio_temporal_dist;
        system.net = net;

    end

    D = system;

end
