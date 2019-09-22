% finds mean squared error between a and b
% a should be desired, b should be predicted

function E = ron_mse(a, b)

value = (a - b).^2;
E = mean(value);
