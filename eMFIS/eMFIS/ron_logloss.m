% finds logarithmic loss between a and b
% a should be desired, b should be predicted

function E = ron_logloss(a, b)

value = (log(a) - log(b)).^2;
E = mean(value);
