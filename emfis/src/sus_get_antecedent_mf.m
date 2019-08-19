% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_get_antecedent_mf XXXXXXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   num_attributes, f (firing strength) and attribute
%               membership value
% Syntax    :   sus_get_antecedent_mf(data_input, net)
% 
% data_input    - input data, has one and multiple columns
% 
% Algorithm -
% 1) Finds winning fuzzy set of each input
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s16 = sus_get_antecedent_mf(data_input, net)
%disp('sus_get_antecedent_mf');

    num_attributes = size(data_input, 2);
    
    % find fuzzy set the input data belongs to
    max_mf = zeros(1, num_attributes);
    max_set = zeros(1, num_attributes);
    for i = 1 : num_attributes
        num_mf = size(net.input(i).mf, 2);
        mf_values = zeros(1, num_mf);
        for j = 1 : num_mf
            if net.input(i).mf(j).params(1) ~= 0 && net.input(i).mf(j).params(3) ~= 0
                mf_values(j) = gauss2mf(data_input(i), net.input(i).mf(j).params);
            end
        end
        % get winning membership values and winning fuzzy sets
        [max_mf(i), max_set(i)] = max(mf_values); 
        net.input(i).mf(max_set(i)).num_invoked = net.input(i).mf(max_set(i)).num_invoked + 1;
    end
    % antecedent is array with winning fuzzy set of each input
    antecedent = max_set;
    f = min(max_set);

    s16.antecedent = antecedent;
    s16.f = f;
    s16.num_attributes = num_attributes;
end
