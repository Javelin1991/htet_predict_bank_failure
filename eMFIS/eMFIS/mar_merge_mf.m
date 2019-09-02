% XXXXXXXXXXXXXXXXXXXXXXXXXXXXX MAR_MERGE_MF XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Mario Hartanto
% Date      :   Jan 27 2014
% Function  :   merges membership functions with small centroid difference
% Syntax    :   mar_merge_mf(net, option, index)
% 
% net - FIS network structure
% option - 'input' or 'output'
% index - attribute or output number (e.g. 1, 2 for first, second etc.)
% 
% Algorithm -
% 1) Performs membership function merging, and renumbers corresponding antecedents in rules
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function [D, m] = mar_merge_mf(net, option, index)

    %disp('MAR MERGE MF');    
    beta = 0.5;
    TD = 0.5;
    num_rules = size(net.rule, 2);
    merging_to_occur = 0;
    
    denom = net.max_cluster;
    
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX INPUT XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        
    if strcmp(option, 'input')        
        num_mf = size(net.input(index).mf, 2);    
        if num_mf == 1
            D = net;
            m = false;
            return;
        end
        mf_database = zeros(num_mf, 4);
        % identify mean of centroids of each MF
        for j = 1 : num_mf
            mf_database(j, 1) = net.input(index).mf(j).params(2);
            mf_database(j, 2) = net.input(index).mf(j).params(4);
            mf_database(j, 3) = (mf_database(j, 1) + mf_database(j, 2)) / 2;
        end
        % identify distances between centroids
        mf_distances = mf_database(2 : num_mf, 3) - mf_database(1 : num_mf - 1, 3);
        
        % Calculate Reducibility criteria
        reducibility_threshold = net.input(index).spatio_temporal_dist / denom;

        % identify membership functions to be merged
        for j = 1 : num_mf - 1
            if mf_distances(j) < reducibility_threshold
                mf_database(j, 4) = 1;
                mf_database(j + 1, 4) = 1;
                merging_to_occur = 1;
            end
        end
        
        if merging_to_occur
            % perform merging
            start_merge = 0; stop_merge = 0;
            merge_mapping = zeros(num_mf, 1);
            new_mf_count = 0;
            for j = 1 : num_mf
                % get start and stop merge indices
                if mf_database(j, 4) == 1 && start_merge == 0 && stop_merge == 0
                    start_merge = j;
                elseif ((j == num_mf && mf_database(num_mf, 4) == 1) || (mf_database(j, 4) == 1 && mf_database(j + 1, 4) == 0)) && start_merge ~= 0 && stop_merge == 0
                    stop_merge = j;
                end

                if start_merge ~= 0 && stop_merge ~= 0
                    new_mf_count = new_mf_count + 1;
                    left_centroid = zeros(1, (stop_merge - start_merge) + 1);
                    right_centroid = zeros(1, (stop_merge - start_merge) + 1);
                    stability = zeros(1, (stop_merge - start_merge) + 1);
                    
                    for k = start_merge : stop_merge                    
                        % get merge mapping to rebuild MF struct and remap
                        % rules
                        merge_mapping(j + start_merge - k) = new_mf_count;
                        left_centroid(k - start_merge + 1) = net.input(index).mf(k).params(2);
                        right_centroid(k - start_merge + 1) = net.input(index).mf(k).params(4);
                        stability(k - start_merge + 1) = net.input(index).mf(k).stability;
                        
                        if k > start_merge && k ~= stop_merge
                            % sum the num_invoked
                            net.input(index).mf(start_merge).num_invoked = net.input(index).mf(start_merge).num_invoked + net.input(index).mf(k).num_invoked;
                        elseif k == stop_merge
                            % final MF will have left slope and centroid of
                            % start_merge, right slope and centroid of
                            % stop_merge
                            net.input(index).mf(start_merge).num_invoked = net.input(index).mf(start_merge).num_invoked + net.input(index).mf(k).num_invoked;
                            net.input(index).mf(start_merge).params(4) = net.input(index).mf(k).params(4);
                            net.input(index).mf(start_merge).params(3) = net.input(index).mf(k).params(3);
                            
                            % after merge, reset plasticity and tendency values
                            net.input(index).mf(start_merge).plasticity = beta;
                            net.input(index).mf(start_merge).tendency = TD;
                            net.input(index).mf(start_merge).num_expanded = 0;
                            
                            % ADJUST New Centroid and STABILITIES
                            if sum(stability) == 0
                                net.input(index).mf(start_merge).params(2) = mean(left_centroid);
                                net.input(index).mf(start_merge).params(4) = mean(right_centroid);
                                net.input(index).mf(start_merge).stability = 0;
                            else
                                left_centroid_stability = left_centroid .* stability;
                                right_centroid_stability = right_centroid .* stability;
                                net.input(index).mf(start_merge).params(2) = sum(left_centroid_stability(1,:)) / sum(stability(1,:));
                                net.input(index).mf(start_merge).params(4) = sum(right_centroid_stability(1,:)) / sum(stability(1,:));
                                net.input(index).mf(start_merge).stability = mean(stability);
                            end
                        end
                    end                
                    start_merge = 0; stop_merge = 0;
                elseif start_merge == 0 && stop_merge == 0 
                    new_mf_count = new_mf_count + 1;
                    merge_mapping(j) = new_mf_count;
                end
            end

            for j = 1 : num_mf
                if j == 1
                    new_mf_struct(1) = net.input(index).mf(j);
                elseif merge_mapping(j) == merge_mapping(j - 1)
                    % remap rules
                    for k = 1 : num_rules
                        if net.rule(k).antecedent(index) == j
                            net.rule(k).antecedent(index) = merge_mapping(j);
                        end
                    end
                elseif merge_mapping(j) ~= merge_mapping(j - 1)
                    % rebuild MF structure and rename MFs
                    new_mf_struct(merge_mapping(j)) = net.input(index).mf(j);
                    new_mf_struct(merge_mapping(j)).name = ['mf', num2str(merge_mapping(j))];
                    for k = 1 : num_rules
                        if net.rule(k).antecedent(index) == j
                            net.rule(k).antecedent(index) = merge_mapping(j);
                        end
                    end
                end
            end
            net.input(index).mf = new_mf_struct;
        end
        
        D = net;
        m = merging_to_occur;
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX OUTPUT XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    
    elseif strcmp(option, 'output')
        num_mf = size(net.output(index).mf, 2);    
        if num_mf == 1
            D = net;
            m = false;
            return;
        end
        mf_database = zeros(num_mf, 4);
        % identify mean of centroids of each MF
        for j = 1 : num_mf
            mf_database(j, 1) = net.output(index).mf(j).params(2);
            mf_database(j, 2) = net.output(index).mf(j).params(4);
            mf_database(j, 3) = (mf_database(j, 1) + mf_database(j, 2)) / 2;
        end
        % identify distances between centroids
        mf_distances = mf_database(2 : num_mf, 3) - mf_database(1 : num_mf - 1, 3);
        
        % Calculate Reducibility criteria
        reducibility_threshold = net.output(index).spatio_temporal_dist / denom;

        % identify membership functions to be merged
        for j = 1 : num_mf - 1
            if mf_distances(j) < reducibility_threshold
                mf_database(j, 4) = 1;
                mf_database(j + 1, 4) = 1;
                merging_to_occur = 1;
            end
        end
        
        if merging_to_occur
            % perform merging
            start_merge = 0; stop_merge = 0;
            merge_mapping = zeros(num_mf, 1);
%             new_mf_count = 1;
            new_mf_count = 0;
            
            for j = 1 : num_mf
                if mf_database(j, 4) == 1 && start_merge == 0 && stop_merge == 0
                    start_merge = j;
                elseif ((j == num_mf && mf_database(num_mf, 4) == 1) || (mf_database(j, 4) == 1 && mf_database(j + 1, 4) == 0)) && start_merge ~= 0 && stop_merge == 0
                    stop_merge = j;
                end

                if start_merge ~= 0 && stop_merge ~= 0
                    new_mf_count = new_mf_count + 1;
                    left_centroid = zeros(1, (stop_merge - start_merge) + 1);
                    right_centroid = zeros(1, (stop_merge - start_merge) + 1);
                    stability = zeros(1, (stop_merge - start_merge) + 1);
                    
                    for k = start_merge : stop_merge     
                        % get merge mapping to rebuild MF struct and remap
                        % rules
                        merge_mapping(j + start_merge - k) = new_mf_count;
                        left_centroid(k - start_merge + 1) = net.output(index).mf(k).params(2);
                        right_centroid(k - start_merge + 1) = net.output(index).mf(k).params(4);
                        stability(k - start_merge + 1) = net.output(index).mf(k).stability;
                        if k > start_merge && k ~= stop_merge
                            % sum the num_invoked
                            net.output(index).mf(start_merge).num_invoked = net.output(index).mf(start_merge).num_invoked + net.output(index).mf(k).num_invoked;
                        elseif k == stop_merge
                            % final MF will have left slope and centroid of
                            % start_merge, right slope and centroid of
                            % stop_merge
                            net.output(index).mf(start_merge).num_invoked = net.output(index).mf(start_merge).num_invoked + net.output(index).mf(k).num_invoked;
                            net.output(index).mf(start_merge).params(4) = net.output(index).mf(k).params(4);
                            net.output(index).mf(start_merge).params(3) = net.output(index).mf(k).params(3);
                            % after merge, reset plasticity and tendency values
                            net.output(index).mf(start_merge).plasticity = beta;
                            net.output(index).mf(start_merge).tendency = TD;
                            net.output(index).mf(start_merge).num_expanded = 0;
                            
                            % ADJUST New Centroid and STABILITIES
                            if sum(stability) == 0
                                net.output(index).mf(start_merge).params(2) = mean(left_centroid);
                                net.output(index).mf(start_merge).params(4) = mean(right_centroid);
                                net.output(index).mf(start_merge).stability = 0;
                            else
                                left_centroid_stability = left_centroid .* stability;
                                right_centroid_stability = right_centroid .* stability;
                                net.output(index).mf(start_merge).params(2) = sum(left_centroid_stability(1,:)) / sum(stability(1,:));
                                net.output(index).mf(start_merge).params(4) = sum(right_centroid_stability(1,:)) / sum(stability(1,:));
                                net.output(index).mf(start_merge).stability = mean(stability);
                            end
                        end
                    end
                    start_merge = 0; stop_merge = 0;
                elseif start_merge == 0 && stop_merge == 0
                    new_mf_count = new_mf_count + 1;
                    merge_mapping(j) = new_mf_count;
                end
            end

            for j = 1 : num_mf
                if j == 1
                    new_mf_struct(1) = net.output(index).mf(j);
                elseif merge_mapping(j) == merge_mapping(j - 1)
                    for k = 1 : num_rules
                        % remap rules
                        if net.rule(k).consequent(index) == j
                            net.rule(k).consequent(index) = merge_mapping(j);
                        end
                    end
                elseif merge_mapping(j) ~= merge_mapping(j - 1)
                    % rebuild MF structure and rename MFs
                    new_mf_struct(merge_mapping(j)) = net.output(index).mf(j);
                    new_mf_struct(merge_mapping(j)).name = ['mf', num2str(merge_mapping(j))];
                    for k = 1 : num_rules
                        if net.rule(k).consequent(index) == j
                            net.rule(k).consequent(index) = merge_mapping(j);
                        end
                    end
                end
            end
            net.output(index).mf = new_mf_struct;
        end
        
        D = net;
        m = merging_to_occur;
    end
        
end