% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_shift XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   
% Syntax    :   sus_shift( r, intermediate_fuzzy_rule, observation, missing_index)
% 
% Algorithm -
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s3 = sus_shift( r, intermediate_fuzzy_rule, observation, missing_index)
%disp('sus_shift');

    shifted_intermediate_fuzzy_rule.antecedents.length = intermediate_fuzzy_rule.antecedents.length;
    delta = 0;
    delta_sum = 0;

    if (missing_index >= intermediate_fuzzy_rule.antecedents.length)
        % forward
        for i=1:1:intermediate_fuzzy_rule.antecedents.length

            distance =  sus_distance_to(observation.antecedent(i),intermediate_fuzzy_rule.antecedent(i));
            delta = distance / (intermediate_fuzzy_rule.max_antecedent_ranges(1,i) - intermediate_fuzzy_rule.min_antecedent_ranges(1,i));

            shifted_intermediate_fuzzy_rule.antecedent(i).point(1) = intermediate_fuzzy_rule.antecedent(i).point(1) + (delta* (intermediate_fuzzy_rule.max_antecedent_ranges(i) - intermediate_fuzzy_rule.min_antecedent_ranges(i)));
            shifted_intermediate_fuzzy_rule.antecedent(i).point(2) = intermediate_fuzzy_rule.antecedent(i).point(2) + (delta* (intermediate_fuzzy_rule.max_antecedent_ranges(i) - intermediate_fuzzy_rule.min_antecedent_ranges(i)));
            shifted_intermediate_fuzzy_rule.antecedent(i).point(3) = intermediate_fuzzy_rule.antecedent(i).point(3) + (delta* (intermediate_fuzzy_rule.max_antecedent_ranges(i) - intermediate_fuzzy_rule.min_antecedent_ranges(i)));

            delta_sum = delta_sum + delta ;
            % disp(['Delta A']);
            % disp(i);
            % disp([delta]);
            % disp(['Distance of A']);
            % disp([distance]);
            %             }
        end
        
        delta = delta_sum / intermediate_fuzzy_rule.antecedents.length;
        % disp(['Delta B']);
        % disp([delta]);
        
        shifted_intermediate_fuzzy_rule.consequent.point(1) = intermediate_fuzzy_rule.consequent.point(1) + (delta * (intermediate_fuzzy_rule.max_consequent_ranges - intermediate_fuzzy_rule.min_consequent_ranges));
        shifted_intermediate_fuzzy_rule.consequent.point(2) = intermediate_fuzzy_rule.consequent.point(2) + (delta * (intermediate_fuzzy_rule.max_consequent_ranges - intermediate_fuzzy_rule.min_consequent_ranges));
        shifted_intermediate_fuzzy_rule.consequent.point(3) = intermediate_fuzzy_rule.consequent.point(3) + (delta * (intermediate_fuzzy_rule.max_consequent_ranges - intermediate_fuzzy_rule.min_consequent_ranges));
        % disp(['(f)shifted B''']);
        % disp([shifted_intermediate_fuzzy_rule.consequent]);
        %             System.out.println(delta * (intermediateRule.getMaxConsequenceRange() - intermediateRule.getMinConsequenceRange()));
        %
        % disp([delta * (intermediate_fuzzy_rule.max_consequent_ranges - intermediate_fuzzy_rule.min_consequent_ranges)]);
    else


        for i=1:1:intermediate_fuzzy_rule.antecedents.length

            if (i ~= missing_index)

                delta = sus_distance_to(observation.antecedent(i),intermediate_fuzzy_rule.antecedent(i)) /(intermediate_fuzzy_rule.max_antecedent_ranges(i) - intermediate_fuzzy_rule.min_antecedent_ranges(i));

                shifted_intermediate_fuzzy_rule.antecedent(i).point(1) = intermediate_fuzzy_rule.antecedent(i).point(1) + (delta *(intermediate_fuzzy_rule.max_antecedent_ranges(i) - intermediate_fuzzy_rule.min_antecedent_ranges(i)));
                shifted_intermediate_fuzzy_rule.antecedent(i).point(2) = intermediate_fuzzy_rule.antecedent(i).point(2) + (delta *(intermediate_fuzzy_rule.max_antecedent_ranges(i) - intermediate_fuzzy_rule.min_antecedent_ranges(i)));
                shifted_intermediate_fuzzy_rule.antecedent(i).point(3) = intermediate_fuzzy_rule.antecedent(i).point(3) + (delta *(intermediate_fuzzy_rule.max_antecedent_ranges(i) - intermediate_fuzzy_rule.min_antecedent_ranges(i)));

                % System.out.println("shifted A'" + i + ":" + shiftedIntermediateRule.getAntecedent(i));
                delta_sum = delta_sum + delta;
                %  System.out.println("Delta A" + i + " " + delta);
            end
        end

        delta = sus_distance_to (observation.consequent, intermediate_fuzzy_rule.consequent) /(intermediate_fuzzy_rule.max_consequent_ranges - intermediate_fuzzy_rule.min_consequent_ranges);
        %  System.out.println("Delta B " + delta);

        shifted_intermediate_fuzzy_rule.consequent.point(1) = intermediate_fuzzy_rule.consequent.point(1) + (delta * (intermediate_fuzzy_rule.max_consequent_ranges - intermediate_fuzzy_rule.min_consequent_ranges));
        shifted_intermediate_fuzzy_rule.consequent.point(2) = intermediate_fuzzy_rule.consequent.point(2) + (delta * (intermediate_fuzzy_rule.max_consequent_ranges - intermediate_fuzzy_rule.min_consequent_ranges));
        shifted_intermediate_fuzzy_rule.consequent.point(3) = intermediate_fuzzy_rule.consequent.point(3) + (delta * (intermediate_fuzzy_rule.max_consequent_ranges - intermediate_fuzzy_rule.min_consequent_ranges));

        % System.out.println("(b)shifted B'" + ":" + shiftedIntermediateRule.getConsequence() + " " + shiftedIntermediateRule.getConsequence().getRepresentativeValue());

        delta = delta * intermediate_fuzzy_rule.antecedents.length - delta_sum;
        % System.out.println("Delta A" + missingIndex + " " + delta);

        shifted_intermediate_fuzzy_rule.antecedent(missingIndex).point(1) = intermediate_fuzzy_rule.antecedent(missingIndex).point(1)+ (delta * (intermediate_fuzzy_rule.max_antecedent_ranges(missing_index) -intermediate_fuzzy_rule.min_antecedent_ranges(missing_index)));
        shifted_intermediate_fuzzy_rule.antecedent(missingIndex).point(2) = intermediate_fuzzy_rule.antecedent(missingIndex).point(2)+ (delta * (intermediate_fuzzy_rule.max_antecedent_ranges(missing_index) -intermediate_fuzzy_rule.min_antecedent_ranges(missing_index)));
        shifted_intermediate_fuzzy_rule.antecedent(missingIndex).point(3) = intermediate_fuzzy_rule.antecedent(missingIndex).point(3)+ (delta * (intermediate_fuzzy_rule.max_antecedent_ranges(missing_index) -intermediate_fuzzy_rule.min_antecedent_ranges(missing_index)));


        % System.out.println("shifted A'" + missingIndex + ":" + shiftedIntermediateRule.getAntecedent(missingIndex));

    end

    s3.shifted_intermediate_fuzzy_rule = shifted_intermediate_fuzzy_rule;


end