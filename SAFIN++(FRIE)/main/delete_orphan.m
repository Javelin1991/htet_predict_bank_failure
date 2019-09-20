function [Rules,Terms] = delete_orphan(Rules,Terms,dim)

no_Terms = size(Terms,2)/2; %get number of terms in the dimension
orphan = ones(no_Terms,1); 
for i = 1:size(Rules,1)
    orphan(Rules(i,dim)) = 0;  %if the cluster appear in the rule => orphan mark to 0 
end
delete = [];
new_Terms = [];
for i = 1:size(orphan,1) %for each term
    if orphan(i) == 1 %term do not appear in any rule
        delete = [delete;i];  %mark the term
    else %term appear
        new_Terms = [new_Terms Terms(1,2*i-1) Terms(1,2*i)]; %add term left_centre to the new matrix
    end
end
Terms = new_Terms;
clear new_Terms;
clear orphan;
for i = 1:size(delete,1) %for each deleted term 1, 2, 3, 4...
    for j = i+1:size(delete,1) %for the term larger 2, 3, 4...
        delete(j) = delete(j)-1; %modify the order of the term
    end
    for j = 1:size(Rules,1) %for each rule
        if Rules(j,dim) > delete(i) %if we delete term 2 => 
            Rules(j,dim) = Rules(j,dim)-1; %term 3,4,5 becomes term 2,3,4
        end
    end
end
        