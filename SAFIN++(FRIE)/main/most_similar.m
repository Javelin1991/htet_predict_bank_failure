function [index_1,index_2,C2] = most_similar(no_Terms,InTerms)

similar = zeros(no_Terms);
Terms = zeros(1,2*no_Terms); % 1 X 2*no_Terms
for term = 1:no_Terms %for each term in the dimension
    Terms(2*term-1) = InTerms(2*term-1);
    Terms(2*term) = InTerms(2*term);
end
for i = 1:no_Terms %for each term
    a1 = 0.5*(4*Terms(2*i)*sqrt(log(2)))*1; %area of isosceles triangle = 4*width*sqrt(log(2))
    for j = i + 1:no_Terms  %for other terms in the dimension
        a2 = 0.5*(4*Terms(2*j)*sqrt(log(2)))*1; %area of isosceles triangle = 4*width(sqrt(log(2))
        %%%%%%%%%%%%%%%%%%%compute a3%%%%%%%%%%%%%%%%%
        % x = (c1*w2+c2*w1) / (w1+w2)
        x = ( Terms(2*i-1)*Terms(2*j) + Terms(2*j-1)*Terms(2*i) )/( Terms(2*i) + Terms(2*j) );
        if Terms(2*i-1) < Terms(2*j-1)  %c1 < c2
            %y = 1 - (x - c1) / (2*w1*sqrt(log(2))
            y = 1 - (x-Terms(2*i-1))/(2*Terms(2*i)*sqrt(log(2)));
        else
            %y = 1 - (x - c2) / (2*w2*sqrt(log(2))
            y = 1 - (x-Terms(2*j-1))/(2*Terms(2*j)*sqrt(log(2)));
        end
        if y < 0
            a3 = 0;
        else
            pi1 = Terms(2*i-1)-2*Terms(2*i)*sqrt(log(2)); %pi1 = c1 - 2*w1*sqrt(log(2))
            pi2 = Terms(2*i-1)+2*Terms(2*i)*sqrt(log(2)); %pi2 = c1 + 2*w1*sqrt(log(2))
            pj1 = Terms(2*j-1)-2*Terms(2*j)*sqrt(log(2)); %pj1 = c2 - 2*w2*sqrt(log(2))
            pj2 = Terms(2*j-1)+2*Terms(2*j)*sqrt(log(2)); %pj2 = c2 + 2*w2*sqrt(log(2))
            a3 = 0;
            if Terms(2*i-1) < x %c1 < x
                a3 = a3 + 0.5*(pi2-x)*y;  %area
            else
                a3 = a3 + 0.5*(x-pi1)*y;  %area
            end
            if Terms(2*j-1) < x %c2 < x
               a3 = a3 + 0.5*(pj2-x)*y;
            else
               a3 = a3 + 0.5*(x-pj1)*y;
            end
        end
        similar(i,j) = min([a3/a1;a3/a2]);
    end
end
[C1,I1] = max(similar);
[C2,I2] = max(C1');
if I2 < I1(I2)
    index_1 = I2;
    index_2 = I1(I2);
else
    index_1 = I1(I2);
    index_2 = I2;
end
