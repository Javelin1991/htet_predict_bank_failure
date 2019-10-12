% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_tabulate_longitudinal_result XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to tabulate results for Longitudinal systems
% Syntax    :   htet_tabulate_longitudinal_result(SYSTEMS)
% SYSTEMS - already processed Longitudinal Systems
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function result = htet_tabulate_longitudinal_result(SYSTEMS)
  result = [];

  for sys = 1:2
    TABLE = [];
    for j = 1:3
      for i = 1:3
        switch j
          case 1
            feat = 'forward_CAPADE';
            name = SYSTEMS{sys, 1}.pretrained_forward_CAPADE{i, 1}.name;
            r = SYSTEMS{sys, 1}.pretrained_forward_CAPADE{i, 1}.R;
            mae = SYSTEMS{sys, 1}.pretrained_forward_CAPADE{i, 1}.MAE;
            rmse = SYSTEMS{sys, 1}.pretrained_forward_CAPADE{i, 1}.RMSE;

            feat_2 = 'backward_CAPADE';
            name_2 = SYSTEMS{sys, 1}.pretrained_backward_CAPADE{i, 1}.name;
            r_2 = SYSTEMS{sys, 1}.pretrained_backward_CAPADE{i, 1}.R;
            mae_2 = SYSTEMS{sys, 1}.pretrained_backward_CAPADE{i, 1}.MAE;
            rmse_2 = SYSTEMS{sys, 1}.pretrained_backward_CAPADE{i, 1}.RMSE;

        case 2
            feat = 'forward_PLAQLY';
            name = SYSTEMS{sys, 1}.pretrained_forward_PLAQLY{i, 1}.name;
            r = SYSTEMS{sys, 1}.pretrained_forward_PLAQLY{i, 1}.R;
            mae = SYSTEMS{sys, 1}.pretrained_forward_PLAQLY{i, 1}.MAE;
            rmse = SYSTEMS{sys, 1}.pretrained_forward_PLAQLY{i, 1}.RMSE;

            feat_2 = 'backward_PLAQLY';
            name_2 = SYSTEMS{sys, 1}.pretrained_backward_PLAQLY{i, 1}.name;
            r_2 = SYSTEMS{sys, 1}.pretrained_backward_PLAQLY{i, 1}.R;
            mae_2 = SYSTEMS{sys, 1}.pretrained_backward_PLAQLY{i, 1}.MAE;
            rmse_2 = SYSTEMS{sys, 1}.pretrained_backward_PLAQLY{i, 1}.RMSE;
        case 3
            feat = 'forward_ROE';
            name = SYSTEMS{sys, 1}.pretrained_forward_ROE{i, 1}.name;
            r = SYSTEMS{sys, 1}.pretrained_forward_ROE{i, 1}.R;
            mae = SYSTEMS{sys, 1}.pretrained_forward_ROE{i, 1}.MAE;
            rmse = SYSTEMS{sys, 1}.pretrained_forward_ROE{i, 1}.RMSE;

            feat_2 = 'backward_ROE';
            name_2 = SYSTEMS{sys, 1}.pretrained_backward_ROE{i, 1}.name;
            r_2 = SYSTEMS{sys, 1}.pretrained_backward_ROE{i, 1}.R;
            mae_2 = SYSTEMS{sys, 1}.pretrained_backward_ROE{i, 1}.MAE;
            rmse_2 = SYSTEMS{sys, 1}.pretrained_backward_ROE{i, 1}.RMSE;
        end

        switch (i)
          case 6
            eMFIS_FRIE = [r;mae;rmse;{feat}];
            eMFIS_FRIE_Back = [r_2;mae_2;rmse_2;{feat_2}];

          case 1
            DENFIS = [r;mae;rmse;{feat}];
            DENFIS_Back = [r_2;mae_2;rmse_2;{feat_2}];

          case 2
            ANFIS = [r;mae;rmse;{feat}];
            ANFIS_Back = [r_2;mae_2;rmse_2;{feat_2}];

          case 3
            ANFIS_DENFIS_SA = [r;mae;rmse;{feat}];
            ANFIS_DENFIS_SA_Back = [r_2;mae_2;rmse_2;{feat_2}];

          case 5
            BEST_SELECT = [r;mae;rmse;{feat}];
            BEST_SELECT_Back = [r_2;mae_2;rmse_2;{feat_2}];
        end
      end
      T = table(DENFIS,ANFIS,ANFIS_DENFIS_SA, 'RowNames', {'r', 'MAE', 'RMSE', 'Target'})
      TABLE = [TABLE; {T}];

      T_2 = table(DENFIS_Back,ANFIS_Back,ANFIS_DENFIS_SA_Back, 'RowNames', {'r', 'MAE', 'RMSE', 'Target'})
      TABLE = [TABLE; {T_2}];
    end
    result = [result; {TABLE}];
  end
end
