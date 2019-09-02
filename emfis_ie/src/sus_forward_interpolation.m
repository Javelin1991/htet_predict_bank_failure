% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_forward_interpolation XXXXXXXXXXXXXXXXXXX
% 
% Author    :   Susanti
% Date      :   Aug 1 2014
% Function  :   
% Syntax    :   sus_forward_interpolation(intermediate_rule,observation)
% 
% Algorithm -
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function s12 = sus_forward_interpolation(intermediate_rule,observation)
    %disp('sus_forward_interpolation');

    s = 0;
    s_sum = 0;
    m = 0;
    m_sum = 0;

    for i=1:1:intermediate_rule.antecedents.length

        s = sus_scale_rate(intermediate_rule.antecedent(i),observation.antecedent(i));
        % disp (i)
        % disp(['0th dimension: s= ']);
        % disp([s.scale_rate]);

        intermediate_rule.antecedent(i) = sus_scale(intermediate_rule.antecedent(i), s.scale_rate);
        % disp('scaled A  :');
        % disp([intermediate_rule.antecedent(i).point(1)]);
        % disp([intermediate_rule.antecedent(i).point(2)]);
        % disp([intermediate_rule.antecedent(i).point(3)]);

        s_sum = s_sum + s.scale_rate;
        m = sus_move_ratio(intermediate_rule.antecedent(i),observation.antecedent(i));
        % disp (i)
        % disp('1th dimension: m= ');
        % disp([m.move_ratio]);

        transformed_rule.antecedent(i) = sus_move(intermediate_rule.antecedent(i),m.move_ratio);
        m_sum = m_sum + m.move_ratio;

    end

    s = s_sum / intermediate_rule.antecedents.length;
    m = m_sum / intermediate_rule.antecedents.length;

    % disp(' consequence dimension: s= ');
    % disp([s]);

    % disp(' consequence dimension: m= ');
    % disp([m]);

    aa = sus_scale(intermediate_rule.consequent, s);
    transformed_rule.consequent = sus_move(aa, m);

    s12.transformed_rule = transformed_rule.consequent;
end
