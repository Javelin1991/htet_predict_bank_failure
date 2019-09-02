% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX RON_SNAFILTER XXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Jan 13 2010
% Function  :   (S)elects a(N)d (A)pplies filter which maximizes noise
%               reduction (kurtosis(before) - kurtosis(after)) and 
%               maximizes pearson's correlation coefficient controlled with
%               a variable parameter 'threshold'.
% Syntax    :   ron_SNAfilter(inputs, filters)
%
% Applies 11 thresholds (0 : 0.1 : 1) on results analysis and selects and
% returns the results of all unique best filters used, as well as the index
% of the no bias filter (threshold 0.5).
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function [D, no_bias_filter] = ron_SNAfilter(inputs, filters)

    outputs(size(filters, 2)).output = zeros(size(inputs, 1), size(inputs, 2));
    noise_reduction = zeros(size(filters, 2), size(inputs, 2));
    correlation = zeros(size(filters, 2), size(inputs, 2));
%     threshold = zeros(11, 2);
    
    % apply all filters
    for i = 1 : size(filters, 2)
        filter = filters(i);
        if ~isempty(filter.param) && size(filter.param, 2) > 1
            n = filter.param(1);
            R = filter.param(2);
            Wp = filter.param(3);
            for j = 1 : size(inputs, 2)
                outputs(i).output(:, j) = ron_filter(inputs(:, j), filter.type, [n R Wp]);
            end
        elseif ~isempty(filter.param) && size(filter.param, 2) == 1
            lag = filter.param(1);
            for j = 1 : size(inputs, 2)
                outputs(i).output(:, j) = ron_filter(inputs(:, j), filter.type, lag);
            end
        elseif isempty(filter.param)
            for j = 1 : size(inputs, 2)
                outputs(i).output(:, j) = ron_filter(inputs(:, j), filter.type);
            end
        end

        for j = 1 : size(inputs, 2)
            noise_reduction(i, j) = kurtosis(inputs(:, j)) - kurtosis(outputs(i).output(:, j));
            c = corrcoef(outputs(i).output(:, j), inputs(:, j));
            correlation(i, j) = c(1, 2);
            clear c;        
        end    
    end
    
    norm_noise_reduction = mapminmax(noise_reduction', 0, 1);       
    norm_correlation = mapminmax(correlation', 0, 1);
    % If threshold = 0.5, both results are treated equally
    % If threshold > 0.5, more weightage given to noise reduction. Winning
    % filter will have more noise reduction, sacrificing correlation.
    % If threshold < 0.5, more weightage given to correlation. Winning
    % filter will have more correlation, sacrificing noise reduction.    
    for i = 1 : 11
        t = (i - 1) * 0.1;
        final = (t * sum(norm_noise_reduction)) + ((1 - t) * sum(norm_correlation));    
        [threshold(i, 1), threshold(i, 2)] = max(final);
    end
    
%     t = 0.5;
%     final = (t * sum(norm_noise_reduction)) + ((1 - t) * sum(norm_correlation));
%     [winning_value, winning_filter] = max(final);
    
    unique_filters = unique(threshold(:, 2));

%     filter_string = ron_getFilterString(filters, winning_filter);
%     disp(['Filter chosen : ', filter_string]);
% %   1st output is values filtered by winning filter
%     D(1).filtered = outputs(winning_filter).output;
%     D(1).filter_string = ron_getFilterString(filters, winning_filter);
% %   2nd output is unfiltered
%     D(2).filtered = inputs;
%     D(2).filter_string = 'No filter';
    for i = 1 : size(unique_filters, 1)
        filter_number = unique_filters(i);
        if filter_number == threshold(6, 2)
            no_bias_filter = i;
        end
        filter_string = ron_getFilterString(filters, filter_number);
        disp(filter_string);
        D(i).filtered = outputs(filter_number).output;
        D(i).filter_number = filter_number;
        D(i).filter_string = filter_string;        
    end
end

function filter_string = ron_getFilterString(filters, filter_number)
	str1 = num2str(filter_number);
    str2 = ', ';
    switch filters(filter_number).type
        case 's'
            str3 = 'Simple w/ Lag ';
        case 'w'
            str3 = 'Weighted w/ Lag ';
        case 'e'
            str3 = 'Exponential w/ Lag ';
        case 'r'
            str3 = 'Rectangular w/ Lag ';
        case 't'
            str3 = 'Triangular w/ Lag ';
        case 'g'
            str3 = 'Pseudo-Gaussian w/ Lag ';
        case 'c1'
            str3 = 'Chebyshev I w/ Params ';
        case 'c2'
            str3 = 'Chebyshev II w/ Params ';
    end
    str4 = '[';
    for j = 1 : size(filters(filter_number).param, 2)
        if j == 1
            str5 = num2str(filters(filter_number).param(j));
        else
            str5 = strcat(str5, ', ', num2str(filters(filter_number).param(j)));
        end
    end
    str6 = ']';

    filter_string = [str1, str2, str3, str4, str5, str6];
end