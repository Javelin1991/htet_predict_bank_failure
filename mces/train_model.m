% Interface to train the actual learning model.
% Supporting model: MLP, ANFIS
function [net] = train_model(x, y, model, params)

if (strcmp(model, 'MLP'))
    % train an MLP
    net = train_mlp(x,y,3000);
elseif (strcmp(model, 'ANFIS'))
    % train an ANFIS network
    net = train_anfis(x,y,10);
elseif (strcmp(model, 'eMFIS'))
    algo = 'emfis';
    spec = 10;
    % train an eMFIS network
    max_cluster = 40;
    half_life = 10; %half_life = 10 works best
    threshold_mf = 0.9999;
    min_rule_weight = 0.7;

    data_input = x;
    data_target = y;
    start_test = size(data_input, 1) * 0.8;
    inMF = zeros(size(spec, 2), size(data_input, 2));
    outMF = zeros(size(spec, 2), size(data_target, 2));

    disp(['Running algo : ', algo]);
    ie_rules_no = 2;
    create_ie_rule = 0;
    system = mar_trainOnline(ie_rules_no ,create_ie_rule, data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
    net = system;
elseif strcmp(model, 'eMFIS_classification')
    data_input = x;
    data_target = y;

    algo = params.algo;
    max_cluster = params.max_cluster;
    half_life = params.half_life;
    threshold_mf = params.threshold_mf;
    min_rule_weight = params.min_rule_weight;
    spec = params.spec;
    ie_rules_no = params.ie_rules_no;
    create_ie_rule = params.create_ie_rule
    system = mar_trainOnline(ie_rules_no ,create_ie_rule, data_input, data_target, algo, max_cluster, half_life, threshold_mf, min_rule_weight);
    net = system;
else
    display(['Model ' model ' not supported!!!'])
end
