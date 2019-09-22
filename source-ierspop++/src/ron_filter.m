% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX RON_FILTER XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Ron TD
% Date      :   Jan 13 2010
% Function  :   performs filtering based on type and parameters
% Syntax    :   ron_filter(input, type, varargin)
% 
% Performs a filter based on chosen type (algorithm). Supported types are :
% 's' - simple MA, param - lag (default 5)
% 'e' - exponential MA, param - lag (default 5)
% 'w' - weighted MA, param - lag (default 5)
% 'c1' - cheby1 filter (passband ripple), param - n, R, Wp (default [5 2 0.6])
% 'c2' - cheby2 filter (stopband ripple), param - n, R, Wp (default [5 10 0.6])
% 'r' - rectangular smooth, param - lag (default 5)
% 't' - triangular smooth, param - lag (default 5)
% 'g' - pseudo-gaussian smooth, param - lag(default 5)
% 
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = ron_filter(input, type, varargin)

disp('Ron fILTER');        
DEFAULT_LAG = 5;
    DEFAULT_N = 5;
    DEFAULT_R_C1 = 2;
    DEFAULT_R_C2 = 10;
    DEFAULT_WP = 0.6;
    
    total = size(input, 1);
    output = zeros(total, 1);
    numer = 0;
    denom = 0;
    
    % XXXXXXXXXXXXXXXXXXXXX initialize parameters or use defaults XXXXXXXXXXXXXXXXXXXXX
    if strcmp(type, 's') || strcmp(type, 'w') || strcmp(type, 'e') || strcmp(type, 'r') || strcmp(type, 't') || strcmp(type, 'g')
        if isempty(varargin)
            lag = DEFAULT_LAG;
        else
            lag = varargin{1};
        end
    elseif strcmp(type, 'c1') || strcmp(type, 'c2')
        if isempty(varargin)
            n = DEFAULT_N;
            if strcmp(type, 'c1')
                R = DEFAULT_R_C1;
            elseif strcmp(type, 'c2')
                R = DEFAULT_R_C2;
            end
            Wp = DEFAULT_WP;
        else
            param = varargin{1};
            n = param(1);
            R = param(2);
            Wp = param(3);
        end
    end
    
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX SIMPLE MA FILTER XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    if strcmp(type, 's')
        for i = 1 : total
            if i < lag
                output(i, 1) = mean(input(1 : i, 1));
            else
                output(i, 1) = mean(input(i - lag + 1 : i, 1));
            end
        end
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX WEIGHTED MA FILTER XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    
    elseif strcmp(type, 'w')
        for i = 1 : total
            if i < lag
                for j = 1 : i
                    numer = numer + j * input(j, 1);
                    denom = denom + j;
                end
                output(i, 1) = numer / denom;
            else
                for j = 1 : lag
                    numer = numer + j * input(i - lag + j, 1);
                    denom = denom + j;
                end
                output(i, 1) = numer / denom;
            end
            numer = 0;
            denom = 0;
        end
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX EXPONENTIAL MA FILTER XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    elseif strcmp(type, 'e')
        for i = 1 : total
            if i == 1
                output(i, 1) = input(i, 1);
            else
                output(i, 1) = (((lag - 1) * output(i - 1, 1)) + input(i, 1) ) / lag;
            end
        end
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX RECTANGULAR SMOOTH XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    elseif strcmp(type, 'r')
        output = fastsmooth(input, lag, 1, 1);
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX TRIANGULAR SMOOTH XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    elseif strcmp(type, 't')
        output = fastsmooth(input, lag, 2, 1);
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX PSEUDO-GAUSSIAN SMOOTH XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    elseif strcmp(type, 'g')
        output = fastsmooth(input, lag, 3, 1);
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX CHEBYSHEV I FILTER XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    elseif strcmp(type, 'c1')
        [b, a] = cheby1(n, R, Wp);
        output = filtfilt(b, a, input);
    % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX CHEBYSHEV II FILTER XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    elseif strcmp(type, 'c2')
        [b, a] = cheby2(n, R, Wp);
        output = filtfilt(b, a, input);
    end
    
%     corrcoef(output, input)
%     plot(output);
%     hold('on');
%     plot(input, 'r');

    D = output;

end