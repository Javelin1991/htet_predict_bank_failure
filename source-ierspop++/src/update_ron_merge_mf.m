% XXXXXXXXXXXXXXXXXXXXXXXXXXXXX RON_MERGE_MF XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Jan 29 2010
% Function  :   merges membership functions with small centroid difference
% Syntax    :   ron_merge_mf(net, option, index)
% 
% net - FIS network structure
% option - 'input' or 'output'
% index - attribute or output number (e.g. 1, 2 for first, second etc.)
% 
% Algorithm -
% 1) Performs membership function merging, and renumbers corresponding antecedents in rules
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function [D m] = update_ron_merge_mf(net, option, index)

    disp('Ron MERGE MF');    
    num_rules = size(net.rule, 2);
    threshold_divisor = 2;
    m = 0;
    
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX INPUT XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        
    if strcmp(option, 'input')        
        num_mf = size(net.input(index).mf, 2);    
        if num_mf == 1
            D = net;
            return;
        end
        mf_database = zeros(num_mf, 2);
        % identify mean of centroids of each MF
        for j = 1 : num_mf
            mf_database(j, 1) = net.input(index).mf(j).params(1);
        end
        % identify distances between centroids
        mf_distances = mf_database(2 : num_mf, 1) - mf_database(1 : num_mf - 1, 1);
        % identify minmax distance - distance between min and max centroid
        minmax_distance = mf_database(num_mf, 1) - mf_database(1, 1);
        % identify a threshold for joining - 1/4 of the average distance
        % between centroids
        threshold_distance = (minmax_distance / (num_mf - 1)) / threshold_divisor;
        % identify membership functions to be merged
        for j = 1 : num_mf - 1
            if mf_distances(j) < threshold_distance
                mf_database(j, 2) = 1;
                mf_database(j + 1, 2) = 1;
                m = 1; % merging to occur
            end
        end
        
        if m
            % perform merging
            start_merge = 0; stop_merge = 0;
            merge_mapping = zeros(num_mf, 1);
            new_mf_count = 1;
            for j = 1 : num_mf
                % get start and stop merge indices
                if mf_database(j, 2) == 1 && start_merge == 0 && stop_merge == 0
                    start_merge = j;
                elseif ((j == num_mf && mf_database(num_mf, 2) == 1) || (mf_database(j, 2) == 1 && mf_database(j + 1, 2) == 0)) && start_merge ~= 0 && stop_merge == 0
                    stop_merge = j;
                end

                if start_merge ~= 0 && stop_merge ~= 0
                    if start_merge == 1
                        new_mf_count = 1;
                    else
                        new_mf_count = new_mf_count + 1;
                    end                
                    for k = start_merge : stop_merge                    
                        % get merge mapping to rebuild MF struct and remap
                        % rules
                        merge_mapping(j + start_merge - k) = new_mf_count;                                       
                        if k > start_merge && k ~= stop_merge
                            % sum the num_invoked
                            net.input(index).mf(start_merge).num_invoked = net.input(index).mf(start_merge).num_invoked + net.input(index).mf(k).num_invoked;
                        elseif k == stop_merge
                            % final MF will have left slope and centroid of
                            % start_merge, right slope and centroid of
                            % stop_merge
                            net.input(index).mf(start_merge).num_invoked = net.input(index).mf(start_merge).num_invoked + net.input(index).mf(k).num_invoked;
                            net.input(index).mf(start_merge).params(1) = (net.input(index).mf(start_merge).params(1) + net.input(index).mf(k).params(1))/2;
                            net.input(index).mf(start_merge).params(2) = (net.input(index).mf(start_merge).params(2) + net.input(index).mf(k).params(2))/2;
                            % after merge, reset plasticity and tendency values
                            net.input(index).mf(start_merge).num_expanded = 0;                        
                        end
                    end                
                    start_merge = 0; stop_merge = 0;
                elseif start_merge == 0 && stop_merge == 0 && j == 1
                    merge_mapping(j) = new_mf_count;
                elseif start_merge == 0 && stop_merge == 0 && j > 1
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
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX OUTPUT XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    
    elseif strcmp(option, 'output')
        num_mf = size(net.output(index).mf, 2);    
        if num_mf == 1
            D = net;
            return;
        end
        mf_database = zeros(num_mf, 2);
        % identify mean of centroids of each MF
        for j = 1 : num_mf
            mf_database(j, 1) = net.output(index).mf(j).params(1);
        end
        % identify distances between centroids
        mf_distances = mf_database(2 : num_mf, 1) - mf_database(1 : num_mf - 1, 1);
        % identify minmax distance - distance between min and max centroid
        minmax_distance = mf_database(num_mf, 1) - mf_database(1, 1);
        % identify a threshold for joining - 1/4 of the average distance
        % between centroids
        threshold_distance = (minmax_distance / (num_mf - 1)) / threshold_divisor;
        % identify membership functions to be merged
        for j = 1 : num_mf - 1
            if mf_distances(j) < threshold_distance
                mf_database(j, 2) = 1;
                mf_database(j + 1, 2) = 1;
                m = 1; % merging to occur
            end
        end
        
        if m
            % perform merging
            start_merge = 0; stop_merge = 0;
            merge_mapping = zeros(num_mf, 1);
            new_mf_count = 1;
            for j = 1 : num_mf
                if mf_database(j, 2) == 1 && start_merge == 0 && stop_merge == 0
                    start_merge = j;
                elseif ((j == num_mf && mf_database(num_mf, 2) == 1) || (mf_database(j, 2) == 1 && mf_database(j + 1, 2) == 0)) && start_merge ~= 0 && stop_merge == 0
                    stop_merge = j;
                end

                if start_merge ~= 0 && stop_merge ~= 0
                    if start_merge == 1
                        new_mf_count = 1;
                    else
                        new_mf_count = new_mf_count + 1;
                    end
                    for k = start_merge : stop_merge     
                        % get merge mapping to rebuild MF struct and remap
                        % rules
                        merge_mapping(j + start_merge - k) = new_mf_count;                                        
                        if k > start_merge && k ~= stop_merge
                            % sum the num_invoked
                            net.output(index).mf(start_merge).num_invoked = net.output(index).mf(start_merge).num_invoked + net.output(index).mf(k).num_invoked;
                        elseif k == stop_merge
                            % final MF will have left slope and centroid of
                            % start_merge, right slope and centroid of
                            % stop_merge
                            net.output(index).mf(start_merge).num_invoked = net.output(index).mf(start_merge).num_invoked + net.output(index).mf(k).num_invoked;
                            net.output(index).mf(start_merge).params(1) = (net.output(index).mf(start_merge).params(1) + net.output(index).mf(k).params(1))/2;
                            net.output(index).mf(start_merge).params(2) = (net.output(index).mf(start_merge).params(2) + net.output(index).mf(k).params(2))/2;
                            % after merge, reset plasticity and tendency values
                            net.output(index).mf(start_merge).num_expanded = 0;
                        end
                    end
                    start_merge = 0; stop_merge = 0;
                elseif start_merge == 0 && stop_merge == 0 && j == 1
                    merge_mapping(j) = new_mf_count;
                elseif start_merge == 0 && stop_merge == 0 && j > 1
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
    end
        
end