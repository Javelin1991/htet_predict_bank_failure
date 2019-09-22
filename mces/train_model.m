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
    TrainData = x;
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
elseif strcmp(model, 'SaFIN_FRIE')
    TrainData = [x y];
    IND = 10;
    OUTD = 1;
    Epochs = 0;
    Eta = 0.05;
    Sigma0 = sqrt(0.16);
    Forgetfactor = 0.99;
    Lamda = 0.3;
    Rate = 0.25;
    Omega = 0.7;
    Gamma = 0.1;
    forget = 1;
    tau = 0.2;
    threshold = 0;


    system.total_network = 1;
    system.net.name = 'SAFIN++(FRIE)';
    system.net.Epochs = Epochs;
    system.net.Eta = Eta;
    system.net.Sigma0 = Sigma0; %SMALL PERTURBATION
    system.net.Rate = Rate; %LEARNING RATE
    system.net.Forgetfactor = Forgetfactor; %FORGETTING FACTOR
    system.net.Lamda = Lamda; %THRESHOLD FOR INTERPOLATION
    system.net.Omega = Omega;
    system.net.Gamma = Gamma;
    system.net.interpolated = zeros(1,size(TrainData,1));
    system.net.ruleCount = zeros(size(TrainData,1),1);
    net = system.net;
    %INITIALIZE NEURAL NET WITH FIRST ROW OF DATA
    net = SAFIN_FRIE_init(net, TrainData(1,1:IND), TrainData(1,IND+1:IND+OUTD), Sigma0);

    %TRAINING THE NET
    for i = 1 : size(TrainData, 1)
        disp('Progress: ');
        disp(i/size(TrainData,1)*100); %DISPLAY PROGRESS OF TRAINING
        %TRAINING THE NET
        net = SaFIN_FRIE_train(i, net, TrainData(i,1:IND), TrainData(i,IND+1:IND+OUTD),IND, OUTD, net.no_InTerms, net.InTerms, net.no_OutTerms, net.OutTerms,net.Rules, net.Rules_Weight, Eta, forget, Forgetfactor,Lamda,tau, Rate, Omega, Gamma);
        disp('Number of rules: ');
        disp(size(net.Rules,1));
        ruleCount(i,1) = size(net.Rules,1);
    end
else
    display(['Model ' model ' not supported!!!'])
end
