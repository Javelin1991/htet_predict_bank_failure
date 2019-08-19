function [net] = train_mlp(x,y,epoch)

idim = size(x,2);
odim = size(y,2);

net=newff(minmax(x'),[2*idim,odim],{'tansig','purelin'},'traingdx');
net.trainParam.show = 100;
net.trainParam.lr = 0.01;
net.trainParam.epochs = epoch;
net.trainParam.goal = 1e-5;

[net,tr]=train(net,x',y');
% output = sim(net,x')';
