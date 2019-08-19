function [output] = normalize(data)

% edim - dimension of examples, fdim - dimension of features.
[edim fdim] = size(data);

maxdata = max(data);
mindata = min(data);
avgdata = mean(data);

divisor = max((maxdata - avgdata), (avgdata - mindata));

for i=1:fdim
    output(:,i) = (data(:,i) - avgdata(1,i))./divisor(1,i);
end