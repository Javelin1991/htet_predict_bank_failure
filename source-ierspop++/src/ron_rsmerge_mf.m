% XXXXXXXXXXXXXXXXXXXXXXXXXXXX RON_RSMERGE_MF XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Jan 29 2010
% Function  :   merges membership functions based on rough set reduction
% Syntax    :   ron_merge_mf(net, option, index)
% 
% net - FIS network structure
% option - 'input' or 'output'
% index - attribute or output number (e.g. 1, 2 for first, second etc.)
% 
% note - as of Feb 09 2010, algorithm DOES NOT work well for incremental
% learning
%
% Algorithm -
% 1) Calculate baseline objective measure using stored data
% 2) Uses a while loop and checks for rule consistency with MF j + 1 is replaced by MF j
% 3) If rules are consistent, merge MF and recalculate new baseline objective measure
% 4) If objective measure is reduced, cannot merge, else use merged.
% 5) Repeat step 1 with new MFs
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_rsmerge_mf(net, option, index)

disp('Ron RS MERGE MF');    
num_rules = size(net.rule, 2);
    
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX INPUT XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        
    if strcmp(option, 'input')
        iteration = 0;
        this_mf = 1; tryMerge_mf = 2;
        while(true)
            iteration = iteration + 1;
%             disp(num2str(iteration));
            % check termination condition
            num_mf = size(net.input(index).mf, 2);
            % if only one membership function left, no need to merge
            if num_mf == 1
                D = net;
                return;
            end
            
            % if only last membership function left, no need to merge
            if this_mf == num_mf
                D = net;
                return;
            end
            
            % replace tryMerge_mf with this_mf and check for rule
            % consistency                        
            if ron_check_consistency(net, 'input', index, this_mf, tryMerge_mf)
                % if consistent, backup structures, and attempt merge
                backup_struct = net.input(index);
                backup_rule = net.rule;
                
                % calculate baseline objective measure before merging
                bom = ron_check_bom(net);
            
                % merging algorithm :
                % 1) use left_centroid and left_width of this_mf and right_centroid and right_width of tryMerge_mf
                for i = 1 : num_mf - 1
                    if i < this_mf
                        new_mf_struct(i) = net.input(index).mf(i);
                    elseif i == this_mf
                        new_mf_struct(i) = net.input(index).mf(this_mf);
                        new_mf_struct(i).params(3) = net.input(index).mf(tryMerge_mf).params(3);
                        new_mf_struct(i).params(4) = net.input(index).mf(tryMerge_mf).params(4);
                        new_mf_struct(i).num_invoked = new_mf_struct(i).num_invoked + net.input(index).mf(tryMerge_mf).num_invoked;
                        % default values
                        new_mf_struct(i).plasticity = 0.5;
                        new_mf_struct(i).tendency = 0.5;
                        new_mf_struct(i).num_expanded = 0;
                    % 2) rebuild MF structure to reduce MFs                            
                    elseif i > this_mf
                        new_mf_struct(i) = net.input(index).mf(i + 1);
                        new_mf_struct(i).name = ['mf', num2str(i)];
                    end
                end
                % 3) replace antecedents of rulebase to fit new MF structure
                for i = 1 : num_rules
                    if net.rule(i).antecedent(index) >= tryMerge_mf
                        net.rule(i).antecedent(index) = net.rule(i).antecedent(index) - 1;
                    end
                end
                net.input(index).mf = new_mf_struct;
                clear new_mf_struct;
                % finish merge
                
                % calculate new objective measure after merging
                nbom = ron_check_bom(net);
                
                % check if results deteriorated i.e. new objective measure
                % lower than baseline objective measure
                deteriorate = 0;
                for i = 1 : size(bom, 1)
                    for j = 1 : size(bom, 2)
                        if nbom(i, j) < bom(i, j)
                            deteriorate = 1;
                            break;
                        end
                    end
                    if deteriorate
                        break;
                    end
                end
                
                if deteriorate
                    disp('Results deteriorated, cannot merge');
                    % if results deteriorated, replace backup structures
                    net.input(index) = backup_struct;
                    net.rule = backup_rule;
                    % attempt merge next MFs
                    this_mf = this_mf + 1;
                    tryMerge_mf = tryMerge_mf + 1;
                else
                    disp('Results improved, use merged');
                end
                clear backup_struct backup_rule bom nbom;
            else
                disp('Inconsistent');
                this_mf = this_mf + 1;
                tryMerge_mf = tryMerge_mf + 1;
            end            
        end % end while
        
        D = net;
        
    elseif strcmp(option, 'output')
        
        iteration = 0;
        this_mf = 1; tryMerge_mf = 2;
        while(true)
            iteration = iteration + 1;
%             disp(num2str(iteration));
            % check termination condition
            num_mf = size(net.output(index).mf, 2);
            % if only one membership function left, no need to merge
            if num_mf == 1
                D = net;
                return;
            end
            
            % if only last membership function left, no need to merge
            if this_mf == num_mf
                D = net;
                return;
            end
            
            % replace tryMerge_mf with this_mf and check for rule
            % consistency                        
            if ron_check_consistency(net, 'output', index, this_mf, tryMerge_mf)
                % if consistent, backup structures, and attempt merge
                backup_struct = net.output(index);
                backup_rule = net.rule;
                
                % calculate baseline objective measure before merging
                bom = ron_check_bom(net);
            
                % merging algorithm :
                % 1) use left_centroid and left_width of this_mf and right_centroid and right_width of tryMerge_mf
                for i = 1 : num_mf - 1
                    if i < this_mf
                        new_mf_struct(i) = net.output(index).mf(i);
                    elseif i == this_mf
                        new_mf_struct(i) = net.output(index).mf(this_mf);
                        new_mf_struct(i).params(3) = net.output(index).mf(tryMerge_mf).params(3);
                        new_mf_struct(i).params(4) = net.output(index).mf(tryMerge_mf).params(4);
                        new_mf_struct(i).num_invoked = new_mf_struct(i).num_invoked + net.output(index).mf(tryMerge_mf).num_invoked;
                        % default values
                        new_mf_struct(i).plasticity = 0.5;
                        new_mf_struct(i).tendency = 0.5;
                        new_mf_struct(i).num_expanded = 0;
                    % 2) rebuild MF structure to reduce MFs                            
                    elseif i > this_mf
                        new_mf_struct(i) = net.output(index).mf(i + 1);
                        new_mf_struct(i).name = ['mf', num2str(i)];
                    end
                end
                % 3) replace consequents of rulebase to fit new MF structure
                for i = 1 : num_rules
                    if net.rule(i).consequent(index) >= tryMerge_mf
                        net.rule(i).consequent(index) = net.rule(i).consequent(index) - 1;
                    end
                end
                net.output(index).mf = new_mf_struct;
                clear new_mf_struct;
                % finish merge
                
                % calculate new objective measure after merging
                nbom = ron_check_bom(net);
                
                % check if results deteriorated i.e. new objective measure
                % lower than baseline objective measure
                deteriorate = 0;
                for i = 1 : size(bom, 1)
                    for j = 1 : size(bom, 2)
                        if nbom(i, j) < bom(i, j)
                            deteriorate = 1;
                            break;
                        end
                    end
                    if deteriorate
                        break;
                    end
                end
                
                if deteriorate
                    disp('Results deteriorated, cannot merge');
                    % if results deteriorated, replace backup structures
                    net.output(index) = backup_struct;
                    net.rule = backup_rule;
                    % attempt merge next MFs
                    this_mf = this_mf + 1;
                    tryMerge_mf = tryMerge_mf + 1;
                else
                    disp('Results improved, use merged');
                end
                clear backup_struct backup_rule bom nbom;
            else
                disp('Inconsistent');
                this_mf = this_mf + 1;
                tryMerge_mf = tryMerge_mf + 1;
            end            
        end % end while
        
        D = net;
        
    end
end