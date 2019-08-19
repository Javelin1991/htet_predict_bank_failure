function [fismat1] = train_anfis(x,y,epoch)

fismat = genfis2(x,y,0.2);
% fismat = genfis2(x,y,0.1);

% trnOpt(1): number of training epochs, default = 10.
% trnOpt(2): error tolerance, default = 0.
% trnOpt(3): initial step-size, default = 0.01.
% trnOpt(4): step-size decrease rate, default = 0.9.
% trnOpt(5): step-size increase rate, default = 1.1.
trnOpt = [epoch 0 0.01 0.9 1.1];

[fismat1,error1,ss] = anfis([x y],fismat,trnOpt);
% anfis_output = evalfis(x, fismat1);
