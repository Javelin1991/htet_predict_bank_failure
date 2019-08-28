%
%================================================================================
%  Function Name: denfis_con.m                                                  =
%  Develpoer:     Qun Song                                                      =
%  Date:          October, 2001                                                 =
%  Description:   contrained function                                           =
%================================================================================
  function [g,g1] = denfis_con(x)

    %global fundata

    %f = 0;
    %for i = 1:fundata.mn0
    %    f0     = norm(x - fundata.data(i,:));
    %    f      = f + f0; 
    %    g(i,1) = f0 / sqrt(fundata.ine) - fundata.Md;       
    %end
    
    fid = fopen('fundata.txt', 'r');  
    mn  = fscanf(fid, '%f', [1 1]);
    Md  = fscanf(fid, '%f', [1,1]); 
    ine = fscanf(fid, '%f', [1,1]);  

    for i = 1:mn
        m0 = fscanf(fid, '%f', [1 ine]);
        for j = 1:ine
            elm(i,j) = m0(j);
        end
    end        
    fclose(fid);

    f = 0;
    for i = 1:mn
        f0     = norm(x - elm(i,:));
        f      = f + f0; 
        g(i,1) = f0 / sqrt(ine) - Md;         
    end

    g1 = [];
  return;   
%--------------------------------------------------------------------------------
%    function denfis_con end
%--------------------------------------------------------------------------------
