%
%    Dynamic Evolving Neural-Fuzzy Inference System: DENFIS Training Function
%================================================================================
%=   Function Name:       denfis.m                                              =
%=   Algorithm Designer:  Qun Song                                              =
%=   Program Developer:   Qun Song                                              =
%=   Date:                October, 2001                                         =
%================================================================================
%
%       Syntax	[Tresult] = denfis(traindata, parameters);
%
% Here, traindata is the training data set, and parameters is a structure
% including several fields described as next lines:
% �	parameters.trainmode:	set 1 for on-line training, 2 for off-line training
%                            (first-order TS FIS), and 3 for off-line training
%                            (high-order TS FIS) (default: 1).
% �	parameters.dthr :		distance threshold (default: 0.1).
% �	parameters.mofn: 		the number of rules in a dynamic FIS (default: 3).
% �	Parameters.ecmepochs : 	the number of epochs of clustering optimisation
%                            (default: 0).
% �	parameters.mlpepochs:	the number of  epochs for creating a High-order TS
%                            fuzzy rule (default: 10).
% �	parameters.dispmode:	1 for displaying the information of training
%                            process in numeric and otherwise  displaying
%                            nothing (default: 1).
%
% The output structure, Tresult, includes following fields:
% Tresult.Cent:			        rule nodes (centres of partitioned regions) in
%                               input space
% Tresult.Fun or Tresult.Net:	functions of TSK fuzzy rules
% Tresult.Out:			        output of DENFIS evaluation on training data
% Tresult.Abe:			        absolute errors of the evaluation on training
%                               data

%--------------------------------------------------------------------------------
%   denfis
%--------------------------------------------------------------------------------
  function [DF] = denfis(data2,varargin)

     % 1. Get parameters and pre-process data
     parm0 = [];
     if length(varargin) > 0
        parm0 = varargin{1};
     end

     [DF]  = denfisf1_ini(data2,parm0);
     if DF.TrainMode == 2
        %  denfisf1 off-line training
        [DF] = denfisf1_offline(DF);
        return;
     end

     % 2. on-line training and evaluating
     if DF.DispMode == 1
        disp(' ');
        disp('    DENFIS On-line training Starts');
        [DF] = denfisf1_ec1(DF);
     end

     % 3  Display results
     if DF.DispMode == 1
        disp(' ');
        disp('    Training Results');
        disp(['    Number of rules:           ' int2str(DF.rn)]);
        disp(['    Objective Value:           ' sprintf('%0.3f',DF.Obj)]);
        disp(['    Maximum Distance:          ' sprintf('%0.3f',DF.MaxD)]);
        disp(' ');
        disp('    Evaluating Results on Training Data');
        disp(['    RMSE:                      '...
              sprintf('%0.3f',DF.Rmse(DF.Nd))]);
        disp(['    NDEI:                      '...
              sprintf('%0.3f',DF.Ndei(DF.Nd))]);
        disp(['    Training time (CPU-time):  '...
              sprintf('%0.1f',DF.Time0)]);
        disp(' ');
        disp('    DENFIS On-line training ends ')
     end

  return;
%--------------------------------------------------------------------------------
%    function denfis.m  end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    subfunction denfisf1_ini
%--------------------------------------------------------------------------------
  function [DF] = denfisf1_ini(dat,parm0);

     DF.Dthr       = 0.1;
     DF.EcmEpochs  = 0;
     DF.EcmImp     = 0.0001;
     DF.EcmTol     = 0.0001;
     DF.TrainMode  = 1;
     DF.DispMode   = 1;
     DF.ExtRegion  = 0.05;
     DF.Overlap    = DF.Dthr*1.2;
     DF.FuzzyType  = 1;
     DF.Mofn       = 3;
     DF.ForgetFact = 0.9;
     DF.NumNeuron  = 4;
     DF.MLPEpochs  = 10;
     DF.MLPGoal    = 0.0001;
     DF.Oute       = 1;

     [DF.Nd, DF.Nx] = size(dat);
     if isfield(parm0, 'oute')
        DF.Oute = parm0.oute;
        if DF.Oute < 1;              DF.Oute = 1;               end;
        if DF.Oute > DF.Nx-1;        DF.Oute = 1;               end;
     end
     DF.Ine = DF.Nx - DF.Oute;

     DF.MinNumSap = DF.Ine + 6;
     if isfield(parm0, 'dthr')
        DF.Dthr = parm0.dthr;
        if DF.Dthr < 0.01;           DF.Dthr = 0.01;            end;
        if DF.Dthr > 0.3;            DF.Dthr = 0.3;             end;
     end
     DF.Wh = DF.Dthr/sqrt(-2*log(0.6));

     if isfield(parm0, 'ecmepochs')
        DF.EcmEpochs = parm0.ecmepochs;
        if DF.EcmEpochs > 20;        DF.EcmEpochs = 20;         end;
     end
     if isfield(parm0, 'ecmimp')
        DF.EcmImp = parm0.ecmimp;
        if DF.EcmImp < 0;            DF.EcmImp = 0;             end;
     end
     if isfield(parm0, 'ecmtol')
        DF.EcmTol = parm0.ecmtol;
        if EF.EcmTol < 0;            DF.EcmTol = 0;             end;
     end
     if isfield(parm0, 'trainmode')
        DF.TrainMode = parm0.trainmode;
        if DF.TrainMode < 1;         DF.TrainMode = 1;          end;
        if DF.TrainMode > 3;         DF.TrainMode = 3;          end;
     end
     DF.FuzzyType  = 1;
     if DF.TrainMode == 3
        DF.FuzzyType = 2;
        DF.TrainMode = 2;
     end
     if isfield(parm0, 'dispmode')
        DF.DispMode = parm0.dispmode;
     end
     if isfield(parm0, 'extregion')
        DF.ExtRegion = parm0.extregion;
        if DF.ExtRegion < 0;         DF.ExtRegion = 0;          end;
        if DF.ExtRegion > 0.25;      DF.ExtRegion = 0.25;       end;
     end
     if isfield(parm0, 'overlap')
        DF.Overlpa = parm0.overlap;
        if DF.Overlpa < DF.Dthr;     DF.Overlpa = DF.Dthr ;     end;
        if DF.Overlpa > 2*DF.Dthr;   DF.Overlpa = 2*DF.Dthr;    end;
     end
     if isfield(parm0, 'mns')
        DF.MinNumSap = parm0.mns;
        if DF.MinNumSap < DF.Ine+3;  DF.MinNumSap = DF.Ine+3;   end;
        if DF.MinNumSap > DF.Nd;     DF.MinNumSap = DF.Nd;      end;
     end
     %if isfield(parm0, 'ftype')
     %   DF.FuzzyType = parm0.ftype;
     %   if DF.FuzzyType < 1;         DF.FuzzyType = 1;          end;
     %   if DF.FuzzyType > 2;         DF.FuzzyType = 2;          end;
     %end
     if isfield(parm0, 'mofn')
        DF.Mofn = parm0.mofn;
        if DF.Mofn < 2;              DF.Mofn      = 2;          end;
        if DF.Mofn > 11;             DF.Mofn      = 11;         end;
     end
     if isfield(parm0, 'forgetfact')
        DF.ForgetFact = parm0.forgetfact;
        if DF.ForgetFact < 0.5;      DF.ForgetFact = 0.5;       end;
        if DF.ForgetFact > 1;        DF.ForgetFact = 1;         end;
     end
     if isfield(parm0, 'numn')
        DF.NumNeuron = parm0.numn;
        if DF.NumNeuron < 2;         DF.NumNeuron = 2;          end;
        if DF.NumNeuron > 8;         DF.NumNeuron = 8;          end;
     end
     if isfield(parm0, 'mlpepochs')
        DF.MLPEpochs = parm0.mlpepochs;
        if DF.MLPEpochs < 3;         DF.MLPEpochs = 3;          end;
        if DF.MLPEpochs > 500;       DF.MLPEpochs = 500;        end;
     end
     if isfield(parm0, 'mlpgoal')
        DF.MLPGoal = parm0.mlpgoal;
        if DF.MLPGoal < 0;           DF.MLPGoal = 0;            end;
     end

     DF.OriInput  = dat(:,1:DF.Ine);
     DF.OriTeach  = dat(:,DF.Ine+1:DF.Nx);
     DF.Time0     = cputime;

   % data normalizing
     for i = 1:DF.Ine
         max0          = max(DF.OriInput(:,i));
         min0          = min(DF.OriInput(:,i));
         DF.Maxi(i)    = max0 + (max0 - min0) * DF.ExtRegion;
         DF.Mini(i)    = min0 - (max0 - min0) * DF.ExtRegion;
         DF.Input(:,i) = (DF.OriInput(:,i)-DF.Mini(i))/(DF.Maxi(i)-DF.Mini(i));
     end                                               % nd-by-ine

     for i = 1:DF.Oute
         max0          = max(DF.OriTeach(:,i));
         min0          = min(DF.OriTeach(:,i));
         DF.Maxt(i)    = max0 + (max0 - min0) * DF.ExtRegion;
         DF.Mint(i)    = min0 - (max0 - min0) * DF.ExtRegion;
         DF.Teach(:,i) = (DF.OriTeach(:,i)-DF.Mint(i))/(DF.Maxt(i)-DF.Mint(i));
     end                                               % nd-by-oute

  return;
%--------------------------------------------------------------------------------
%    subfunction denfisf1_ini  end
%--------------------------------------------------------------------------------

%================================================================================
%     denfisf1_offline
%================================================================================
  function [DF] = denfisf1_offline(DF,cTime0)

     if DF.DispMode == 1
        disp(' ');
        disp('    DENFIS Off-line training Starts');
     end

     % 1. Clustering
     [DF] = denfisf1_ec2(DF);

     % 2  Rule Creating
     [DF] = denfisf1_cr2(DF);

     % 3  Training Results Evaluating
     [DF] = denfisf1_ev2(DF);

     % 4  Display results
     if DF.DispMode == 1
        disp(' ');
        disp(['    Training Results']);
        disp(['    Number of rules:           ' int2str(DF.rn)]);
        disp(['    Objective function:        '...
              sprintf('%0.3f',DF.Obj)]);
        disp(['    Maximum distance:          '...
              sprintf('%0.3f',DF.MaxD)]);
        disp(['    Training time (CPU-time):  '...
              sprintf('%0.1f',DF.Time0)]);
        disp(' ');
        disp(['    Evaluating Results on Training Data']);
        disp(['    RMSE:                      '...
              sprintf('%0.3f',DF.Rmse(DF.Nd))]);
        disp(['    NDEI:                      '...
              sprintf('%0.3f',DF.Ndei(DF.Nd))]);
        disp(' ');
        disp('    DENFIS Off-line training ends ');
        disp(' ');
     end
  return;
%--------------------------------------------------------------------------------
%    function denfisf1_offline end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    subfunction denfisf1_ec1
%--------------------------------------------------------------------------------
  function [DF] = denfisf1_ec1(DF);

     warning off
     % create the first node
     DF.rn        = 1;
     DF.Crn       = [1];
     DF.Clas1{1}  = [DF.Input(1,:); DF.Input(1,:)];
     DF.Radius(1) = 0;
     DF.Obj       = 0;
     DF.MaxD      = 0;
     DF.Forget    = [];
     DF.Out       = [];
     DF.Abe       = [];
     DF.Rmse      = [];
     DF.Ndei      = [];
     ind1         = [1];
     rn0          = 1;

     if DF.DispMode == 1
        disp(' ');
        disp('    Data Information');
        disp(['    Samples:       ' int2str(DF.Nd)]);
        disp(['    Input(s):      ' int2str(DF.Ine)]);
        disp(['    Output(s):     ' int2str(DF.Oute)]);
        disp(' ');
        disp('    Parameter(s)');
        disp( '    Rule-Type:     First-order TSK');
        disp(['    Threshold:     ' sprintf('%0.3f',DF.Dthr)]);
        disp(['    M-of-N:        ' int2str(DF.Mofn)]);
        disp(' ');
        dt1 = sprintf('%0.1f',(cputime - DF.Time0));
        disp('     Rules        Samples         Time')
        disp(['        1             1             ' dt1])
     end

     % create the first m fuzzy rules
     for i = 2:DF.Nd
         [DF,ind1]  = denfisf1_ec11(DF,ind1,i);
         if DF.rn > rn0
            rn0    = DF.rn;
            DF.Crn = [DF.Crn; i];
            if DF.DispMode == 1
               disp([sprintf('%9d',DF.rn)...
                     sprintf('%14d',i)...
                     sprintf('%16.1f',cputime-DF.Time0)]);
            end
         end

         DF.Cent = [];
         for j = 1:DF.rn
             DF.Cent(j,:) = DF.Clas1{j}(1,:);
         end

         if DF.rn >= DF.Mofn & i >= DF.MinNumSap
            ini  = i;
            break;
         end
     end                           % i = 2:nd

     for i = 1:DF.rn
         f1   = 0;
         rcr0 = DF.Overlap;
         for j = 1:ini
             D(j) = norm(DF.Cent(i,:) - DF.Input(j,:))/sqrt(DF.Ine);
         end          % j = 1:ini

         while (f1 == 0)
               X  = [];
               Y  = [];
               for j = 1:ini
                   if D(j) <= rcr0
                      X = [X; 1 DF.Input(j,:)];
                      Y = [Y; DF.Teach(j,:)];
                   end
               end
               [Ne Ne0] = size(Y);
               if Ne < DF.MinNumSap
                  rcr0 = rcr0 * 1.05;
               else
                  f1 = 1;
               end
         end          % while (f1 == 0)

         P0           = inv(X'*X);
         K{i}.P       = P0;
         K{i}.Q       = P0 * X' * Y;
         DF.Forget(i) = 1;
     end              % i = 1:rn

     for i = 1:ini
         [DF] = denfisf1_ev1(DF,K,i);
     end

     % create new nodes and update nodes
     for i = ini+1:DF.Nd

         [DF] = denfisf1_ev1(DF,K,i);

         % update the functions
         [K,w1,inw1] = denfisf1_ec12(DF,K,i);

         % create or update the cluster
         [DF,ind1]  = denfisf1_ec11(DF,ind1,i);
         if DF.rn > rn0
            rn0    = DF.rn;
            DF.Crn = [DF.Crn; i];
            if DF.DispMode == 1
               disp([sprintf('%9d',DF.rn)...
                     sprintf('%14d',i)...
                     sprintf('%16.2f',cputime-DF.Time0)]);
            end
            % create a function
            [DF,K] = denfisf1_ec13(DF,K,i,w1,inw1);
         end

         DF.Cent = [];
         for j = 1:DF.rn
             DF.Cent(j,:) = DF.Clas1{j}(1,:);
         end

         if i == DF.Nd
            [DF.Obj, DF.MaxD] =  denfisf1_ec14(DF);
         end
     end                           % i = ini:nd

     for j = 1:DF.rn
         DF.Fun{j} = K{j}.Q;
     end

     DF.Time0 = cputime - DF.Time0;
     warning on
  return;
%--------------------------------------------------------------------------------
%    function denfisf1_ec1 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    subfunction denfisf1_ec11
%    create a new cluster or update an existed one
%--------------------------------------------------------------------------------
  function [DF,ind1] = denfisf1_ec11(DF,ind1,i)

     EX = DF.Input(i,:);
     for j = 1:DF.rn
         D(j) = norm(EX - DF.Clas1{j}(1,:))/sqrt(DF.Ine) + DF.Radius(j);
     end;
     [mina1,inda1] = min(D);
     if mina1 - DF.Radius(inda1) <= DF.Radius(inda1)
        return;
     end

     if mina1 > 2*DF.Dthr
        DF.rn            = DF.rn + 1;         % create a new class
        DF.Clas1{DF.rn}  = [EX; EX];
        DF.Radius(DF.rn) = 0;
        ind1             = [ind1; i];
     else
        D0   = mina1 - DF.Radius(inda1);
        R0   = mina1 / 2;
        dist = EX - DF.Clas1{inda1}(1,:);

        for k = 1:DF.Ine
            dx  = abs(dist(k)) * R0/D0;
            if dist(k) > 0
               DF.Clas1{inda1}(1,k) = EX(k) - dx;
            else
               DF.Clas1{inda1}(1,k) = EX(k) + dx;
            end
        end

        DF.Radius(inda1) = R0;
        DF.Clas1{inda1}  = [DF.Clas1{inda1}; EX];

     end                                 % if mina1 > 2 * DF.Dthr
  return;
%--------------------------------------------------------------------------------
%   subfunction denfis1_ec11 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%   subfunction denfisf1_ec12
%--------------------------------------------------------------------------------
  function  [K,w1,inw1] = denfisf1_ec12(DF,K,i)

     ex1 = [1 DF.Input(i,:)];

     for j = 1:DF.rn
         D(j) = norm(DF.Input(i,:) - DF.Cent(j,:))/sqrt(DF.Ine);
     end

     [w1 inw1] = min(D);

     for j = 1:DF.Mofn
         [w0 inw0]     = min(D);
         D(inw0)       = 1;
         w(j)          = 1 - w0;
         inw(j)        = inw0;

         P0  = K{inw0}.P;
         Q0  = K{inw0}.Q;

         pp1 = w(j) * P0 * ex1' * ex1 * P0;
         pp2 = DF.Forget(inw0) + w(j) * ex1 * P0 * ex1';
         %P1  = (P0 - pp1/pp2)/DF.Forget(inw0);
         P1  = (P0 - pp1/pp2)/DF.ForgetFact;

         K{inw0}.P  = P1;
         K{inw0}.Q  = Q0 + w(j) * P1 * ex1' * (DF.Teach(i,:) - ex1 * Q0);

     end
  return;
%--------------------------------------------------------------------------------
%   subfunction denfisf1_ec12 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%   subfunction denfisf1_ec13 end
%   create a linear function for the new rule
%--------------------------------------------------------------------------------
  function [DF,K] = denfisf1_ec13(DF,K,i,w0,inda1)

     DF.Forget(DF.rn) = DF.ForgetFact;
     ex1              = [1 DF.Input(i,:)];
     P0               = K{inda1}.P;
     Q0               = K{inda1}.Q;
     pp1              = w0 * P0 * ex1' * ex1 * P0;
     pp2              = DF.ForgetFact + w0 * ex1 * P0 * ex1';
     P1               = (P0 - pp1/pp2)/DF.ForgetFact;
     K{DF.rn}.P       = P1;
     K{DF.rn}.Q       = Q0 + w0 * P1 * ex1' * (DF.Teach(i,:) - ex1 * Q0);

  return;
%--------------------------------------------------------------------------------
%   subfunction denfisf1_ec13 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%   subfunction denfisf1_ec14
%--------------------------------------------------------------------------------
  function [obj0,maxD] = denfisf1_ec14(DF)

      U     = zeros(DF.rn,DF.Nd);
      obj0  = 0;

      for j = 1:DF.Nd
          for i = 1:DF.rn
              D(i,j) = norm(DF.Input(j,:) - DF.Cent(i,:))/sqrt(DF.Ine);
          end

          [min0,ind0] = min(D(:,j));
          U(ind0,j)   = 1;
          %obj0 = obj0 + sum(U(:,j).*D(:,j));
          obj0  = obj0 + min0;
      end

      for i = 1:DF.rn
          for j = 1:DF.Nd
              D(i,j) = D(i,j) * U(i,j);
          end
      end
      maxD   = max(max(D));

  return;
%--------------------------------------------------------------------------------
%   subfunction denfisf1_ec14 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    function denfisf1_ev1
%--------------------------------------------------------------------------------
  function  [DF] = denfisf1_ev1(DF,K,i)

     EX        = DF.Input(i,:);

     for j = 1:DF.rn
         D(j) = norm(EX - DF.Cent(j,:))/sqrt(DF.Ine);
     end
     for j = 1:DF.Mofn
         [mina(j) inda(j)] = min(D);
         D(j)              = 1;
         frg(j,:)          = DF.Cent(inda(j),:);
     end

     for j = 1:DF.Mofn
         mind    = inda(j);
         out0(j) = satlin([1 EX] * K{mind}.Q);
         r(j) = 1;
         for k = 1:DF.Ine
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

     DF.Out(i)  = out1 * (DF.Maxt - DF.Mint) + DF.Mint;
     DF.Abe(i)  = DF.Out(i) - DF.OriTeach(i);
     DF.Rmse(i) = norm(DF.Abe(1:i))/sqrt(i);

     if i == 1
        DF.Ndei(1) = 0;
     else
        DF.Ndei(i) = DF.Rmse(i)./std(DF.OriTeach(1:i));
     end
     if i == 2
        DF.Ndei(1) = DF.Ndei(2);
     end
  return;
%--------------------------------------------------------------------------------
%    function denfisf1_ev1 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    subfunction denfisf1_ec2
%--------------------------------------------------------------------------------
  function [DF] = denfisf1_ec2(DF)

     warning off
     % create the first node
     DF.Crn       = [1];
     DF.Clas1{1}  = [DF.Input(1,:); DF.Input(1,:)];
     DF.Radius(1) = 0;
     DF.rn        = 1;
     DF.Obj       = 0;
     DF.MaxD      = 0;
     DF.Cobj      = [];
     ind1         = [1];
     rn0          = 1;

     if DF.DispMode == 1
        disp(' ');
        disp('    Data Information');
        disp(['    Samples:       ' int2str(DF.Nd)]);
        disp(['    Input(s):      ' int2str(DF.Ine)]);
        disp(['    Output(s);     ' int2str(DF.Oute)]);
        disp(' ');
        disp('    Parameter(s)');
        disp(['    Threshold:     ' num2str(DF.Dthr)]);
        if DF.EcmEpochs > 0
           disp(['    OptEpochs:     ' int2str(DF.EcmEpochs)]);
        end
        if DF.FuzzyType < 2
           disp(['    Rule-Type:     First-order TSK']);
        else
           disp(['    Rule-Type:     High-order TSK']);
        end
        disp(['    M-of-N:        ' num2str(DF.Mofn)]);
        disp(' ')
        disp('    Clusters      Samples         Time')
        disp(['        1             1            '...
              sprintf('%0.1f',cputime-DF.Time0)])
     end

     % create new nodes and update nodes
     for i = 2:DF.Nd
         [DF,ind1] = denfisf1_ec11(DF,ind1,i);

         if DF.rn > rn0
            rn0    = DF.rn;
            DF.Crn = [DF.Crn; i];
            if DF.DispMode == 1
               disp([sprintf('%9d',DF.rn)...
                     sprintf('%14d',i)...
                     sprintf('%15.1f',cputime-DF.Time0)]);
               drawnow
            end
         end

         DF.Cent = [];
         for j = 1:DF.rn
             DF.Cent(j,:) = DF.Clas1{j}(1,:);
         end

         if i == DF.Nd
            [DF.Obj, DF.MaxD] = denfisf1_ec14(DF);

            if DF.DispMode == 1
               disp([sprintf('%9d',DF.rn)...
                     sprintf('%14d',i)...
                     sprintf('%15.1f',cputime-DF.Time0)]);
               disp(' ');
               disp(['    ObjValue:      ' sprintf('%0.3f',DF.Obj)]);
               disp(['    MaxDistance:   ' sprintf('%0.3f',DF.MaxD)]);
            end
         end

     end                           % i = 2:nd

    if DF.EcmEpochs > 0
       if DF.DispMode == 1
          disp(' ');
          disp('    Optimising');
          disp(' ');
          disp('    Epochs   ObjValue     MaxD    Improvement     Time');
       end
       obj1               = DF.Obj;
       DF.Cobj(1)         = DF.Obj;
       DF.Radius(1:DF.rn) = DF.Dthr;

       for i = 1:DF.EcmEpochs
           [DF] = denfisf1_ec23(DF);
           DF.Cobj(i+1) = DF.Obj;
           DF.Imp       = obj1 - DF.Obj;

           if DF.DispMode == 1
              disp([sprintf('%8d',i)...
                   sprintf('%11.2f',DF.Obj)...
                   sprintf('%11.3f',DF.MaxD)...
                   sprintf('%13.4f',DF.Imp)...
                   sprintf('%12.1f',cputime-DF.Time0)]);
                   drawnow
           end

           if DF.Imp < DF.EcmImp
              break;
           end
           obj1 = DF.Obj;
        end     % for i = 1:epoch
    end        % if epoch > 0
    DF.Time0 = cputime - DF.Time0;
  warning on
  return;
%--------------------------------------------------------------------------------
%    function denfisf1_ec2 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%   subfunction denfisf1_ecf23
%--------------------------------------------------------------------------------
  function [DF] = denfisf1_ec23(DF)

     %global fundata
     DF.Obj  = 0;
     DF.MaxD = 0;

     for i = 1:DF.rn
         DF.Clas1{i} = [DF.Cent(i,:)];
     end
     for j = 1:DF.Nd
         for i = 1:DF.rn
             D(i,j) = norm(DF.Input(j,:) - DF.Clas1{i}(1,:)) / sqrt(DF.Ine);
         end
         [min0,ind0] = min(D(:,j));
         DF.Clas1{ind0} = [DF.Clas1{ind0}; DF.Input(j,:)];
     end

     OPTIONS = optimset('LargeScale', 'off', 'Display', 'off');
     lb = zeros(1,DF.Ine);
     ub = ones(1,DF.Ine);

     for i = 1:DF.rn
         [mn mn0] = size(DF.Clas1{i});
         D0       = zeros(mn,1);

         if mn > 1
            %fundata.mn0  = mn-1;
            %fundata.Md   = Md;
            %fundata.ine  = ine;
            %undata.data = clus{i}(2:mn,1:ine);

            fido = fopen('fundata.txt','w');
            fprintf(fido, ' %8.4f  %8.4f  %8.4f \n', mn-1,DF.Dthr,DF.Ine);
            for fi = 1:mn-1
                for fj = 1:DF.Ine
                    fprintf(fido, ' %8.4f',DF.Clas1{i}(fi+1,fj));
                end
                fprintf(fido, '\n');
            end
            fclose(fido);

            x0 = DF.Clas1{i}(1,:);
            x = fmincon('denfis_fun', x0, [], [], [], [], lb, ub,...
                        'denfis_con', OPTIONS);

            for j = 1:DF.Ine
                DF.Clas1{i}(1,j) = x(j);
                DF.Cent(i,j)     = x(j);
            end
            for j = 2:mn
                D0(j)  = norm(DF.Clas1{i}(1,:)-DF.Clas1{i}(j,:))/sqrt(DF.Ine);
                DF.Obj = DF.Obj + D0(j);
            end
            MaxD0 = max(D0);
            if MaxD0 > DF.MaxD
               DF.MaxD = MaxD0;
            end
         end         % mn > 1
     end             % i = 1:rn
     delete fundata.txt;

  return;
%--------------------------------------------------------------------------------
%   subfunction denfisf1_ec23.m
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    function denfisf1_cr2
%--------------------------------------------------------------------------------
  function   [DF] = denfisf1_cr2(DF);

     warning off
     if DF.DispMode == 1
        disp(' ');
        disp('    Rule Creating');
     end

     rcr = DF.Overlap;
     for i = 1:DF.rn
         f1   = 0;
         rcr0 = rcr;
         for j = 1:DF.Nd
             D(j) = norm(DF.Cent(i,:) - DF.Input(j,:))/sqrt(DF.Ine);
         end          % j = 1:nd

         while (f1 == 0)
               X  = [];
               Y  = [];
               for j = 1:DF.Nd
                   if D(j) <= rcr0
                      if DF.TrainMode == 2 & DF.FuzzyType == 2
                         X = [X; DF.Input(j,:)];
                      else
                         X = [X; 1 DF.Input(j,:)];
                      end
                      Y = [Y; DF.Teach(j,:)];
                   end
               end
               [Ne Ne0] = size(Y);

               if Ne < DF.MinNumSap
                  rcr0 = rcr0 * 1.05;
               else
                  f1 = 1;
               end
         end          % while (f1 == 0)

         if DF.TrainMode == 2 & DF.FuzzyType == 2
            DF.Net{i} = newff([zeros(DF.Ine,1) ones(DF.Ine,1)],...
                              [DF.NumNeuron 1],{'tansig' 'purelin'});
            DF.Net{i}.trainParam.epochs = DF.MLPEpochs;
            DF.Net{i}.trainParam.goal   = DF.MLPGoal;
            DF.Net{i}.trainParam.show   = Inf;
            DF.Net{i} = train(DF.Net{i},X',Y');
         else
            DF.Fun{i} = inv(X'*X) * X' * Y;
         end
     end              % i = 1:rn
     warning on
  return;
%--------------------------------------------------------------------------------
%    function denfisf1_cr2 end
%--------------------------------------------------------------------------------

%--------------------------------------------------------------------------------
%    function denfisf1_ev2
%--------------------------------------------------------------------------------
  function  [DF] = denfisf1_ev2(DF);

     for i = 1:DF.Nd
         EX = DF.Input(i,:);
         for j = 1:DF.rn
             D(j) = norm(EX - DF.Cent(j,:))/sqrt(DF.Ine);
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
             for k = 1:DF.Ine
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

         DF.Out(i)  = out1 * (DF.Maxt - DF.Mint) + DF.Mint;
         DF.Abe(i)  = DF.Out(i) - DF.OriTeach(i);
         DF.Rmse(i) = norm(DF.Abe(1:i))/sqrt(i);
         if i == 1
            DF.Ndei(1) = 0;
         else
            DF.Ndei(i) = DF.Rmse(i)./std(DF.OriTeach(1:i));
         end
         if i == 2
            DF.Ndei(1) = DF.Ndei(2);
         end
     end        % i = 1:nd
  return;
%--------------------------------------------------------------------------------
%    function denfisf1_ev2 end
%--------------------------------------------------------------------------------
