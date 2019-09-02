function rsi = rsindex(closep, nperiods)
%RSINDEX Relative Strength Index (RSI).
%   RSINDEX calculates the Relative Strength Index (RSI). The RSI is calculated
%   based on a default 14-period period.
%
%   RSI = rsindex(CLOSEP)
%   RSI = rsindex(CLOSEP, NPERIODS)
%
%   Optional Inputs: NPERIODS
%
%   Inputs:
%     CLOSEP - Nx1 vector of closing prices.
%
%   Optional Inputs:
%   NPERIODS - Scalar value of the number of periods. The default is period
%   is 14.
%
%   Outputs:
%        RSI - Nx1 vector of the relative strength index
%
%   Note: The RS factor is calculated by dividing the average of the gains by
%   the average of the losses within a specified period.
%
%     RS = (average gains) / (average losses)
%
%   Also, the first value of RSI, RSI(1), is a NaN in order to preserve the
%   dimensions of CLOSEP.
%
%   Example:
%      load disney.mat
%      dis_RSI = rsindex(dis_CLOSE);
%      plot(dis_RSI);
%
%   See also NEGVOLIDX, POSVOLIDX.

%   Reference: Murphy, John J., Technical Analysis of the Futures Market,
%              New York Institute of Finance, 1986, pp. 295-302

%   Copyright 1995-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $   $Date: 2012/08/21 00:14:32 $

% Check input arguments.
switch nargin
    case 1
        nperiods = 14;

    case 2
        if numel(nperiods) ~= 1 || mod(nperiods, 1) ~= 0
            error(message('finance:ftseries:rsindex:NPERIODSMustBeScalar'));

        elseif nperiods > length(closep)
            error(message('finance:ftseries:rsindex:NPERIODSTooLarge1'));
        end

    otherwise
        error(message('finance:ftseries:rsindex:InvalidNumberOfInputArguments'));
end

% Check to make sure closep is a column vector
if size(closep, 2) ~= 1
    error(message('finance:ftseries:rsindex:ClosepMustBeColumnVect'));
end

% Check for data sufficiency.
if length(closep) < nperiods
    error(message('finance:ftseries:rsindex:NPERIODSTooLarge2'));
end

% Calculate the Relative Strength index (RSI).
if (nperiods > 0) && (nperiods ~= 0)
    % Determine how many nans are in the beginning
    nanVals = isnan(closep);
    firstVal = find(nanVals == 0, 1, 'first');
    numLeadNans = firstVal - 1;

    % Create vector of non-nan closing prices
    nnanclosep = closep(~isnan(closep));

    % Take a diff of the non-nan closing prices
    diffdata = diff(nnanclosep);
    priceChange = abs(diffdata);

    % Create '+' Delta vectors and '-' Delta vectors
    advances = priceChange;
    declines = priceChange;

    advances(diffdata < 0) = 0;
    declines(diffdata >= 0) = 0;

    % Calculate the RSI of the non-nan closing prices. Ignore first non-nan
    % closep b/c it is a reference point. Take into account any leading nans
    % that may exist in closep vector.
    trsi = nan(size(diffdata, 1)-numLeadNans, 1);
    for didx = nperiods:size(diffdata, 1)
        % Gains/losses
        totalGain = sum(advances((didx - (nperiods-1)):didx));
        totalLoss = sum(declines((didx - (nperiods-1)):didx));

        % Calculate RSI
        rs         = totalGain ./ totalLoss;
        trsi(didx) = 100 - (100 / (1+rs));
    end

    % Pre allocate vector taking into account reference value and leading nans.
    % length of vector = length(closep) - # of reference values - # of leading nans
    rsi = nan(size(closep, 1)-1-numLeadNans, 1);

    % Populate rsi
    rsi(~isnan(closep(2+numLeadNans:end))) = trsi;

    % Add leading nans
    rsi = [nan(numLeadNans+1, 1); rsi];

elseif nperiods < 0
    error(message('finance:ftseries:rsindex:NPERIODSMustBePosScalar'));

else
    rsi = closep;
end


% [EOF]
