%
%   Dynamic Evolving Neural-Fuzzy Inference System: DENFIS Simulating Function
%================================================================================
%=   Function Name:     denfiss.m                                               =
%=   Developer:         Qun Son                                                 =
%=   Date:              October, 20001                                          =
%=   Description:       Simulate the DENFIS trained by denfis                   =
%================================================================================
%
%    Syntax		 [Rresult] = denfiss(testingdata, Tresult)
%
% where testdata is the testing data set and Tresult is a structure produced
% by the DENFIS training function, denfis.
% The output structure, Rresult, includes following several fields:
% Rresult.Out:		output of the DENFIS evaluation on testing data
% Rresult.Abe:		errors of the evaluation on testing data

%--------------------------------------------------------------------------------
%   denfiss
%--------------------------------------------------------------------------------
  function [res] = denfiss(data3,DF)

     if DF.DispMode == 1
        disp(' ');
        disp('  DENFIS Simulating Process Starts');
     end

     % 1. Get parameters and pre-process data
     [res] = denfisf1s_ini(data3,DF);

     % 2  Evaluation
     [res] = denfisf1s_ev1(res,DF);

     % 3  Display results
     if DF.DispMode == 1
        disp(' ');
        disp('  Evaluating Results');
        disp(['  RMSE:                         '...
              sprintf('%0.3f',res.Rmse(res.Nd))]);
        disp(['  NDEI:                         '...
              sprintf('%0.3f',res.Ndei(res.Nd))]);
        disp(['  Simulating time (CPU-time):   '...
              sprintf('%0.1f',res.Time0)]);
        disp(' ');
        disp('  DENFIS Simulating Process ends ');
        disp(' ');
     end

  return;
%--------------------------------------------------------------------------------
%    function denfiss.m  end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    subfunction denfisf1s_ini
%--------------------------------------------------------------------------------
  function [res] = denfisf1s_ini(dat,DF)

     res.Time0        = cputime;
     [res.Nd res.Nx]  = size(dat);
     res.Ine          = DF.Ine;
     res.OriTeach     = dat(:,res.Ine+1:res.Nx);
     res.OriInput     = dat(:,1:res.Ine);
     res.rn           = DF.rn;
     res.Mofn         = DF.Mofn;
     res.TrainMode    = DF.TrainMode;
     res.FuzzyType    = DF.FuzzyType;
     res.Oute         = DF.Oute;

     for i = 1:res.Ine
         res.Input(:,i) = (dat(:,i) - DF.Mini(i))/(DF.Maxi(i) - DF.Mini(i));
     end                                               % nd-by-ine
  return;
%--------------------------------------------------------------------------------
%    subfunction denfisf1s_ini  end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    function denfisf1s_ev1
%--------------------------------------------------------------------------------
  function  [res] = denfisf1s_ev1(res,DF)

     for i = 1:res.Nd
         EX = res.Input(i,:);
         for j = 1:DF.rn
             D(j) = norm(EX - DF.Cent(j,:))/sqrt(res.Ine);
         end
         for j = 1:DF.Mofn
             [mina(j) inda(j)] = min(D);
             D(j)              = 1;
             frg(j,:)          = DF.Cent(inda(j),:);
         end

         for j = 1:DF.Mofn
             mind = inda(j);
             if DF.TrainMode == 2 & DF.FuzzyType == 2
                out0(j) = satlin(sim(DF.Net{mind},EX'));
             else
                out0(j) = satlin([1 EX] * DF.Fun{mind});
             end

             r(j) = 1;
             for k = 1:res.Ine
                 r(j) = r(j) * gaussmf(EX(k),[DF.Wh frg(j,k)]);
              end     % k = 1:ine
         end         % j = 1:mofn

         y0  = sum(r .* out0);
         y1  = sum(r);
         if y1 < 0.0001
            Y0 = 0;
            for k = 1:DF.Mofn
                Y0 = Y0 + out0(k) * (1 - mina(k));
            end
            out1 = Y0 / sum((1 - mina));
         else
            out1 = y0 / y1;
         end    % if y1 < 0.0001

         res.Out(i)  = out1 * (DF.Maxt - DF.Mint) + DF.Mint;
         res.Abe(i)  = res.Out(i) - res.OriTeach(i);
         res.Rmse(i) = norm(res.Abe(1:i))/sqrt(i);
         if i == 1
            res.Ndei(1) = 0;
         else
            res.Ndei(i) = res.Rmse(i)./std(res.OriTeach(1:i));
         end
         if i == 2
            res.Ndei(1) = res.Ndei(2);
         end

     end        % i = 1:nd
     res.Time0 = cputime-res.Time0;
  return;
%--------------------------------------------------------------------------------
%    function denfisf1s_ev1 end
%--------------------------------------------------------------------------------
