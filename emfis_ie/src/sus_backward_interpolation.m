% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_backward_interpolation XXXXXXXXXXXXXXXXXX
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   
% Syntax    :   sus_backward_interpolation(intermediate_rule, observation, missing_index)
% 
% 
% Algorithm -
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s7 = sus_backward_interpolation(intermediate_rule, observation, missing_index)
disp('sus_backward_interpolation');

    s = 0;
    s_sum = 0;
    m = 0;
    m_sum = 0;


    for i=1:1:observation.antecedents.length

        if(i ~= missing_index)

            s = sus_scale_rate(intermediate_rule.antecedent(i),observation.antecedent(i));
            % System.out.println(i + "'th dimension: " + "s=" + s);

            intermediate_rule.antecedent(i) = sus_scale(intermediate_rule.antecedent(i), s.scale_rate);
            % System.out.println("scaled A" + i + "'':" + intermediateRule.getAntecedents()[i]);

            s_sum = s_sum + s.scale_rate;
            m = sus_move_ratio(intermediate_rule.antecedent(i),observation.antecedent(i));
            % System.out.println(i + "'th dimension: " + "m=" + m);

            transformed_rule.antecedent(i) = sus_move( intermediate_rule.antecedent(i), m.move_ratio);
            m_sum = m_sum + m.move_ratio;
        end
    end


    s = sus_scale_rate(intermediate_rule.consequent,observation.consequent);
    intermediate_rule.consequent = sus_scale(intermediate.consequent,s.scale_rate);

    % System.out.println("Consequence dimension: " + "s=" + s);
    % System.out.println("B'':" + intermediateRule.getConsequence());

    m = sus_move_ratio(intermediate_rule.consequent, observation.consequent );
    transformed_rule.consequent = sus_move(intermediate_rule.consequent,m.move_ratio);
    % System.out.println("Consequence dimension: " + "m=" + m);

    s = s.scale_rate * observation.antecedents.length - s_sum;
    % System.out.println(missingIndex + " dimension: " + "s=" + s);

    m = m.move_ratio * observation.antecedents.length - m_sum;
    % System.out.println(missingIndex + " dimension: " + "m=" + m);

    transformed_rule.antecedent(missing_index) = sus_scale(intermediate_rule.antecedent(missing_index),s.scale_rate);
    % System.out.println("scaled A" + missingIndex + "''" + transformedRule.getAntecedents()[missingIndex].toString());

    transformed_rule.antecedent(missing_index) = sus_move(transformed_rule.antecedent(missingIndex), m.move_ratio);
    % System.out.println("Backward interpolation antecedent:" + missingIndex + transformedRule.getAntecedents()[missingIndex].toString() + transformedRule.getAntecedents()[missingIndex].getRepresentativeValue());

    s7.transformed_rule = transformed_rule;
end