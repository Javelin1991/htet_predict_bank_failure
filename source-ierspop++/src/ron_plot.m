% XXXXXXXXXXXXXXXXXXXXXXXXXXXXX For Traffic XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% subplot(2, 1, 1);
% plot(traffic_1_60(1).data(551:1360, 5), 'b', 'LineWidth', 1);
% hold('on');
% plot(p(1).p(551:1360), 'r', 'LineWidth', 1);
% title('ieRSPOP R^2 = 0.76');
% ylabel('Lane 1 traffic density (t+60)');
% xlabel('Normalized time');
% labels = {sprintf('%.2f', traffic_1_60(1).data(551, 1)), sprintf('%.2f', traffic_1_60(1).data(642, 1)), sprintf('%.2f', traffic_1_60(1).data(733, 1)), ...
%     sprintf('%.2f', traffic_1_60(1).data(824, 1)), sprintf('%.2f', traffic_1_60(1).data(915, 1)), sprintf('%.2f', traffic_1_60(1).data(1006, 1)), ...
%     sprintf('%.2f', traffic_1_60(1).data(1097, 1)), sprintf('%.2f', traffic_1_60(1).data(1188, 1)), sprintf('%.2f', traffic_1_60(1).data(1279, 1)), ...
%     sprintf('%.2f', traffic_1_60(1).data(1360, 1))};
% set(gca, 'XLim', [0 820], 'XTick', [0 91 182 273 364 455 546 637 728 809], 'XTickLabel', labels);
% h = legend('Actual','Predicted', 2);
% set(h,'Interpreter','none')
% subplot(2, 1, 2);
% plot((traffic_1_60(1).data(551:1360, 5) - p(1).p(551:1360)).^2, 'b', 'LineWidth', 1);
% ylabel('Squared error');
% xlabel('Normalized time');
% set(gca, 'XLim', [0 820], 'XTick', [0 91 182 273 364 455 546 637 728 809], 'XTickLabel', labels);
%   
% clf;
% plot(rne, '-go', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'm', 'MarkerSize', 10)
% hold('on')
% plot(rn, '-bo', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'm', 'MarkerSize', 10)
% set(gca, 'XTick', [1 2 3]);
% ylim([166 173]);
% xlabel('Lane');
% ylabel('Rules');
% title('ieRSPOP vs iRSPOP in Rules');
% % h = legend('ieRSPOP','iRSPOP', 2);
% % set(h,'Interpreter','none')

% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX For MG XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% hold('on');
% plot(p(2).p(551:1371), '-.g', 'LineWidth', 1);
% title('Mackey Glass 4-step series');
% h = legend('Actual','Predicted', 2);
% set(h,'Interpreter','none')

% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX For real XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
s = 251;
e = 2180;
e2 = 2175;
int = floor((e-s)/3);
plot(s:e, data(s:e), 'b');
hold('on')
plot(s:e, p(1).predicted(e2-(e-s):e2), 'm');
plot(s:e, p(2).predicted, 'r');
plot(s:e, p(3).predicted, 'g');
% h = legend('Actual','ieRSPOP', 'RNFS', 'DENFIS', 2);
% set(h,'Interpreter','none')
xlim([s e]);
d = companies(27).dates;
labels = {datestr(d(s)), datestr(d(s+(1*int))), datestr(d(s+(2*int))), datestr(d(e))};
set(gca, 'XTick', [s s+(1*int) s+(2*int) e], 'XTickLabel', labels);
title('SingTel stock price');
ylabel('Stock price');
xlabel('Date');

% %XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX For garch XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
plot(1:6, garch2(:, 1), '-bo', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'm', 'MarkerSize', 10)
hold('on')
plot(1:6, garch2(:, 2), '-ro', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'm', 'MarkerSize', 10)
plot(1:6, garch2(:, 3), '-go', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'm', 'MarkerSize', 10)
h = legend('GARCH','EGARCH', 'GJR-GARCH', 2);
set(h,'Interpreter','none')
labels = {'w/none', 'w/RV', 'w/RR', 'w/RPV', 'w/BPV', 'w/all'};
set(gca, 'XTick', [1 2 3 4 5 6], 'XTickLabel', labels);
title('Comparison across intraday indicators for J.P Morgan');
ylabel('MSE');
xlabel('Input schema');

%XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX For garch XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
s = 1;
e = 96;
e2 = 246;
int = floor((e-s)/3);
plot(s:e, g2(:, 1), '-b')
hold('on')
plot(s:e, g2(:, 2), '-r')
plot(s:e, g2(:, 3), '-g')
% h = legend('Actual','Best GARCH model', 'Best GARCH-ieRSPOP schema', 2);
% set(h,'Interpreter','none')
d = companies(2).dates;
labels = {datestr(d(e2 - 3*int)), datestr(d(e2 - 2*int)), datestr(d(e2 - 1*int)), datestr(d(e2))};
set(gca, 'XTick', [s s+1*int s+2*int e], 'XTickLabel', labels);
title('J.P Morgan volatility');
ylabel('Value');
xlabel('Date');
% 
s = 1;
e = 246;
stop = 152;
int = floor((e-s)/3);
plot(1:stop, companies(2).realizedVar(1:stop, 1), '-r', 'LineWidth', 2)
hold('on')
plot(stop:246, companies(2).realizedVar(stop:246, 1), '-b', 'LineWidth', 1)
d = companies(2).dates;
labels = {datestr(d(s)), datestr(d(s+1*int)), datestr(d(s+2*int)), datestr(d(e))};
set(gca, 'XTick', [s s+1*int s+2*int e], 'XTickLabel', labels);
title('J.P Morgan volatility');
ylabel('Value');
xlabel('Date');