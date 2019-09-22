function  D=delete_orphan_labels(ensemble)

for i=1:size(ensemble.net_struct,2)
    ensemble.input_mf(i).input = ensemble.net_struct(1,i).net.input;
    ensemble.output_mf(i).output = ensemble.net_struct(1,i).net.output;
end

for i=1:size(ensemble.net_struct,2)
    for j=1:size(ensemble.input_mf(1,i).input,2)
        ensemble.input_mf(1,i).input(1,j).mfBoolean = zeros(size(ensemble.input_mf(1,i).input(1,j).mf,2),1);
    end
    
    for j=1:size(ensemble.output_mf(1,i).output,2)
        ensemble.output_mf(1,i).output(1,j).mfBoolean = zeros(size(ensemble.output_mf(1,i).output(1,j).mf,2),1);
    end
       
end

for i=1:size(ensemble.rules,2)
    index = ensemble.rules(i).belong;
    antecedent = ensemble.rules(i).antecedent;
    consequent = ensemble.rules(i).consequent;
    for j=1:size(ensemble.input_mf(1,index).input,2)
        member = antecedent(j);
        if(member~=0)
        ensemble.input_mf(1,index).input(j).mfBoolean(member) = ensemble.input_mf(1,index).input(j).mfBoolean(member) + 1;
        end
    end
    for j=1:size(ensemble.output_mf(1,index).output,2)
        member = consequent(j);
        if(member~=0)
        ensemble.output_mf(1,index).output(j).mfBoolean(member) = ensemble.output_mf(1,index).output(j).mfBoolean(member) + 1;
        end
    end  
    
end

for i=1:size(ensemble.net_struct,2)
    for j=1:size(ensemble.input_mf(1,i).input,2)
        if sum(ensemble.input_mf(1,i).input(1,j).mfBoolean) == 0
            ensemble.input_mf(1,i).input(1,j).range = [];
            ensemble.input_mf(1,i).input(1,j).min = 0;
            ensemble.input_mf(1,i).input(1,j).max=0;
            ensemble.input_mf(1,i).input(1,j).mf=[];
         else
            for k=1:size(ensemble.input_mf(1,i).input(1,j).mfBoolean,1)
                if(ensemble.input_mf(1,i).input(1,j).mfBoolean(k) == 0)
                    ensemble.input_mf(1,i).input(1,j).mf(k).params = [];
                    ensemble.input_mf(1,i).input(1,j).mf(k).plasticity = 0;
                    ensemble.input_mf(1,i).input(1,j).mf(k).tendency= 0;
                    ensemble.input_mf(1,i).input(1,j).mf(k).num_expanded= 0;
                end
            end
        end
    end
    for j=1:size(ensemble.output_mf(1,i).output,2)
        if sum(ensemble.output_mf(1,i).output(1,j).mfBoolean) == 0
            ensemble.output_mf(1,i).output(1,j).range = [];
            ensemble.output_mf(1,i).output(1,j).min = 0;
            ensemble.output_mf(1,i).output(1,j).max=0;
            ensemble.output_mf(1,i).output(1,j).mf=[];
        else
            for k=1:size(ensemble.output_mf(1,i).output(1,j).mfBoolean,1)
                if(ensemble.output_mf(1,i).output(1,j).mfBoolean(k) == 0)
                    ensemble.output_mf(1,i).output(1,j).mf(k).params = [];
                    ensemble.output_mf(1,i).output(1,j).mf(k).plasticity = 0;
                    ensemble.output_mf(1,i).output(1,j).mf(k).tendency= 0;
                    ensemble.output_mf(1,i).output(1,j).mf(k).num_expanded= 0;
                end
            end
        end
    end  

end

for i=1:size(ensemble.net_struct,2)
    for j=1:size(ensemble.input_mf(1,i).input,2)
          if  ~isempty(ensemble.input_mf(1,i).input(1,j).mf)
          num=1;
          mf = [];
          for k=1:size(ensemble.input_mf(1,i).input(1,j).mfBoolean,1)
             if ~isempty(ensemble.input_mf(1,i).input(1,j).mf(k).params)
                 ensemble.input_mf(1,i).input(1,j).mf(k).index = num;
                 mf(num).params = ensemble.input_mf(1,i).input(1,j).mf(k).params;
                 mf(num).plasticity = ensemble.input_mf(1,i).input(1,j).mf(k).plasticity;
                 mf(num).tendency = ensemble.input_mf(1,i).input(1,j).mf(k).tendency;
                 mf(num).num_expanded = ensemble.input_mf(1,i).input(1,j).mf(k).num_expanded;
                 num = num + 1;
             end
          end
          ensemble.input_mf(1,i).input(1,j).new_mf = mf;
          end
    end
    for j=1:size(ensemble.output_mf(1,i).output,2)
          if  ~isempty(ensemble.output_mf(1,i).output(1,j).mf)
          mf = [];
          num=1;
          for k=1:size(ensemble.output_mf(1,i).output(1,j).mfBoolean,1)
             if ~isempty(ensemble.output_mf(1,i).output(1,j).mf(k).params)
                 ensemble.output_mf(1,i).output(1,j).mf(k).index = num;
                 mf(num).params = ensemble.output_mf(1,i).output(1,j).mf(k).params;
                 mf(num).plasticity = ensemble.output_mf(1,i).output(1,j).mf(k).plasticity;
                 mf(num).tendency = ensemble.output_mf(1,i).output(1,j).mf(k).tendency;
                 mf(num).num_expanded = ensemble.output_mf(1,i).output(1,j).mf(k).num_expanded;
                 num = num + 1;
             end
          end
          ensemble.output_mf(1,i).output(1,j).new_mf = mf;
          end
    end
    
end

for rules=1:size(ensemble.rules,2)
    rule = ensemble.rules(rules);
    antecedent = rule.antecedent;
    consequent = rule.consequent;
    for m=1:size(antecedent,2)
        if(antecedent(m) ~=0)
            index = ensemble.input_mf(1, rule.belong).input(1,m).mf(antecedent(m)).index;
            antecedent(m) = index;
        end
    end

    for m=1:size(consequent,2)
        if(consequent(m) ~=0)
            index = ensemble.output_mf(1, rule.belong).output(1,m).mf(consequent(m)).index;
            consequent(m) = index;
        end
    end

    ensemble.rules(rules).antecedent = antecedent;
    ensemble.rules(rules).consequent = consequent;
end

for i=1:size(ensemble.net_struct,2)
    for j=1:size(ensemble.input_mf(1,i).input,2)
        input_mf(1,i).input(1,j)= rmfield(ensemble.input_mf(1,i).input(1,j), {'mf';'mfBoolean'});
    end
        ensemble.input_mf(1,i).input =  input_mf(1,i).input;
    for j=1:size(ensemble.output_mf(1,i).output,2)
        output_mf(1,i).output(1,j) = rmfield(ensemble.output_mf(1,i).output(1,j), {'mf';'mfBoolean'});
    end
        ensemble.output_mf(1,i).output =  output_mf(1,i).output;
end

D = ensemble;
end