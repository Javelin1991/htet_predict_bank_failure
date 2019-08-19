b1 = -0.19864;
b2 = -0.05262;
b3 = 0.672974;
b4 = 0.729972;
b0 = -0.04062;

[x,y] = meshgrid(0:0.05:1);

z = b3 * x + b4 * y + b0;
w = b1 * x + b2 * y;
subplot(1,2,1);
mesh(x,y,z);
axis([0 1 0 1 -0.1 1.4]);
xlabel('x_1');
ylabel('x_2');
zlabel('y_1');
title('y_1 = b_1*x_1 + b_2*x_2 + b_0');
subplot(1,2,2);
mesh(x,y,w,z);
axis([0 1 0 1 -0.2 -0.05]);
xlabel('x_3');
ylabel('x_4');
zlabel('y_2');
title('y_2 = b_3*x_3 + b_3*x_3');