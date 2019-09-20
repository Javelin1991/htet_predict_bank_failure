function [no_Terms,Terms] = merge_MF(no_Terms,Terms,dim,label1,label2)

% label1 and label2 are to be merged.  To save merged MF under label1's
% postion and delete label2.

no_Terms(dim) = no_Terms(dim)-1;
[max_labels,index_labels] = max(no_Terms);
c1 = Terms(dim, 2*label1-1);
sig1 = Terms(dim,2*label1);
c2 = Terms(dim,2*label2-1);
sig2 = Terms(dim,2*label2);
Terms(dim,2*label1-1) = 0.5*(Terms(dim,2*label1-1) + Terms(dim,2*label2-1));
c = Terms(dim,2*label1-1);
if c2 < c1
    temp_c = c2;    temp_sig = sig2;
    c2 = c1;        sig2 = sig1;
    c1 = temp_c;    sig1 = temp_sig;
    clear temp_c; clear temp_sig;
end
x_1 = c1 - sig1*sqrt(log(2));
s1 = ((x_1-c)^2)/(log(2));
x_2 = c2 + sig2*sqrt(log(2));
s2 = ((x_2-c)^2)/(log(2));
sig = 0.5*(s1+s2);
Terms(dim,2*label1) = sig;
Terms(dim,2*label2-1:2*no_Terms(dim)) = Terms(dim,2*label2+1:2*(no_Terms(dim)+1));
Terms(dim,2*(no_Terms(dim)+1)-1) = 0;
Terms(dim,2*(no_Terms(dim)+1)) = 0;
Terms = Terms(:,1:2*max_labels);
