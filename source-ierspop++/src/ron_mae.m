% finds mean absolute error between a and b
% a should be desired, b should be predicted

function E = ron_mae(a, b)

value = abs(a - b);
E = mean(value);
