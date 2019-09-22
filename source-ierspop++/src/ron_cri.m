% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX RON_CRI XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Feb 10 2010
% Function  :   performs fuzzy inference using CRI
% Syntax    :   ron_cri(data_input, net)
% 
% ensemble - FIS net structure
% data_input - input data, can have multiple columns (attributes) but one row
% 
% Note - 
% Gaussian defuzzification formula from POPFNN [ZHOU96]
% Inference scheme gotten from POPFNN-CRI [ANG03]
%
% Algorithm -
% 1) Get firing strength of each rule as minimum of each antecedent membership value
% 2) For each consequent fuzzy set, get maximum firing strength
% 3) Defuzzify
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function y = ron_cri(data_input, net)
    
    disp('Running CRI');
    num_outputs = size(net.output, 2);
    y = zeros(num_outputs);
      
    num_attributes = size(data_input, 2);
    num_rules = size(net.rule, 2);

    antecedent_values = zeros(num_rules, num_attributes);
    consequent_values = zeros(num_rules, num_outputs);
    weights = zeros(num_rules, 1);

    % for all rules, get membership values of antecedents, and consequents
    % and weight values of each rule (layer 2)
    % f2 = o1, o2 = u(f2)
    for i = 1 : num_rules
        weights(i, 1) = net.rule(i).weight;
        for j = 1 : num_attributes
            if net.rule(i).antecedent(j) == 0
                % if membership function is 0, means attribute is reduced.
                % since firing strength is min operator, set some random
                % high number will 'ignore' this attribute
                antecedent_values(i, j) = 100;
            else
                if(net.input(j).mf(net.rule(i).antecedent(j)).params(1) == 0 || net.input(j).mf(net.rule(i).antecedent(j)).params(3) == 0)
                    continue;
                else
                antecedent_values(i, j) = gauss2mf(data_input(j), net.input(j).mf(net.rule(i).antecedent(j)).params);
                if antecedent_values(i, j) == 0
                    antecedent_values(i, j) = 1e-100;
                end
                end
            end
        end
        for j = 1 : num_outputs            
            consequent_values(i, j) = net.rule(i).consequent(j);
        end        
    end

    rule_firing_strength = zeros(num_rules, num_outputs + 2);
    % get firing strength of each rule as minimum of all antecedent
    % membership values (layer 3)
    % f3 = min(o2), o3 = f3
    rule_firing_strength(:, 1) = min(antecedent_values, [], 2);
    rule_firing_strength(:, 2) = weights(:, 1);
    rule_firing_strength(:, 3 : num_outputs + 2) = consequent_values;

    for i = 1 : num_outputs
        numer = 0; denom = 0;
        a = unique(rule_firing_strength(:, i + 2));
        b = zeros(size(a, 1), 3);
        % for each unique consequent fuzzy set in rule base ...
        for j = 1 : size(a, 1)
            b(j, 3) = a(j);
            % find the rule with the maximum firing strength as the
            % consequent membership value (layer 4)
            % f4 = max(o3), o4 = f4
            for k = 1 : num_rules
                if rule_firing_strength(k, 3) == a(j) && rule_firing_strength(k, 1) > b(j, 1)
                    b(j, 1) = rule_firing_strength(k, 1);
                    b(j, 2) = rule_firing_strength(k, 2);
                end
            end
        end
        for j = 1 : size(a, 1)
            % average the widths
            left_width = net.output(i).mf(b(j, 3)).params(1);
            right_width = net.output(i).mf(b(j, 3)).params(3);
            width = (left_width + right_width) / 2;
            % average the centroids
            left_centroid = net.output(i).mf(b(j, 3)).params(2);
            right_centroid = net.output(i).mf(b(j, 3)).params(4);
            centroid = (left_centroid + right_centroid) / 2;
            % get f and w
            firing_strength = b(j, 1);
            weight = b(j, 2);
            % f5 = sum((centroid / width) * f * w) for each consequent
            % fuzzy set fired from rule base
            % o5 = f5 / sum(f * w / width)
            numer = numer + ((centroid / width) * firing_strength * weight);
            denom = denom + (firing_strength * weight / width);            
        end
        y(i) = y(i) + (numer / denom);
    end
end