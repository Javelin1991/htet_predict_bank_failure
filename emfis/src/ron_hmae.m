% finds mean absolute error between a and b
% a should be desired, b should be predicted

function E = ron_hmae(a, b)

value = abs(1 - ((a.^-1) .* b));
E = mean(value);
