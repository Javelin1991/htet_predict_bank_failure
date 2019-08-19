% finds pearson's correlation coefficient between a and b
% a should be desired, b should be predicted

function E = ron_r(a, b)

    
    
     a = corrcoef(a, b);
     E = a(1,2);
end
