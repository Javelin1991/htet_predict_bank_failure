function D = ron_online_backprop(net, data_input, data_target, y)

    disp('Running Backprop');
    learning_rate = 0.8;
    
    err = data_target - y;
    
    num_attributes = size(data_input, 2);
    num_outputs = size(net.output, 2);
    num_rules = size(net.rule, 2);
    
    antecedent_values = zeros(num_rules, num_attributes);
    consequent_values = zeros(num_rules, num_outputs);
    for i = 1 : num_rules
        for j = 1 : num_attributes          
            if net.rule(i).antecedent(j) ~= 0
            antecedent_values(i, j) = gauss2mf(data_input(j), net.input(j).mf(net.rule(i).antecedent(j)).params);
            end
        end
        for j = 1 : num_outputs            
            consequent_values(i, j) = net.rule(i).consequent(j);
        end
    end
    
    rule_firing_strength = zeros(num_rules, num_outputs + 1);
    rule_firing_strength(:, 1) = min(antecedent_values, [], 2);
    rule_firing_strength(:, 2 : num_outputs + 1) = consequent_values;
    
    for i = 1 : num_outputs
        a = unique(rule_firing_strength(:, i + 1));
        a(:, 2) = 0;
        for j = 1 : size(a, 1)
            for k = 1 : num_rules
                if rule_firing_strength(k, 2) == a(j, 1) && rule_firing_strength(k, 1) > a(j, 2)
                    a(j, 2) = rule_firing_strength(k, 1);
                end
            end
        end
        
        left_width = zeros(size(a, 1), 1);
        left_centroid = zeros(size(a, 1), 1);
        right_width = zeros(size(a, 1), 1);
        right_centroid = zeros(size(a, 1), 1);
        
        for j = 1 : size(a, 1)
            left_width(j) = net.output(i).mf(a(j, 1)).params(1);
            left_centroid(j) = net.output(i).mf(a(j, 1)).params(2);
            right_width(j) = net.output(i).mf(a(j, 1)).params(3);
            right_centroid(j) = net.output(i).mf(a(j, 1)).params(4);
        end
        
        for j = 1 : size(a, 1)
            numer = a(j, 2) / left_width(j, 1);
            denom = sum(a(:, 2) ./ left_width(:, 1));
            left_centroid_delta = learning_rate * err * numer / denom;
            
            numer = a(j, 2) / right_width(j, 1);
            denom = sum(a(:, 1) ./ right_width(:, 1));
            right_centroid_delta = learning_rate * err * numer / denom;
            
            numer = (sum(left_centroid(:, 1) .* a(:, 2) ./ left_width(:, 1)) * a(j, 2) * (left_width(j, 1))^(-2)) - ...
                        (sum(a(:, 2) ./ left_width(:, 1)) * left_centroid(j, 1) * a(j, 2) * (left_width(j, 1))^(-2));
            denom = (sum(a(:, 2) ./ left_width(:, 1))^(2));
            left_width_delta = learning_rate * err * numer / denom;
            
            numer = (sum(right_centroid(:, 1) .* a(:, 2) ./ right_width(:, 1)) * a(j, 2) * (right_width(j, 1))^(-2)) - ...
                        (sum(a(:, 2) ./ right_width(:, 1)) * right_centroid(j, 1) * a(j, 2) * (right_width(j, 1))^(-2));
            denom = (sum(a(:, 2) ./ right_width(:, 1))^(2));
            right_width_delta = learning_rate * err * numer / denom;
            
            if data_target < left_centroid
                net.output(i).mf(a(j, 1)).params(1) = left_width(j, 1) + left_width_delta;
                net.output(i).mf(a(j, 1)).params(2) = left_centroid(j, 1) + left_centroid_delta;            
            elseif data_target > right_centroid
                net.output(i).mf(a(j, 1)).params(3) = right_width(j, 1) + right_width_delta;
                net.output(i).mf(a(j, 1)).params(4) = right_centroid(j, 1) + right_centroid_delta;
            end
            
%             
%             if data_target < left_centroid(j, 1)
%                 numer = ((left_centroid(j, 1) / left_width(j, 1)) * (sum(a(:, 2) ./ left_width(:, 1)))) - ...  
%                             (sum(left_centroid(:, 1) .* a(:, 2) ./ left_width(:, 1)) / left_width(j, 1));
%                 denom = (sum(a(:, 2) ./ left_width(:, 1))^(2));
%                 err4(j, 1) = learning_rate * err * numer / denom;
%             elseif data_target > right_centroid(j, 1)
%                 numer = ((right_centroid(j, 1) / right_width(j, 1)) * (sum(a(:, 2) ./ right_width(:, 1)))) - ...  
%                     (sum(right_centroid(:, 1) .* a(:, 2) ./ right_width(:, 1)) / right_width(j, 1));
%                 denom = (sum(a(:, 2) ./ right_width(:, 1))^(2));
%                 err4(j, 1) = learning_rate * err * numer / denom;
%             end
        end
        
%         err2 = sum(err4);
%         
%         for j = 1 : num_attributes
%             for k = 1 : size(net.input(j).mf, 2)
%                 o1 = data_input(j);
%                 o2 = gauss2mf(data_input(j), net.input(j).mf(k).params);
%                 left_width = net.input(j).mf(k).params(1);
%                 left_centroid_delta = err2 * o2 * 2 * (o1 - o2) / (left_width ^ 2);
%                 left_width_delta = err2 * o2 * (o1 - o2) / (left_width ^ 3);
%             end
%         end
    end
    
    D = net;

end