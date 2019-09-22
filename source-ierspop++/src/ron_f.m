function f = ron_f(b, x)
    z = filtfilt(b, 1, x);
    f(1) = (kurtosis(x) + kurtosis(z)) / kurtosis(x);
%     f(2) = var(z) / var(x - z);
    f(3) = ron_r2(z, x);
end
