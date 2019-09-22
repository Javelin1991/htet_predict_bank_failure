% finds heteroskedasticity adjusted mean squared error between a and b
% a should be desired, b should be predicted

function E = ron_hmse(a, b)

value = (1 - ((a.^-1) .* b)).^2;
E = mean(value);
