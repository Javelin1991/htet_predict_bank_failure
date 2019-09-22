function varargout = popfnn(varargin)
% POPFNN v3.0 by Ang Kai Keng dated 8 Jan 2007
%   [ outFIS O {CO} ] = popfnn('train', algo, inFIS, [Inputs], [Output])
%   identifies the fuzzy rules in outFIS using the algo specified and the
%   membership functions in inFIS. Generates the training output in O and
%   optional consequence output in CO. 
%
%   [ O {CO} ] = popfnn('compute', inFIS, [Inputs])
%   computes the output in O using inFIS and the optional consequence 
%   output in CO from the input data.
%
%   For algos:
%     pop     - Pseudo Output-Product
%     rspop   - Rough Set-based Pseudo Outer-Product
%     reduce1 - RSPOP Attribute Reduction
%     reduce2 - RSPOP Rule Reduction
%     reduce3 - RSPOP Outlier Rule Reduction
%
%   [ outFIS O CO {SA} ] = popfnn('train', 'reduce1', inFIS, [Inputs], [Output])
%   performs attribute reduction and generates the optional Selected 
%   Atttribute SA array.
%
%   For inFIS:
%   Membership functions are generated using MEMBER function.
%
%   For outFIS:
%   Fuzzy rules are stored in the field .rule where it can be edited by
%   RULEEDIT or FUZZY.
%
%   See also MEMBER, RULEEDIT, FUZZY, TRIMF, TRAPMF, GBELLMF, GAUSSMF, 
%   GAUSS2MF, SIGMF, DSIGMF, PSIGMF, PIMF, SMF, ZMF.

% MEX-File function.                                                     