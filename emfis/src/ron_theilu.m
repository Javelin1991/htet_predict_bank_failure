% finds Theil's U index of inequality between a and b
% a should be desired, b should be predicted

function E = ron_theilu(a, b)

value1 = sum((a - b).^2);

num = size(a, 1);
c = zeros(num, 1);
for i = 1 : num
    if i == 1
        c(i, 1) = a(i, 1);
    else
        c(i, 1) = a(i, 1) - (a(i - 1, 1))^2;
    end
end
value2 = sum(c.^2);

E = value1 / value2;
