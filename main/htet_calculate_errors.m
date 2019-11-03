% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_calculate_errors XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Ron TD, Htet
% Date      :   Feb 09 2010, Sep 11, 2019
% Function  :   calculates prediction errors
% Syntax    :   htet_calculate_errors(predicted, data_target)
%
% predicted - predicted value
% data_target - actual value (ground truth value)
%
% Stars     :   ***
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function D = htet_calculate_errors(predicted, data_target)

    a = data_target;
    b = predicted;

    system.MAE = ron_mae(a, b);
    system.MSE = ron_mse(a, b);
    system.RMSE = sqrt(system.MSE);
    system.HMAE = ron_hmae(a, b);
    system.HMSE = ron_hmse(a, b);
    system.AMAPE = ron_amape(a, b);
    system.theilU = ron_theilu(a, b);
    system.MMEU = ron_mmeu(a, b);
    system.MMEO = ron_mmeo(a, b);
    system.R = ron_r(a, b);
    system.R2 = ron_r2(a, b);
    system.MLF = (system.MAE + system.MSE + system.HMAE + system.HMSE + system.AMAPE + system.theilU + system.MMEU + system.MMEO) / 8;
    D = system;
end
