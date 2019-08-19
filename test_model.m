% Interface to test/evaluate the actual learning model.
% Supporting model: MLP, ANFIS
function [output] = test_model(net,input,model)

if (strcmp(model, 'MLP'))
    % test an input to MLP
    output = sim(net,input')';
elseif (strcmp(model, 'ANFIS'))
    % test an input to ANFIS network
    output = evalfis(input,net);
else
    display(['Model ' model ' not supported!!!'])
end
