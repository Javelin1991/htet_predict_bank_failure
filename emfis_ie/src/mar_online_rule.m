% XXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_ONLINE_RULE XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Mario Hartanto
% Date      :   Jan 25 2014
% Function  :   creates rules incrementally
% Syntax    :   mar_online_rule(net, data_input, data_target, current_count)
%
% net - FIS network structure
% data_input - input data, can have multiple columns (attributes) but one
% row
% data_target - target data, can have multiple columns (outputs) but one row
%
% Algorithm -
% 1) Finds winning fuzzy set of each input and output
% 2) Searches for the same rule or inconsistent rule in net.rule by matching the antecedents and consequents
% 3) Update all rules' weight using BCM theory
% 4) If no same rule found, new rule generated with weight f * u
% 5) All weights are normalized (see mar_normalize_weights)
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = mar_online_rule(net, data_input, data_target, current_count)

%    disp('Online Rule');
    new_rule_weight_factor = 1;
    num_attributes = size(data_input, 2);
    num_outputs = size(data_target, 2);
    forgettor = net.forgettor;

    % find fuzzy set the input data belongs to
    max_mf = zeros(1, num_attributes);
    max_set = zeros(1, num_attributes);
    for i = 1 : num_attributes
        num_mf = size(net.input(i).mf, 2);
        mf_values = zeros(1, num_mf);
        for j = 1 : num_mf
            if net.input(i).mf(j).params(1) ~= 0 && net.input(i).mf(j).params(3) ~= 0
                mf_values(j) = gauss2mf(data_input(i), net.input(i).mf(j).params);
            end
        end
        % get winning membership values and winning fuzzy sets

        [max_mf(i), max_set(i)] = max(mf_values);

        net.input(i).mf(max_set(i)).num_invoked = net.input(i).mf(max_set(i)).num_invoked + 1;
    end
    % antecedent is array with winning fuzzy set of each input
    antecedent = max_set;

    % f for firing strength of this particular invocation
    f = min(max_mf);

    % find fuzzy set the target data belongs to
    max_mf = zeros(1, num_outputs);
    max_set = zeros(1, num_outputs);
    for i = 1 : num_outputs
        num_mf = size(net.output(i).mf, 2);
        mf_values = zeros(1, num_mf);
        for j = 1 : num_mf
           if( net.output(i).mf(j).params(1) ~=0 &&  net.output(i).mf(j).params(3) ~=0 )
                mf_values(j) = gauss2mf(data_target(i), net.output(i).mf(j).params);
           end
        end
        % get winning membership values and winning fuzzy sets
        [max_mf(i), max_set(i)] = max(mf_values);


        net.output(i).mf(max_set(i)).num_invoked = net.output(i).mf(max_set(i)).num_invoked + 1;
    end
    % consequent is array with winning fuzzy set of each output
    consequent = max_set;
    % u is 'strength' of the output of this particular invocation
    u = min(max_mf);

    if ~isfield(net, 'rule')
        % if the field rule does not exist, it means this is the first data
        net.rule(1).antecedent = antecedent;
        net.rule(1).consequent = consequent;
        net.rule(1).weight = new_rule_weight_factor * f * u;
        net.rule(1).connection = 1;
        net.rule(1).num_invoked = 1;
        net.rule(1).topCache = 0;
        net.rule(1).baseCache = 0;
        net.rule(1).lastUpdate = current_count;
        net.rule(1).belong = 1;
        net.rule(1).active = 1;

        D = net;
        return;
    end


    rule_exists = 0; inconsistent_found = 0;
    num_rules = size(net.rule, 2);

    for i = 1 : num_rules
        % looking for same rule i.e. same antecedents, same consequents
        if sum(antecedent == net.rule(i).antecedent) == num_attributes && sum(consequent == net.rule(i).consequent) == num_outputs

            if(net.rule(i).baseCache == 0)
                thetha = 0;
            else
                thetha = net.rule(i).topCache / net.rule(i).baseCache;
            end

            assoc = f * u * (u - thetha);
            net.rule(i) = mar_update_sliding_threshold(net.rule(i), u, forgettor);

            if(net.rule(i).weight + assoc < 0)
                assoc = -net.rule(i).weight;
            end

            net.rule(i).weight = net.rule(i).weight + assoc;

            % if found, increase number of times invoked
            net.rule(i).num_invoked = net.rule(i).num_invoked + 1;
            net.rule(i).lastUpdate = current_count;

            rule_exists = 1;

        % if same antecedent but different consequents (inconsistent rule)
        elseif sum(antecedent == net.rule(i).antecedent) == num_attributes && sum(consequent == net.rule(i).consequent) ~= num_outputs
            % only keep the one with the higher weight
            if net.rule(i).weight < (new_rule_weight_factor * f * u)
                net.rule(i).weight = new_rule_weight_factor * f * u;
                net.rule(i).consequent = consequent;
                net.rule(i).num_invoked = 1;
                net.rule(i).topCache = 0;
                net.rule(i).baseCache = 0;
                net.rule(i).lastUpdate = current_count;
                net.rule(i).belong = 1;
                net.rule(i).active = 1;
            end
            inconsistent_found = 1;

        else
            net.rule(i) = mar_update_sliding_threshold(net.rule(i), 0, forgettor);
        end
    end

    if rule_exists == 0 && inconsistent_found == 0


        net.rule(num_rules + 1).antecedent = antecedent;
        net.rule(num_rules + 1).consequent = consequent;
        net.rule(num_rules + 1).weight = new_rule_weight_factor * f * u;
        net.rule(num_rules + 1).connection = 1;
        net.rule(num_rules + 1).num_invoked = 1;
        net.rule(num_rules + 1).topCache = 0;
        net.rule(num_rules + 1).baseCache = 0;
        net.rule(num_rules + 1).lastUpdate = current_count;
        net.rule(num_rules + 1).belong = 1;
        net.rule(num_rules + 1).active = 1;


    end

    net = mar_normalize_weights(net);

    D = net;
end
