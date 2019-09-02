load stock_predicted;
load stock_systems;
load ron_companies;

for i=27:27
    
figure;    
s = 251;
e = size(companies(1,i).adjclose, 1);
e2 = e-5;
int = floor((e-s)/3);
data = companies(1, i).adjclose; 
plot(s:e, data(s:e), 'b');
hold('on')
plot(s:e2-1, predicted_ierspopn.net_struct(i).predict(s:e2-1), 'y');
%plot(s:e2-1, predicted_ierspop.net_struct(i).predict(s:e2-1), 'r');
%plot(s:e2-1, predicted_denfis.net_struct(i).predicted, 'r');
% h = legend('Actual','ieRSPOP', 'RNFS', 'DENFIS', 2);
% set(h,'Interpreter','none')
xlim([s e2]);
d = companies(i).dates;
labels = {datestr(d(s)), datestr(d(s+(1*int))), datestr(d(s+(2*int))), datestr(d(e))};
set(gca, 'XTick', [s s+(1*int) s+(2*int) e], 'XTickLabel', labels);
title(companies(1,i).name);
ylabel('Stock price');
xlabel('Date');


end

