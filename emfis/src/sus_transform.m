% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_transform XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   
% Syntax    :   sus_transform(intermediate_rule, observation, missing_index)
% 
% 
% Algorithm -
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s6 = sus_transform(intermediate_rule, observation, missing_index)
%disp('sus_transform');

    if ((missing_index >= 0) && (missing_index < observation.antecedents.length))                   
            s6.interpolation = sus_backward_interpolation(intermediate_rule,observation,missingIndex); 
    else
            s6.interpolation = sus_forward_interpolation(intermediate_rule,observation);
    end    
end