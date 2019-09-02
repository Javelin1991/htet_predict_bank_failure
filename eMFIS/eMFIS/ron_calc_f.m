function D = ron_calc_f(net, rule_struct, data_input)

    ante = rule_struct.antecedent;
    num_attributes = size(data_input, 2);
    
    f = zeros(1, num_attributes);
    for i = 1 : num_attributes
        f(i) = gauss2mf(data_input(i), net.input(i).mf(ante(i)).params);
    end
    
    D = min(f);
    
end