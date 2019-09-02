function D = ron_removeOutlier(inputs)

    disp('Remove outlier');
	avg = mean(inputs);
    sd = sqrt(var(inputs));
    
    for i = 1 : size(inputs, 1)
        if inputs(i, 1) > (avg + 3*sd)
            outputs(i, 1) = (avg + 3*sd);
        else
            outputs(i, 1) = inputs(i, 1);
        end
    end
    
    D = outputs;

end