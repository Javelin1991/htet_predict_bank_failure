function output = ron_optimize(x, b0)

options = optimset('Display', 'iter');
f = @(b)ron_f(b, x);
[b, fval, exitflag] = fminimax(f, b0, [], [], [], [], [], [], [], options);

output = filtfilt(b,1,x);
% plot(1:250, y, 'r', 1:250, x, 'b');
% disp(['Kurtosis : ', num2str(kurtosis(y))]);
% disp(['SNR : ', num2str(var(y) / var(x - y))]);
% disp(['R2 : ', num2str(ron_r2(y, x))]);

end