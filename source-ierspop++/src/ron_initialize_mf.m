% XXXXXXXXXXXXXXXXXXXXXXXXXX RON_INITIALIZE_MF XXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Feb 11 2010
% Function  :   generates widths of singleton MFs
% Syntax    :   ron_initialize_mf(net)
% 
% net - FIS network structure
% 
% Algorithm (adapated DIC) -
% 1) Determine slopes of each MF using slope param * attribute range
% 2) Calculate width by reversing gaussian function
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_initialize_mf(net)

    SLOPE = 0.5;
    
    num_attributes = size(net.input, 2);
    num_outputs = size(net.output, 2);
    
    for i = 1 : num_attributes
        min = net.input(i).range(1);
        max = net.input(i).range(2);
        num_mf = size(net.input(i).mf, 2);
        
        width = (SLOPE * (max - min)) / sqrt(2 * log(100));
        
        for j = 1 : num_mf
            net.input(i).mf(j).params(1) = width;
            net.input(i).mf(j).params(3) = width;
        end
        
        net.input(i).range(1) = net.input(i).mf(1).params(2) - (SLOPE * (max - min));
        net.input(i).range(2) = net.input(i).mf(num_mf).params(2) + (SLOPE * (max - min));
    end
    
    for i = 1 : num_outputs
        min = net.output(i).range(1);
        max = net.output(i).range(2);
        num_mf = size(net.output(i).mf, 2);
        
        width = (SLOPE * (max - min)) / sqrt(2 * log(100));
        
        for j = 1 : num_mf
            net.output(i).mf(j).params(1) = width;
            net.output(i).mf(j).params(3) = width;
        end
        
        net.output(i).range(1) = net.output(i).mf(1).params(2) - (SLOPE * (max - min));
        net.output(i).range(2) = net.output(i).mf(num_mf).params(2) + (SLOPE * (max - min));
    end

    D = net;

end
