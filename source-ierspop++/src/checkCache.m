function D = checkCache(ensemble, data_input)


%755, 824 - 5
%504, 926
cache = ensemble.cache;
current_count = ensemble.dataProcessed-1;

if isempty(cache)
    cacheSize = 0;
else
    cacheSize = size(cache.net_struct,2);
end

if(cacheSize > 0)
    sums = 0;
    similarity = zeros(1, cacheSize);

    for i=1: size(cache.net_struct,2)
        for j=1:size(data_input,2)
        sums = sums + (data_input(:,j)-cache.net_struct(i).input(j))^2;
        end
        similarity(i) = sqrt(sums);
    end


    [value, index] = min(similarity);

    if exp(-value) > 0.9
        
        if(current_count > 900)
           hit = true; 
        end

        weights = zeros(1,size(ensemble.net_struct,2));
        for i=1:size(ensemble.net_struct,2)
           weights(1,i) = ensemble.net_struct(i).net.weight; 
        end

        [minWeight, minIndex] = min(weights);
        net = ensemble.net_struct(minIndex).net;

        if(minIndex == 1)
             ensemble.net_struct = ensemble.net_struct(2:size(ensemble.net_struct,2));
        elseif(minIndex == size(ensemble.net_struct,2))
             ensemble.net_struct = ensemble.net_struct(1:size(ensemble.net_struct,2)-1);
        else
             ensemble.net_struct =[ensemble.net_struct(1:minIndex-1) ensemble.net_struct(minIndex+1:size(ensemble.net_struct,2))];
        end
        ensemble.net_struct(size(ensemble.net_struct,2)+1).net = cache.net_struct(index).net;

    for i=1:size(ensemble.stored_input,2)
        ensemble.net_struct(size(ensemble,2)).net.predicted(current_count-i, :) = ron_cri(ensemble.stored_input(i, :), ensemble.net_struct(size(ensemble,2)).net);  
    end

    if(index == size(ensemble.cache.net_struct,2) && index ~= 1)
     ensemble.cache.net_struct = ensemble.cache.net_struct(1:index-1);  
     cacheIndex = size(ensemble.cache.net_struct,2) + 1;
    elseif(cacheSize == 1 && index == 1)
        ensemble = rmfield(ensemble, 'cache');
        cacheIndex = 1;
    elseif(index == 1 && cacheSize > 1)
     ensemble.cache.net_struct = ensemble.cache.net_struct(2:size(ensemble.cache.net_struct,2));  
     cacheIndex = size(ensemble.cache.net_struct,2) + 1;
    else
     ensemble.cache.net_struct = [ensemble.cache.net_struct(1:index-1) ensemble.cache.net_struct(index+1:cacheSize)];
     cacheIndex = size(ensemble.cache.net_struct,2) + 1;
    end

        ensemble.cache.net_struct(cacheIndex).net = net;
        ensemble.cache.net_struct(cacheIndex).belong = current_count;
        for m=1:size(ensemble.cache.net_struct(cacheIndex).net.input,2)
            ensemble.cache.net_struct(cacheIndex).input(m) = sum(ensemble.cache.net_struct(cacheIndex).net.input(1,m).range,2)/2;
        end
        
    else
    end
    
    num = 1;
    boolean = false;
    for m=1:size(ensemble.cache.net_struct,2)
        if(current_count - ensemble.cache.net_struct(1,m).belong < 3 * ensemble.fixWindowSize)
             boolean = true;
             cacheTemp.net_struct(1,num) = ensemble.cache.net_struct(1,m);
             num = num + 1;
        end
        
    end
    if boolean == true
        ensemble.cache = cacheTemp;
    else
        ensemble = rmfield(ensemble, 'cache');
    end
    
end
D= ensemble;
end

