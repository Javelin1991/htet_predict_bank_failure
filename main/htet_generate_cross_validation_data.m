% XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_scale XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :
% Function  :
% Syntax    :
%
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_generate_cross_validation_data(input, offset)
    I = test(SB,i);
    cv_sb = [];
    for j = 1:length(I)
        if I(j,:) == 1
            cv_sb = [cv_sb; Survived_Banks_Group_By_Bank_ID(j, :)];
        end
    end

    I2 = test(FB, i);
    cv_fb = [];
    for k = 1:length(I2)
        if I2(k,:) == 1
            cv_fb = [cv_fb; Failed_Banks_Group_By_Bank_ID(k, :)];
        end
    end

    cv_sb_plus_cv_fb = vertcat(cv_sb,cv_fb);
    final_cv = htet_pre_process_bank_data(cv_sb_plus_cv_fb, 1, 0);
    CV = [CV; {final_cv}];
end
