

function htet_export_results_to_excel_files(SYSTEMS, isLateral)
  if isLateral
    T1 = htet_tabulate_lateral_result(SYSTEMS);
    export_cv_lat(T1);
  else
    T2 = htet_tabulate_longitudinal_result(SYSTEMS);
    export_cv_long(T2);
  end
end

function export_cv_lat(T1)
  filename = 'lateral_prediction_result_1.xlsx';
  for j=1:2
    for i=1:3
        T = T1{j, 1}{i, 1};
        switch i
            case 1
                writetable(T,filename,'Sheet',j,'Range','A1','WriteRowNames',true)

            case 2
                writetable(T,filename,'Sheet',j,'Range','A7','WriteRowNames',true)

            case 3
                writetable(T,filename,'Sheet',j,'Range','A13','WriteRowNames',true)
        end
    end
  end
end

function export_cv_long(T2)

  filename_2 = 'longitudinal_prediction_result_1.xlsx';

  for j=1:2
    for i=1:6
        T = T2{j, 1}{i, 1};
        switch i
            case 1
                writetable(T,filename_2,'Sheet',j,'Range','A1','WriteRowNames',true)

            case 2
                writetable(T,filename_2,'Sheet',j,'Range','A19','WriteRowNames',true)

            case 3
                writetable(T,filename_2,'Sheet',j,'Range','A7','WriteRowNames',true)

            case 4
                writetable(T,filename_2,'Sheet',j,'Range','A25','WriteRowNames',true)

            case 5
                writetable(T,filename_2,'Sheet',j,'Range','A13','WriteRowNames',true)

            case 6
                writetable(T,filename_2,'Sheet',j,'Range','A31','WriteRowNames',true)
        end
    end
  end
end
