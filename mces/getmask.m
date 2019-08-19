function [mask,accuracy] = getmask(weight,x,y,net)

momentum = 8;

idim = size(x,2);
average = mean(x)';

% s_weight = [weight rank]
[s_weight] = sortrows([weight [1:1:idim]'], 1);

accuracy = zeros(idim+1,1);
% mask = ones(idim,1);
accuracy(1) = mmse(sim(net,x')',y);
m_x = x;

for i = 1:idim
    % Set mask to zero.
    % mask(rank(i)) = 0;
    
    % Disable those features with mask zero.
    m_x(:,s_weight(i,2)) = average(s_weight(i,2));
    
    accuracy(i+1) = mmse(sim(net,m_x')',y);
end

tolerance = max(accuracy)*momentum/idim;

mask = ones(idim,1);
for i = 1:idim
    if accuracy(i+1) <= tolerance
        mask(s_weight(i,2)) = 0;
    end
end
