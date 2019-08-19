% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_intermediate_rule XXXXXXXXXXXXXXXXXXXXXXX
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :
% Syntax    :   sus_intermediate_rule(r,observation, missing_index)
%
% r             - rules used for interpolation or extrapolation
% observation   - observation
%
% Algorithm -
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s2 = sus_intermediate_rule(r,observation, missing_index)
%disp('sus_intermediate_rule');

    intermediate_fuzzy_rule.antecedents.length = observation.antecedents.length;
    intermediate_fuzzy_rule.min_antecedent_ranges = r.rules(1).min_antecedent_ranges;
    intermediate_fuzzy_rule.max_antecedent_ranges = r.rules(1).max_antecedent_ranges;
    intermediate_fuzzy_rule.min_consequent_ranges = r.rules(1).min_consequent_ranges;
    intermediate_fuzzy_rule.max_consequent_ranges = r.rules(1).max_consequent_ranges;

    r_rules_length = r.rules.length;
    term_weights = zeros( r_rules_length, observation.antecedents.length+1 );

    for i=1:1:r_rules_length

        for j=1:1:r.rules(i).antecedents.length
            if (j ~= missing_index)
                % System.out.println("r.rules" + i + "Antecedent" + j + r.rules[i].getAntecedent(j).toStringInt() + " vs " + "observation.Antecedent" + j + observation.getAntecedent(j).toStringInt());
                antecedent_distance = sus_abs_distance_to(r.rules(i).antecedent(j),observation.antecedent(j));
                term_weights(i,j) = 1 / antecedent_distance;
                % System.out.println("A*" + j + "termWeights to R" + i + j + ":" + termWeights[i][j]);
            end
        end


        if ( missing_index < observation.antecedents.length )
            % System.out.println("B*" + "termWeights to B" + i + ":" + termWeights[i][observation.getNumberOfAntecedents()]);
            consequent_distance = sus_abs_distance_to(r.rules(i).consequent,observation.consequent);
            term_weights(i,observation.antecedents.length+1) = 1 / consequent_distance ;
        end
    end

    s2.term_weights = term_weights ;
    % disp('Raw term weight');
    % disp([s2.term_weights]);

    w_sum = 0;
    for i=1:1:observation.antecedents.length
        if(i ~= missing_index)
            w_sum = 0;
            for j=1:1:r_rules_length
                w_sum = w_sum + s2.term_weights(j,i);
            end

            for j=1:1:r_rules_length
                normalized_term_weights(j,i) = s2.term_weights(j,i)/w_sum;
                % System.out.println("A*" + i + "NormlisedtermWeights " + ":" + termWeights[j][i]);
            end
        end
    end


    if (missing_index < observation.antecedents.length)

        w_sum = 0;

        for j=1:1:r_rules_length
            w_sum = w_sum + s2.term_weights(j,observation.antecedents.length);
        end

        for j=1:1:r_rules_length
            % System.out.println("B*" + "NormlisedtermWeights to B" + j + ":" + termWeights[j][observation.getNumberOfAntecedents()]);
            normalized_term_weights(j,observation.antecedents.length+1) = s2.term_weights(j,observation.antecedents.length+1) / w_sum;
        end

    end

    s2.normalized_term_weights = normalized_term_weights;
    %disp('Normalised Weights:');
    %disp([s2.normalized_term_weights]);

    % System.out.print("---- IntermediateFuzzyRule\n");

    for i=1:1:r.rules(1).antecedents.length
        if(i ~= missing_index)
            antecedent_points_length = 3;
            for m=1:1:antecedent_points_length
                points(m) = 0;
            end

            for j=1:1:r_rules_length
                for k=1:1:antecedent_points_length
                    points(k) = points(k) + s2.normalized_term_weights(j,i) * r.rules(j).antecedent(i).point(k);
                end
            end

            intermediate_fuzzy_rule.antecedent(i).point(1) = points(1);
            intermediate_fuzzy_rule.antecedent(i).point(2) = points(2);
            intermediate_fuzzy_rule.antecedent(i).point(3) = points(3);
            % System.out.println("A''[" + i + "] = " + intermediateFuzzyRule.getAntecedent(i));
        end
    end

    if (missing_index < r.rules(1).antecedents.length)

        consequent_points_length = 3;
        for m=1:1:consequent_points_length
            points(m) = 0;
        end

        for(j=1:1:r_rules_length)
            for k=1:1:consequent_points_length
                points(k) = points(k) + s2.normalized_term_weights(j,r.rules(0).antecedents.length) * r.rules(j).consequent.point(k);
            end
        end

        intermediate_fuzzy_rule.consequent.point(1) = points(1);
        intermediate_fuzzy_rule.consequent.point(2) = points(2);
        intermediate_fuzzy_rule.consequent.point(3) = points(3);
        % System.out.println("B'' = " + intermediateFuzzyRule.getConsequence());

    end

    %  System.out.println("\nIntermediate Rule:\n" + intermediateFuzzyRule);
    s2.intermediate_fuzzy_rule = intermediate_fuzzy_rule ;

    if ((missing_index >= 0) & (missing_index < observation.antecedents.length))
        % backward

        antecedent_points_length = 3;
        w_sum = 0;

        for i=1:1:r_rules_length
            w_sum = 0;
            for j=1:1:r.rules(1).antecedents.length
                if (j ~= missing_index)
                    w_sum = w_sum + s2.normalized_term_weights(i,j);
                end
            end

            for m=1:1:antecedent_points_length
                points(m) = 0;
            end

            s2.normalized_term_weights(i,missing_index) = s2.normalized_term_weights(i,r.rules(1).antecedents.length +1) / r.rules(1).antecedents.length - w_sum;

            for k=1:1:antecedent_points_length
                points(k) = points(k) + s2.normalized_term_weights(i,missing_index) * r.rules(i).antecedent(missing_index).point(k);
            end

        end

        s2.intermediate_fuzzy_rule.antecedent(missing_index).point(1) = points(1);
        s2.intermediate_fuzzy_rule.antecedent(missing_index).point(2) = points(2);
        s2.intermediate_fuzzy_rule.antecedent(missing_index).point(3) = points(3);
        % disp(['intermediate A'':' , missing_index , ''':' ,  s2.intermediate_fuzzy_rule.antecedent(missing_index)]);
 
    else
        %  forward
        consequent_points_length = 3;
        for m=1:1:consequent_points_length
            points(m) = 0;
        end

        w_sum = 0;
        for i=1:1:r_rules_length
            w_sum = 0;

            for j=1:1:r.rules(1).antecedents.length
                w_sum = w_sum + s2.normalized_term_weights(i,j);
            end

            s2.normalized_term_weights(i,r.rules(1).antecedents.length+1) = w_sum / r.rules(1).antecedents.length;
            for k=1:1:consequent_points_length
                points(k) = points(k) + s2.normalized_term_weights(i,r.rules(1).antecedents.length+1) * r.rules(i).consequent.point(k);
            end

            s2.intermediate_fuzzy_rule.consequent.point(1) = points(1);
            s2.intermediate_fuzzy_rule.consequent.point(2) = points(2);
            s2.intermediate_fuzzy_rule.consequent.point(3) = points(3);

            % disp(['intermediate B":']);
            % disp( [s2.intermediate_fuzzy_rule.consequent]);

            consequent_weight_sum = 0;

            for i=1:1:r_rules_length
                consequent_weight = 1/ abs(sus_distance_to(s2.intermediate_fuzzy_rule.consequent,r.rules(i).consequent) -0.092990205*15);
                consequent_weight_sum = consequent_weight_sum + consequent_weight;
            end
            
            for i=1:1:r_rules_length
                consequent_weight2 = 1/ abs(sus_distance_to(s2.intermediate_fuzzy_rule.consequent,r.rules(i).consequent) -0.092990205*15);
                consequent_weight2 = consequent_weight2 / consequent_weight_sum;
                % System.out.print(consequenceWeight2 + "\t");
            end
        end

        % disp('Normalised Weights: ');
        % disp([s2.normalized_term_weights]);

        shift = sus_shift( r, s2.intermediate_fuzzy_rule, observation, missing_index);
        consequent_weight_sum = 0;

        for i=1:1:r_rules_length
            consequent_weight = 1 / sus_abs_distance_to(shift.shifted_intermediate_fuzzy_rule.consequent,r.rules(i).consequent);
            consequent_weight_sum = consequent_weight_sum + consequent_weight;
        end

        for i=1:1:r_rules_length
            consequent_weight2 = 1 / sus_abs_distance_to (shift.shifted_intermediate_fuzzy_rule.consequent,r.rules(i).consequent);
            consequent_weight2 = consequent_weight2 / consequent_weight_sum;
            % disp([consequent_weight2]);
        end

        s2.shifted_intermediate_rule = shift.shifted_intermediate_fuzzy_rule;
end
