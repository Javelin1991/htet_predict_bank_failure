function D = ron_calc_z(net, rule_struct, data_target)

    cons = rule_struct.consequent;
    num_outputs = size(data_target, 2);
    
    z = zeros(1, num_outputs);
    for i = 1 : num_outputs
        z(i) = gauss2mf(data_target(i), net.output(i).mf(cons(i)).params);
    end
    
    D = min(z);
    
end