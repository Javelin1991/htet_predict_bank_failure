function plotFuzzy(inputs, boolean)
        
for i=1:size(inputs,2)
        input = inputs(1,i);
        if ~(isempty(input.range))
                figure;
        if boolean
        mf = input.mf;
        else
        mf = input.new_mf;
        end
        for i=1:size(mf,2)
        if ~(isempty(mf(1,i).params))
        x = input.range(1):(input.range(2)-input.range(1))/200:1*input.range(2);
        y1 = gauss2mf(x, mf(1,i).params);
        hold all;
        plot(x, y1);
        end
        end
        end
end
end