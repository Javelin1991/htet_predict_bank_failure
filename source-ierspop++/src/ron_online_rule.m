% XXXXXXXXXXXXXXXXXXXXXXXXXXX RON_ONLINE_RULE XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Jan 28 2010
% Function  :   creates rules incrementally
% Syntax    :   ron_online_rule(net, data_input, data_target)
% 
% net - FIS network structure
% data_input - input data, can have multiple columns (attributes) but one
% row
% data_target - target data, can have multiple columns (outputs) but one row
% 
% Algorithm -
% 1) Finds winning fuzzy set of each input and output
% 2) Searches for the same rule in net.rule (matching antecedents and consequents)
% 3) If same rule found, weight of 0.1 * f * u is added, and num_invoked increases
% 4) If no same rule found, new rule generated with weight f * u
% 5) All weights are normalized (see ron_normalize_weights)
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_online_rule(net, data_input, data_target)

   disp('Online Rule');
    num_attributes = size(data_input, 2);
    num_outputs = size(data_target, 2);
    
    % find fuzzy set the input data belongs to
    max_mf = zeros(1, num_attributes);
    max_set = zeros(1, num_attributes);
    for i = 1 : num_attributes
        num_mf = size(net.input(i).mf, 2);
        mf_values = zeros(1, num_mf);
        for j = 1 : num_mf
            mf_values(j) = gauss2mf(data_input(i), net.input(i).mf(j).params);
        end
        % get winning membership values and winning fuzzy sets
        [max_mf(i) max_set(i)] = max(mf_values);
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
            mf_values(j) = gauss2mf(data_target(i), net.output(i).mf(j).params);
        end
        % get winning membership values and winning fuzzy sets
        [max_mf(i) max_set(i)] = max(mf_values);
        net.output(i).mf(max_set(i)).num_invoked = net.output(i).mf(max_set(i)).num_invoked + 1;
    end
    % consequent is array with winning fuzzy set of each output
    consequent = max_set;
    % u is 'strength' of the output of this particular invocation
    u = min(max_mf);
    
    % if the field rule exists, means rules were already generated
    if isfield(net, 'rule')
        duplicate_found = 0; inconsistent_found = 0;
        num_rules = size(net.rule, 2);
        for i = 1 : num_rules
            % looking for same rule i.e. same antecedents, same consequents
            if sum(antecedent == net.rule(i).antecedent) == num_attributes && sum(consequent == net.rule(i).consequent) == num_outputs
                % if found, increase number of times invoked
                net.rule(i).num_invoked = net.rule(i).num_invoked + 1;
                % increase weightage of rule by hebbian learning
                net.rule(i).weight = net.rule(i).weight + (f * u);
                duplicate_found = 1;
%                 break;
            % if same antecedent but different consequents (inconsistent rule)
            elseif sum(antecedent == net.rule(i).antecedent) == num_attributes && sum(consequent == net.rule(i).consequent) ~= num_outputs
                % only keep the one with the higher weight
                if net.rule(i).weight < (f * u)
                    net.rule(i).antecedent = antecedent;
                    net.rule(i).consequent = consequent;
                    net.rule(i).weight = f * u;
                    net.rule(i).num_invoked = net.rule(i).num_invoked + 1;
                end
                inconsistent_found = 1;
%                 break;
            else
                net.rule(i).weight = net.rule(i).weight * 0.99;
            end
        end
        if duplicate_found == 0 && inconsistent_found == 0
            net.rule(num_rules + 1).antecedent = antecedent;
            net.rule(num_rules + 1).consequent = consequent;
            net.rule(num_rules + 1).weight = f * u;
            net.rule(num_rules + 1).connection = 1;
            net.rule(num_rules + 1).num_invoked = 1;
        end
    % if not, means this is the first data
    else
        net.rule(1).antecedent = antecedent;
        net.rule(1).consequent = consequent;
        net.rule(1).weight = f * u;
        net.rule(1).connection = 1;
        net.rule(1).num_invoked = 1;
    end
    
    net = ron_normalize_weights(net);
    
    D = net;
end