function [output, net] = backpropnn(x,y)

net=newff([-1 1; -1 1; -1 1; -1 1; -1 1; -1 1],[2,1],{'tansig','tansig'},'traingd');
net.trainParam.show = 1000;
net.trainParam.lr = 0.01;
net.trainParam.epochs = 15000;
net.trainParam.goal = 1e-5;

[net,tr]=train(net,x',y');

output=sim(net,x');
