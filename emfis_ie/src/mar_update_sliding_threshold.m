% XXXXXXXXXXXXXXXXXXXXX MAR_UPDATE_SLIDING_THRESHOLD XXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Mario Hartanto
% Date      :   Jan 27 2014
% Function  :   updates BCM sliding threhold
% Syntax    :   mar_update_sliding_threshold(rule, updateTo, postSignal, forgettor)
% 
% rule - FIS rule
% 
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


function D = mar_update_sliding_threshold(rule, postSignal, forgettor)

    offset = forgettor;

    if(forgettor == 1)
        inverseForgettor = 0;
    else
        inverseForgettor = 1/(1-forgettor);
    end

    rule.weight = rule.weight * offset;
    rule.topCache = rule.topCache * offset + (postSignal * postSignal);
    rule.baseCache = rule.baseCache * offset + (1 - offset) * inverseForgettor;  

    D = rule;

end

