% finds adjusted mean absolute percentage error between a and b
% a should be desired, b should be predicted

function E = ron_amape(a, b)

value = abs((a - b) ./ (a + b));
E = mean(value);
