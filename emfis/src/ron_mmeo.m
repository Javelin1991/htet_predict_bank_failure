% finds mean mixed error (over predictions) between a and b
% a should be desired, b should be predicted

function E = ron_mmeo(a, b)

% forecast error
f_error = a - b;
num = size(f_error, 1);

Iu = zeros(num, 1);
Io = zeros(num, 1);
num_u = 0;
num_o = 0;

for i = 1 : num
    % error is negative means under prediction
    if f_error(i, 1) < 0
        % number of under predictions + 1
        num_u = num_u + 1;
        % flag for under prediction
        Iu(i, 1) = 1;
    % error is positive means over prediction
    else
        % number of over predictions + 1
        num_o = num_o + 1;
        % flag for over prediction
        Io(i, 1) = 1;
    end
end

value1 = (1 / num_u) * sum(Iu .* abs(f_error));
value2 = (1 / num_o) * sum(Io .* (f_error).^2);
E = value1 + value2;
