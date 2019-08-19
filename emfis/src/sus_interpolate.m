% % XXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% % 
% % Author    :   Susanti
% % Date      :   Aug 1 2014
% % Function  :   
% % Syntax    :   
% % 
% 
% % 
% % Algorithm -
% 
% % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% function s1 = sus_interpolate()
% disp('sus_interpolate');
% 
% disp('Interpolate Start');
%         %declare number of variables
%         number_of_variables = 2;
%         number_of_outputs = 1;
%         number_of_rules = 3;
% %disp(['Processing ', num2str(number_of_variables)]);
% 
%         
%         %declare range of antecedents
%         min_antecedent_ranges = zeros (1,number_of_variables);
%         max_antecedent_ranges = zeros (1,number_of_variables);
%         for i = 1:1:number_of_variables
%         
%             min_antecedent_ranges(1,i) = 0;
%             max_antecedent_ranges(1,i) = 15;
%         end
% 
%         %declare first rule and antecedents, consequence values
%         r.rules.length = 3;
%         
%         for i = 1:1:number_of_rules
%             r.rules(i).antecedents.length = 2;
%         end
%         
%       
%         observation.antecedents.length = 2;
%         
%        
%         r.rules(1).min_antecedent_ranges = min_antecedent_ranges;
%         r.rules(1).max_antecedent_ranges = max_antecedent_ranges;
%         r.rules(1).min_consequent_ranges = 0;
%         r.rules(1).max_consequent_ranges = 15;
%         
%         r.rules(1).antecedent(1).point(1) = 0;
%         r.rules(1).antecedent(1).point(2) = 1;
%         r.rules(1).antecedent(1).point(3) = 3;
%         
%         r.rules(1).antecedent(2).point(1) = 1;
%         r.rules(1).antecedent(2).point(2) = 2;
%         r.rules(1).antecedent(2).point(3) = 3;
%         
%         r.rules(1).consequent.point(1) = 0;
%         r.rules(1).consequent.point(2) = 2;
%         r.rules(1).consequent.point(3) = 3;
%   
%         %declare first rule and antecedents, consequence values
%        
%         r.rules(2).min_antecedent_ranges = min_antecedent_ranges;
%         r.rules(2).max_antecedent_ranges = max_antecedent_ranges;
%         r.rules(2).min_consequent_ranges = 0;
%         r.rules(2).max_consequent_ranges = 15;
%         
%         r.rules(2).antecedent(1).point(1) = 8;
%         r.rules(2).antecedent(1).point(2) = 9;
%         r.rules(2).antecedent(1).point(3) = 10;
%         
%         r.rules(2).antecedent(2).point(1) = 7;
%         r.rules(2).antecedent(2).point(2) = 9;
%         r.rules(2).antecedent(2).point(3) = 10;
%         
%         r.rules(2).consequent.point(1) = 9;
%         r.rules(2).consequent.point(2) = 10;
%         r.rules(2).consequent.point(3) = 11;
% 
%         %declare second rule and antecedents, consequence values
%         
%         r.rules(3).min_antecedent_ranges = min_antecedent_ranges;
%         r.rules(3).max_antecedent_ranges = max_antecedent_ranges;
%         r.rules(3).min_consequent_ranges = 0;
%         r.rules(3).max_consequent_ranges = 15;
%         
%         r.rules(3).antecedent(1).point(1) = 11;
%         r.rules(3).antecedent(1).point(2) = 13;
%         r.rules(3).antecedent(1).point(3) = 14;
%         
%         r.rules(3).antecedent(2).point(1) = 11;
%         r.rules(3).antecedent(2).point(2) = 12;
%         r.rules(3).antecedent(2).point(3) = 13;
%         
%         r.rules(3).consequent.point(1) = 12;
%         r.rules(3).consequent.point(2) = 13;
%         r.rules(3).consequent.point(3) = 14;
% 
%         %declare consequence and antecedents, consequence values
%         
%         observation.min_antecedent_ranges = min_antecedent_ranges;
%         observation.max_antecedent_ranges = max_antecedent_ranges;
%         observation.min_consequent_ranges = 0;
%         observation.max_consequent_ranges = 15;
%         
%         observation.antecedent(1).point(1) = 3.5;
%         observation.antecedent(1).point(2) = 5;
%         observation.antecedent(1).point(3) = 7;
%         
%         observation.antecedent(2).point(1) = 5;
%         observation.antecedent(2).point(2) = 6;
%         observation.antecedent(2).point(3) = 7;
%      
%         %Rule[] rules = new Rule[]{rule0, rule1, rule2};
%         %forward interpolation A->B
%         %get intermediate rule (A' and B')
%         intermediate_rule = sus_intermediate_rule(r, observation, 3);
% %disp([intermediate_rule.shifted_intermediate_rule.antecedent(1)]);
% %disp([intermediate_rule.shifted_intermediate_rule.antecedent(2)]);
% %disp([intermediate_rule.shifted_intermediate_rule.consequent]);
%         %transform the intermediate variables (A', B' to A*, B*)
%         transformed_rule = sus_transform(intermediate_rule.shifted_intermediate_rule, observation, 3);
%         %output consequence value
%         %System.out.println("Forward interpolation consequence:" + transformedRule.getConsequence().toString());
% disp(['Forward interpolation consequence:']);        
%         %System.out.println("Forward interpolation consequence:" + transformedRule.getConsequence() + " " + transformedRule.getConsequence().getRepresentativeValue());
% disp([transformed_rule.interpolation.transformed_rule]);
% end
