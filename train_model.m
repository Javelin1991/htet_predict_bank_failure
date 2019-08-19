% Interface to train the actual learning model.
% Supporting model: MLP, ANFIS
function [net] = train_model(x,y,model)

if (strcmp(model, 'MLP'))
    % train an MLP
    net = train_mlp(x,y,3000);
elseif (strcmp(model, 'ANFIS'))
    % train an ANFIS network
    net = train_anfis(x,y,10);
else
    display(['Model ' model ' not supported!!!'])
end
