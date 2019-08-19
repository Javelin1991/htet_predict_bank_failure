function [error] = rmse(x,y)
% My version of root mean square error

dim = size(x,1);
mse = sum((x-y).^2)/(dim);
error = sqrt(mse);
