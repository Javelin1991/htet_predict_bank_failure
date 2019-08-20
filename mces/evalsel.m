% Evaluative input selection method. Only concern with single output.
% Using SE to calculate the reinforcement for each changes.
% [returning weight vector of features] = evalsel(..
%   .. input matrix, output matrix, number of learning epoch, underlying model)
% function [weight] = evalsel(x,y,epoch,model,net)
function [weight] = evalsel(x,y,epoch,model)

tol = 0;    % Tolerance of difference
% epoch = 2;  % Number of epoch

% Get the total number of examples
edim = size(x,1);

% Get the dimension of input vector
idim = size(x,2);

% Initialize weight matrix
% Bounding weight with largest(SBP algo) and smallest, middle is our measure.
weight = zeros(idim, 3);

% Train the underlying induction model first.
net = train_model(x,y,model);

% Action arrays, store all possible actions and information
% Forward action, changing from 0->1 for a mask element.
% Reverse action, changing from 1->0 for a mask element, opposite of Forward.
% First dimension, idim.
% Second dimension, 1st is the total reinforcement for action
%                 , 2nd is total number of actions encountered
% Positive r for Reverse action = negative r for Forward action, vice-versa.
action = zeros(idim,2);

% Take the average value of each input features. As a point of virtually disabling.
average = mean(x);

for loop = 1:epoch    % number of iterations
    display('Processing...')
    for i = 1:edim  % For all examples
        % Get current input vector and output
        ip = x(i,:);
        op = y(i);

        % Generate a random original mask vector, m1 taking value {0,1}
        m1 = round(rand(1,idim));

        % Generate a random action to apply on mask.
        a = round(rand*idim);  % 1st dimension
        if a == 0
            a = idim;
        end

        % Determine forward or reverse action needed. Get modified mask, m2.
        m2 = m1;
        if m2(1,a) == 0
            b = 1;  % Forward action
            m2(1,a) = 1;
        else
            b = -1;  % Reverse action
            m2(1,a) = 0;
        end

        % Get input1 and input2.
        ip1 = ip.*m1;   % Input with original mask.
        ip2 = ip.*m2;   % Input with modified mask.
        % ip1 = ip;
        % ip2 = ip;
        for j = 1:idim
            if m1(1,j) == 0
                ip1(1,j) = average(1,j);
            end
            if m2(1,j) == 0
                ip2(1,j) = average(1,j);
            end
        end

        % Get actual output from the underlying model.
        y1 = test_model(net,ip1,model, i);
        y2 = test_model(net,ip2,model, i);

        % Get the mean square error of the actual output.
        % se1 = mmse(y1,y(i));
        % se2 = mmse(y2,y(i));

        % Derive reinforcement for the action based on MSE.
        % if (se2 < (se1 + tol)) % y2 is nearer than y1 to true solution, y
        %     r = mmse(y2,y1); %1;     % Get positive reinforcement
        % else
        %     r = -mmse(y1,y2); %-1;    % Get negative reinforcement
        % end

        % Derive reinforcement for the action based on Truth Error.
        if (abs(y2-y(i)) < (abs(y1-y(i))+ tol)) % y2 is nearer than y1 to true solution, y
            r = abs(y1-y2); %1;     % Get positive reinforcement
        else
            r = -abs(y2-y1); %-1;    % Get negative reinforcement
        end

        action(a,1) = action(a,1)+b*r;
        action(a,2) = action(a,2)+1;    % Number of action encountered
    end

    weight(:,2) = action(1:idim,1)./action(1:idim,2);
    display('Processing of one MCES iteration completed ')

end

display('Processing of MCES completed')

% display('Calculating smallest and largest bounds for weights...')
%
% % Calculating the largest bound (SBP) of weight for each feature.
% for i = 1:idim
%     m_x = x;
%     m_x(:,i) = average(i);
%     % weight(i,1) = mean(test_model(net,m_x,model)-test_model(net,x,model));
%     y1 = test_model(net,m_x,model,i);
%     y2 = test_model(net,x,model,i);
%
%     for j = 1:edim
%         if (abs(y2(j)-y(j)) < (abs(y1(j)-y(j))+ tol)) % y2 is nearer than y1 to true solution, y
%             r = abs(y1(j)-y2(j));     % Get positive reinforcement
%         else
%             r = -abs(y2(j)-y1(j));    % Get negative reinforcement
%         end
%
%         weight(i,1) = weight(i,1)+r;
%     end
%     weight(i,1) = weight(i,1)/edim;
% end
%
% % Calculating the smallest bound of weight for each feature.
% m_x = zeros(edim,idim);
% for i = 1:idim
%     m_x(:,i) = average(i);
% end
% nominal = test_model(net,m_x,model);
% for i = 1:idim
%     m_x(:,i) = x(:,i);
%     % weight(i,3) = mean(nominal-test_model(net,m_x,model));
%     y1 = nominal;
%     y2 = test_model(net,m_x,model,i);
%
%     for j = 1:edim
%         if (abs(y2(j)-y(j)) < (abs(y1(j)-y(j))+ tol)) % y2 is nearer than y1 to true solution, y
%             r = abs(y1(j)-y2(j));     % Get positive reinforcement
%         else
%             r = -abs(y2(j)-y1(j));    % Get negative reinforcement
%         end
%
%         weight(i,3) = weight(i,1)+r;
%     end
%     weight(i,3) = weight(i,1)/edim;
% end
%
% display('Calculating smallest and largest bounds for weights complted')
