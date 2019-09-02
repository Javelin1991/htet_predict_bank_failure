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

function D = ron_calcErrors(system, data_target, varargin)

    if ~isempty(varargin)
        g = varargin{1};
    end
    

    
    end_test = size(system.predicted, 1);
    start_test = end_test - size(data_target, 1) + 1;
  
    % get loss functions
    if ~isempty(varargin)
        if g == 2
            a = exp(system.predicted(start_test : end_test));
            b = exp(data_target);
        else
            a = system.predicted(start_test : end_test);
            b = data_target;
        end
    else
        a = system.predicted(start_test : end_test);
        b = data_target;
    end
    
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
    
    if isfield(system, 'net_struct')
        num_networks = size(system.net_struct, 2);
        system.num_rules = 0;
        for i = 1 : num_networks
          system.num_rules = system.num_rules + (size(system.net_struct(i).net.rule, 2) * system.net_struct(i).net.weight);
        end
    elseif isfield(system, 'rule')
        system.num_rules = size(system.rule, 2);
    elseif isfield(system, 'rn')
        system.num_rules = system.rn;        
    end
        
    D = system;

end