% XXXXXXXXXXXXXXXXXXXXXXXXXXXX RON_CALCERRORS XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Ron TD
% Date      :   Feb 09 2010
% Function  :   calculates prediction errors
% Syntax    :   ron_calcErrors(system, data_target, start_test)
%
% system - FIS system struct
% data_target - target data, can have multiple columns (outputs) but one row
% start_test - tuple to start calcuating errors (from start_test to total)
%
% Algorithm -
% 1) Runs all loss functions formulae
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

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
