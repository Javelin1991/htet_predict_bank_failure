function [ output_args ] = combineRules( ensemble, net )


    num_attributes = size(net.input, 2);
    num_outputs = size(net.output, 2);
    num_rules = size(net.rule, 2);  

    % collate rules data into database matrix
    weight_col = num_attributes + num_outputs + 1;
    conn_col = num_attributes + num_outputs + 2;
    invoked_col = num_attributes + num_outputs + 3;
    
    rule_database = zeros(num_rules, num_attributes + num_outputs + 3);
    
    for i = 1 : num_rules
        rule_database(i, 1 : num_attributes) = net.rule(i).antecedent;
        rule_database(i, num_attributes + 1 : num_attributes + num_outputs) = net.rule(i).consequent;
        rule_database(i, weight_col) = net.rule(i).weight;
        rule_database(i, conn_col) = net.rule(i).connection;
        rule_database(i, invoked_col) = net.rule(i).num_invoked;
    end
    

    for i = 1 : num_rules
        for j = 1 : num_rules
            % find rules with same antecendents but different consequents
            if sum(rule_database(i, 1 : num_attributes) == rule_database(j, 1 : num_attributes)) == num_attributes && ...
                    sum(rule_database(i, num_attributes + 1 : num_attributes + num_outputs) == rule_database(j, num_attributes + 1 : num_attributes + num_outputs)) ~= num_outputs && ...
                        i ~= j
                % keep only the rule with higher weight
                if rule_database(i, weight_col) > rule_database(j, weight_col)
                    rule_database(i, invoked_col) = rule_database(i, invoked_col) + rule_database(j, invoked_col);
                    rule_database(j, :) = 0;
                else
                    rule_database(j, invoked_col) = rule_database(j, invoked_col) + rule_database(i, invoked_col);
                    rule_database(i, :) = 0;
                end
            % remove duplicate rules
            elseif sum(rule_database(i, 1 : num_attributes) == rule_database(j, 1 : num_attributes)) == num_attributes && ...
                    sum(rule_database(i, num_attributes + 1 : num_attributes + num_outputs) == rule_database(j, num_attributes + 1 : num_attributes + num_outputs)) == num_outputs && ...
                        i ~= j
                % add weights together
                rule_database(i, weight_col) = rule_database(i, weight_col) + rule_database(j, weight_col);
                rule_database(i, invoked_col) = rule_database(i, invoked_col) + rule_database(j, invoked_col);
                rule_database(j, :) = 0;
            end            
        end
    end

    % rebuild rule structure
    num_new_rules = 1;
    for i = 1 : num_rules        
        if sum(rule_database(i, :)) ~= 0
            new_rule_struct(num_new_rules).antecedent = rule_database(i, 1 : num_attributes);
            new_rule_struct(num_new_rules).consequent = rule_database(i, num_attributes + 1 : num_attributes + num_outputs);
            new_rule_struct(num_new_rules).weight = rule_database(i, weight_col);
            new_rule_struct(num_new_rules).connection = rule_database(i, conn_col);
            new_rule_struct(num_new_rules).num_invoked = rule_database(i, invoked_col);
            num_new_rules = num_new_rules + 1;
        end
    end
    
    net.rule = new_rule_struct;    
    net = ron_normalize_weights(net);
    D = net;



end

