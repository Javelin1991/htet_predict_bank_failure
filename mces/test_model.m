% Interface to test/evaluate the actual learning model.
% Supporting model: MLP, ANFIS
function [output] = test_model(net,input,model, current_count)

if (strcmp(model, 'MLP'))
    % test an input to MLP
    output = sim(net,input')';
elseif (strcmp(model, 'eMFIS') || strcmp(model, 'eMFIS_classification'))
    % test an input to eMFIS network
    output = htet_test_emfis(net, input, current_count);
elseif strcmp(model, 'SaFIN_FRIE')
    input_dimen = 10;
    output_dimen = 1;
    output = SaFIN_FRIE_test(input,input_dimen,output_dimen,net.no_InTerms,net.InTerms,net.no_OutTerms,net.OutTerms,net.Rules);
else
    display(['Model ' model ' not supported!!!'])
end
