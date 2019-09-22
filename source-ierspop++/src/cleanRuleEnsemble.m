function D = cleanRuleEnsemble(ensemble)
    
    ensemble.rules = [];
    rules = [];
    num_rules = 0;
    
    for i=1:size(ensemble.net_struct, 2)      
        for j=1:size(ensemble.net_struct(1,i).net.rule,2)
            ensemble.net_struct(1,i).net.rule(j).belong = i;
        end
    end
    
    for i=1:size(ensemble.net_struct, 2)      
        rules = [rules ensemble.net_struct(1, i).net.rule];   
        num_rules = num_rules + ensemble.net_struct(1,i).net.weight * size(ensemble.net_struct(1,i).net.rule,2);
    end
        newNet =  ensemble.net_struct(1).net;
        newNet.rule = rules;
        inputs = ensemble.net_struct(1, size(ensemble.net_struct, 2) ).net.input;
        outputs = ensemble.net_struct(1, size(ensemble.net_struct, 2) ).net.output;
        newNet.input = inputs;
        newNet.output = outputs;
        newNet = ron_clean_pop(newNet);
        ensemble.totalRules = size(newNet.rule, 2);
        rule = zeros(size(newNet.rule, 2), 4);
        
        num_rule = 1;
        weight = 2;
        num_invoked = 3;
        belong = 4;
        for i=1: size(newNet.rule, 2)
               rule(i,num_rule) = i;
               rule(i, weight) = newNet.rule(i).weight;
               rule(i, num_invoked) = newNet.rule(1, i).num_invoked;
               rule(i, belong) = newNet.rule(1, i).belong;
        end
        
        [rule, indexes] = sortrows(rule, [-3, -4, -2]);
        
        if round(num_rules) > size(newNet.rule, 2)
            countRule = size(newNet.rule, 2);
        else
            countRule= round(num_rules);
        end
        for i=1: countRule
           index = rule(i, num_rule);
           new_rules(i).antecedent = newNet.rule(index).antecedent;
           new_rules(i).consequent = newNet.rule(index).consequent;  
           new_rules(i).belong = newNet.rule(index).belong; 
        end
        ensemble.rules = new_rules;
    D = ensemble;
end

