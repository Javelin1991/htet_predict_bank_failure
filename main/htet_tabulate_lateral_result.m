% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_tabulate_lateral_result XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to tabulate results for lateral systems
% Syntax    :   htet_tabulate_lateral_result(SYSTEMS)
% SYSTEMS - already processed Lateral Systems
% Stars     :   **
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function result = htet_tabulate_lateral_result(SYSTEMS)
  result = [];

  for sys = 1:2
    TABLE = [];
    for j = 1:3
      for i = 1:6
          feat = SYSTEMS{sys, 1}{j, i}.target_feature_name;
          name = SYSTEMS{sys, 1}{j, i}.name;
          r = SYSTEMS{sys, 1}{j, i}.R;
          mae = SYSTEMS{sys, 1}{j, i}.MAE;
          rmse = SYSTEMS{sys, 1}{j, i}.RMSE;

          % skip to safin++
          i = 6;
        switch (i)
          case 1
            eMFIS_FRIE = [r;mae;rmse;{feat}];

          case 2
            DENFIS = [r;mae;rmse;{feat}];

          case 3
            ANFIS = [r;mae;rmse;{feat}];

          case 4
            ANFIS_DENFIS_SA = [r;mae;rmse;{feat}];

          case 5
            BEST_SELECT = [r;mae;rmse;{feat}];

          case 6
            BEST_SELECT = [r;mae;rmse;{feat}];
        end
      end
      T = table(eMFIS_FRIE,DENFIS,ANFIS,ANFIS_DENFIS_SA,BEST_SELECT, 'RowNames', {'r', 'MAE', 'RMSE', 'Target'})
      TABLE = [TABLE; {T}];
    end
    result = [result; {TABLE}];
  end
end
