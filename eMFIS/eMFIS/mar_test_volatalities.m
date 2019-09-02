voldata = load('volatilitydata2.txt');  
vdata = [];

num_inputs = 5;

for i = 1:(size(voldata,1) - num_inputs)
    
    for j=0:num_inputs-1
    vdata(i,j+1) = voldata(j+i);
    end
    
    vdata(i,num_inputs+1) = voldata(num_inputs+i);

end

vdata

warning('off');

i = 1;
spec(i).algo = 'emfis';       

data_input = vdata(:, 1:num_inputs);
data_target = vdata(:, num_inputs+1);
    
    %start_test = (size(data_input, 1) / 2) + 1;
for m = 1 : 1
    start_test = 491;
    inMF = zeros(size(spec, 2), size(data_input, 2));
    outMF = zeros(size(spec, 2), size(data_target, 2));
    max_cluster = m + 23;
    half_life = 60;
    threshold_mf = 0.5;
    min_rule_weight = 0.4;
    
%     figure;
%     plot(1:size(data_input,1),data_input(1:size(data_input,1), 2));
%     figure;
%     hold all;
%     plot(1:size(data_input,1),data_input(1:size(data_input,1), 1));
%     for l=3:size(data_input,2)
%         plot(1:size(data_input,1),data_input(1:size(data_input,1), l));
%     end
     
    disp(['Running algo : ', spec(i).algo]);

    system = mar_trainOnline(data_input, data_target, spec(i).algo, max_cluster, half_life, threshold_mf, min_rule_weight);
    system = ron_calcErrors(system, data_target(start_test : size(data_target, 1)));

    system.num_rules = mean(system.net.ruleCount(start_test : size(data_target, 1)));

    figure;
    str = [sprintf('Actual VS Predicted <-> '), num2str(max_cluster)];
    title(str);

    for l = 1:size(data_target,2)
        hold on;
        plot(1:size(data_target,1),data_target(1:size(data_target,1)), 'b');
        plot(1:size(system.predicted,1),system.predicted(1:size(data_target,1)), 'r');
    end

    legend('Actual','eMFIS');

    comp_result(m).rmse = system.RMSE;
    comp_result(m).num_rules = system.num_rules;
                
end
clear data_input data_target;