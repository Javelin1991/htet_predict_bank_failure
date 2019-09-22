function D = update_sliding_threshold(rule, updateTo, postSignal, forgettor)

timeLag = updateTo - rule.lastUpdate;
if(timeLag > 0)
    offset = forgettor^timeLag;
    if(forgettor == 1)
        inverseForgettor = 0;
    else
        inverseForgettor = 1/(1-forgettor);
    end

    rule.topCache = rule.topCache * offset + (postSignal * postSignal);
    rule.baseCache = rule.baseCache * offset + (1 - offset) * inverseForgettor;
    rule.lastUpdate = updateTo+1;
end
D = rule;

end
