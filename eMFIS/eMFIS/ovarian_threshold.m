
for i = 1: 5
   for j = 1:4
       result = zeros(107,1);
       
       if j < 4
            thresh = 0;
       else
           if i == 1
               thresh = 0.5;
           end
           if i == 2
               thresh = 0.55;
           end
           if i == 3
               thresh = 0.67;
           end 
           if i == 4
               thresh = 0.6;
           end 
           if i == 5
               thresh = 0.5005;
           end 
       end
%        if i == 4 && j == 3
%            thresh = 0.1;
%        end
       
       for k = 1 : 107
           if ovarian_result{i}{j}.predicted(k) > thresh
                result(k) = 1;
           else
                result(k) = 0;
           end
       end
       ovarian_result{i}{j}.after_thresh = result;
   end
end



for i = 1: 5
   for j = 1:4
       if j < 4
            label_0 = ovarian_result{i}{j}.after_thresh(31:75);
            label_1 = ovarian_result{i}{j}.after_thresh(76:end);
       else
            label_0 = ovarian_result{i}{j}.after_thresh(63:end);
            label_1 = ovarian_result{i}{j}.after_thresh(31:62);
       end
       correct_0 = length(find(label_0 == 0));
       correct_1 = length( find(label_1 - ones(32,1)== 0));
       ovarian_result{i}{j}.sensitivity = correct_1 / 32;
       ovarian_result{i}{j}.specificity = correct_0 / 45;
       ovarian_result{i}{j}.accuracy = (correct_1 + correct_0) / 77;
   end
end
       
       