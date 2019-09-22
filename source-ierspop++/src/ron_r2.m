% finds pearson's correlation coefficient between a and b
% a should be desired, b should be predicted

function E = ron_r2(a, b)
     r2 = corr2(a,b);
     E = r2;
end
