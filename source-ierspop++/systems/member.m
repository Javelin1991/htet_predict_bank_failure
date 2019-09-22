function varargout = member(varargin)
% MEMBER v3.0 by Ang Kai Keng dated 8 Jan 2007
%   mfdata = member('train', algo, [inputs], {[outputs]}, {[params]})
%   generates the membership functions in mfdata using the algo specified 
%   with the params for a single dimension of input data and using optional 
%   output data labelled [1..c] for supervised algorithms.
%
%   mfdata = member('gen', algo, [inputs], {[outputs]}, {[params]})
%   generates the membership functions in mfdata using the algo specified 
%   with the params for all dimensions of input data and output data.
%
%   output = member('compute', mfdata, [inputs], p)
%   computes the membership functions output using mfdata specified on the
%   single dimension or pth dimension of the input data.
%
%   [mv,mcv] = member('compute', mfdata, [inputs], p)
%   computes the membership value and the class membership value using 
%   mfdata on the single dimension or pth dimension of the input data.
%
%   [mcr,{mco}] = member('compute', mfdata, [inputs])
%   computes the number of correct membership classification results and 
%   classification output using mfdata on the input data.
%
%   output = member('eval', mftype, [params], [inputs])
%   evaluates one membership function output using mftype specified with
%   params on the input data.
%
%   For algos:
%     lvq   - Learning Vector Quantization               (gauss2mf)
%             params: epsilon, labels, lambda, alpha, eta
%     clvq  - Cerebellar LVQ - prototype                 (gaussmf)
%             params: maxiter, epsilon, lambda, labels, beta, eta
%     spsec - Supervised Pseudo Self-Evolving Cerebellar (gauss2mf)
%             params: none
%     fkp   - Fuzzy Kohonen Partition                    (trapmf)
%             params: epsilon, labels, lambda, eta, alpha
%     sfkp  - Supervised Fuzzy Kohonen Partition         (trapmf)
%             params: epsilon, labels, lambda, eta, alpha
%     pfkp  - Pseudo Fuzzy Kohonen Partition             (trapmf)
%             params: epsilon, labels, lambda, eta
%     spfkp - Supervised Pseudo Fuzzy Kohonen Partition  (trapmf)
%             params: epsilon, labels, lambda, eta
%     dic   - Discrete Incremental Clustering            (trapmf)
%             params: slope, step, IT/OT
%     span  - Membership that spans min(x) to max(x)     (gaussmf)
%             params: labels, width
%     dspan - Membership that spans -max|x| to max|x|    (gaussmf)
%             params: labels, width
%
%   For mfdata:
%   mfdata is stored in the field .input and .output where it can be edited 
%   by MFEDIT or FUZZY.
%
%   For mftype:
%   Standard types of membership functions are supported: 
%   trimf, gbellmf, gaussmf, gauss2mf, sigmf, dsigmf, psigmf, pimf, smf, zmf.
%
%   See also POPFNN, MFEDIT, FUZZY, TRIMF, TRAPMF, GBELLMF, GAUSSMF, 
%   GAUSS2MF, SIGMF, DSIGMF, PSIGMF, PIMF, SMF, ZMF.

% MEX-File function.                                                     