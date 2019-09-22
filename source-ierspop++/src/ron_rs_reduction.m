% XXXXXXXXXXXXXXXXXXXXXXXXXXXX RON_RSMERGE_MF XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Feb 09 2010
% Function  :   performs attribute reduction using rough set theory
% Syntax    :   ron_rs_reduction(net, stored_input)
% 
% net - FIS network structure
% stored_input - historical input data
% 
% Algorithm -
% 1) Calculate baseline objective measure using stored data
% 2) Uses a while loop and checks for rule consistency by removing attributes
% 3) If rules are consistent, remove attribute and recalculate new baseline objective measure
% 4) If objective measure is reduced, cannot reduce, else use reduced.
% 5) Repeat step 1 with new rules
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_rs_reduction(net, stored_input)

    disp('RS Reduction');
    num_rules = size(net.rule, 2);
    num_attributes = size(net.input, 2);
        
    num_reduced = 0;
    
    % XXXXXXXXXXXXXXXXXXXXXXX ATTRIBUTE REDUCTION XXXXXXXXXXXXXXXXXXXXXXXXX
    for i = 1 : num_attributes
        
        % check termination condition
        if num_reduced == num_attributes - 1
            disp('Last attribute cannot be reduced');
            D = net;
            return;
        end
           
        % remove attributes and check for rule consistency
        if ron_check_consistency2(net, i)
            % if consistent, backup structures, and attempt reduction
            backup_rule = net.rule;
                
            % calculate baseline objective measure before merging
            bom = ron_check_bom(net, stored_input);
            
            % remove attribute from rule base
            for j = 1 : num_rules
                net.rule(j).antecedent(1, i) = 0;
            end

            % calculate new objective measure after reduction
            nbom = ron_check_bom(net, stored_input);
                
            % check if results deteriorated i.e. new objective measure
            % lower than baseline objective measure
            deteriorate = 0;
            for j = 1 : size(bom, 1)
                for k = 1 : size(bom, 2)
                    if nbom(j, k) < bom(j, k)
                        deteriorate = 1;
                        break;
                    end
                end
                if deteriorate
                    break;
                end
            end

            if deteriorate
                disp(['Attribute ', num2str(i), ' reduction consistent ...... results deteriorated, cannot reduce']);
                % if results deteriorated, replace backup structures
                net.rule = backup_rule;
            else
                disp(['Attribute ', num2str(i), ' reduction consistent ...... results improved, use reduced']);
                num_reduced = num_reduced + 1;
            end
            clear backup_rule bom nbom;
        else
            disp(['Attribute ', num2str(i), ' reduction inconsistent']);
        end            
    end % end for

%     % XXXXXXXXXXXXXXXXXXXXXXXXXX RULE REDUCTION XXXXXXXXXXXXXXXXXXXXXXXXXXX
%     for i = 1 : num_rules
% 
%         num_reduced = 0;
%         
%         for j = 1 : num_attributes
%             % check termination condition
%             if num_reduced == num_attributes - 1
%                 break;
%             end
% 
%             % remove attribute and check for rule consistency
%             if ron_check_consistency2(net, j, i)
%                 % if consistent, backup structures, and attempt reduction
%                 backup_rule = net.rule;
% 
%                 % calculate baseline objective measure before merging
%                 bom = ron_check_bom(net, stored_input);
%                 
%                 % reduce attribute from this rule
%                 if net.rule(i).antecedent(1, j) == 0
%                     continue;
%                 else
%                     net.rule(i).antecedent(1, j) = 0;
%                 end
%                 
%                 % calculate new objective measure after reduction
%                 nbom = ron_check_bom(net, stored_input);
% 
%                 % check if results deteriorated i.e. new objective measure
%                 % lower than baseline objective measure
%                 deteriorate = 0;
%                 for k = 1 : size(bom, 1)
%                     for l = 1 : size(bom, 2)
%                         if nbom(k, l) < bom(k, l)
%                             deteriorate = 1;
%                             break;
%                         end
%                     end
%                     if deteriorate
%                         break;
%                     end
%                 end
% 
%                 if deteriorate
%                     % if results deteriorated, replace backup structures
%                     net.rule = backup_rule;
%                 else
%                     num_reduced = num_reduced + 1;
%                 end
%                 clear backup_rule bom nbom;
%             end  
%         end
%         disp([num2str(num_reduced), ' attribute(s) removed from Rule ', num2str(i)]);
%     end % end for
    
    D = net;
        
end
