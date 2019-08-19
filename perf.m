% Calculate the performance of a feature subset based on complexity and accuracy.
% Number of features to represent complexity.
% MSE to represent accuracy.
function [p] = perf(reduced_no_of_features,total_no_of_features,after_mse,original_mse)

% Accuracy improvement
delta_accuracy = -((after_mse-original_mse)/original_mse);

% Complexity improvement
fraction_complexity = total_no_of_features / reduced_no_of_features;

% Performance of feature subset
p = fraction_complexity * exp(delta_accuracy);