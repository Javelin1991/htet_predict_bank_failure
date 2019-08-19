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
% function a1 = sus_interpolation(data_input, net, prev_net)
% disp('sus_interpolation');
% 
% antecedent = sus_get_antecedent_mf(data_input, net);        
%    disp(antecedent(1));     
% 
%     disp('Interpolation Start');
%         %declare number of variables
% %         number_of_variables = 2;
% %         number_of_outputs = 1;
% %         number_of_rules = 3;
% %disp(['Processing ', num2str(number_of_variables)]);
% 
%     num_attributes = size(data_input, 2);
%     num_outputs = size(prev_net.output, 2);
%     num_rules = size(prev_net.rule, 2);
%     
%     
% % disp('No of RULES:');
% % disp(num_rules);
% 
%     %declare range of antecedents
%     min_antecedent_ranges = zeros (1,num_attributes);
%     max_antecedent_ranges = zeros (1,num_attributes);
% 
%         for i = 1:1:num_attributes
%             num_mfs = size(prev_net.input(i).mf, 2);
%             min_antecedent_ranges(1,i) = (prev_net.input(i).mf(1).params(2)) - (prev_net.input(i).mf(1).params(1));
%             max_antecedent_ranges(1,i) = (prev_net.input(i).mf(num_mfs).params(2)) + (prev_net.input(i).mf(num_mfs).params(3));
%            
%             
%             
%         end
% 
%         for i = 1:1:num_outputs
%             num_mfs = size(prev_net.output(i).mf, 2)
%             min_consequent_ranges = (prev_net.output(i).mf(1).params(2)) - (prev_net.output(i).mf(1).params(1));
%             max_consequent_ranges = (prev_net.output(i).mf(num_mfs).params(2)) + (prev_net.output(i).mf(num_mfs).params(3));
%             
%         end   
% %         disp('min_consequent_ranges');
% %         disp(min_consequent_ranges);
% %         disp('max_consequent_ranges');
% %         disp(max_consequent_ranges);
% %         
% %         disp('min_antecedent_ranges:');
% %         disp(min_antecedent_ranges);
% %          disp('max_antecedent_ranges:');
% %         disp(max_antecedent_ranges);
%         
%         
%         %declare first rule and antecedents, consequence values
%         r.rules.length = num_rules;
%         
%         for i = 1:1:num_rules
%             r.rules(i).antecedents.length = num_attributes;
%         end
%         observation.antecedents.length = num_attributes;
%         
% 
% for i = 1 : num_rules
% %     if net.rule(i).active == 0
% %             continue;
% %     end
%     
%         r.rules(i).min_antecedent_ranges = min_antecedent_ranges;
%         r.rules(i).max_antecedent_ranges = max_antecedent_ranges;
%         r.rules(i).min_consequent_ranges = min_consequent_ranges;
%         r.rules(i).max_consequent_ranges = max_consequent_ranges;
%     
%     for j = 1 : num_attributes       
%         r.rules(i).antecedent(j).point(1) = (prev_net.input(j).mf(net.rule(i).antecedent(j)).params(2)) - (prev_net.input(j).mf(net.rule(i).antecedent(j)).params(1));
%         r.rules(i).antecedent(j).point(2) = prev_net.input(j).mf(net.rule(i).antecedent(j)).params(2);
%         r.rules(i).antecedent(j).point(3) = (prev_net.input(j).mf(net.rule(i).antecedent(j)).params(2)) + (prev_net.input(j).mf(net.rule(i).antecedent(j)).params(3));  
%     end
%     
%     for j = 1 : num_outputs                   
%         r.rules(i).consequent.point(1) = (prev_net.output(j).mf(net.rule(i).consequent(j)).params(2)) - (prev_net.output(j).mf(net.rule(i).consequent(j)).params(1));
%         r.rules(i).consequent.point(2) = prev_net.output(j).mf(net.rule(i).consequent(j)).params(2);
%         r.rules(i).consequent.point(3) = (prev_net.output(j).mf(net.rule(i).consequent(j)).params(2)) + (prev_net.output(j).mf(net.rule(i).consequent(j)).params(3));
%     end
%     
% end
% 
% for k = 1 : num_attributes  
% 
%         observation.min_antecedent_ranges = min_antecedent_ranges;
%         observation.max_antecedent_ranges = max_antecedent_ranges;
%         observation.min_consequent_ranges = min_consequent_ranges;
%         observation.max_consequent_ranges = max_consequent_ranges;
%         
%         
%  
%         observation.antecedent(k).point(1) = (net.input(k).mf(antecedent.antecedent(k)).params(2)) - (net.input(k).mf(antecedent.antecedent(k)).params(1));
%         observation.antecedent(k).point(2) = net.input(k).mf(antecedent.antecedent(k)).params(2);
%         observation.antecedent(k).point(3) = (net.input(k).mf(antecedent.antecedent(k)).params(2)) + (net.input(k).mf(antecedent.antecedent(k)).params(3));  
%         
% end
% 
% 
% sus_two_nearest_rule(r,observation,3);
% 
%         %forward interpolation A->B
%         %get intermediate rule (A' and B')
%         intermediate_rule = sus_intermediate_rule(r, observation, 5);
% 
%         %transform the intermediate variables (A', B' to A*, B*)
%         transformed_rule = sus_transform(intermediate_rule.shifted_intermediate_rule, observation, 5);
%         %output consequence value
% 
% disp(['Forward interpolation consequence:']);        
% disp([transformed_rule.interpolation.transformed_rule]);
%     
% end
