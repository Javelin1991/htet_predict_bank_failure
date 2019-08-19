function [mse] = mmse(x,y)
% My version of mean square error

dim = size(x,1);
mse = sum((x-y).^2)/(2*dim);
