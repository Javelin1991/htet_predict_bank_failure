function D = semanticRules(ensemble)

    semantic_list = {'M  ';'H  ';'VH ';'VVH ';'L  ';'VL ';'VVL '}; % is a cell array
    rules_semantic = ensemble.rules;

    for i=1:size(ensemble.rules,2)
        index = ensemble.rules(i).belong;
        rules_semantic(i).antecedent = {};
        rules_semantic(i).consequent = {};
        if(size(ensemble.input_mf(index),2) < 8)
            for j=1:size(ensemble.net_struct(1).net.input,2)
                if(ensemble.rules(i).antecedent(j) ~= 0)
                    diff = ensemble.rules(i).antecedent(j) - ceil(size(ensemble.input_mf(index),2));

                    if(diff > 0 && diff < 7)  
                        rules_semantic(i).antecedent{j} = semantic_list{(diff+1)};  
                    elseif (diff < 0)
                        diff2 = 0 - diff; % changing diff to positive    
                        rules_semantic(i).antecedent{j} = semantic_list{(diff2+4)};  
                    else
                        rules_semantic(i).antecedent{j} = semantic_list{1}; 
                    end
                else
                     rules_semantic(i).antecedent{j} = 'N/A';
                end        
            end

            for j=1:size(ensemble.net_struct(1).net.output,2)
                diff = ensemble.rules(i).consequent(j) - ceil(size(ensemble.output_mf(index),2));

                if(diff > 0 && diff < 7)  
                    rules_semantic(i).consequent{j} = semantic_list{(diff+1)};  
                elseif (diff < 0)
                    diff2 = 0 - diff; % changing diff to positive    
                    rules_semantic(i).consequent{j} = semantic_list{(diff2+4)};  
                else
                    rules_semantic(i).consequent{j} = semantic_list{1}; 
                end
            end
        end

    end
    ensemble.rules_semantic = rules_semantic;
    D = ensemble;
end