function r = corr2(varargin)
%CORR2 2-D correlation coefficient.
%   R = CORR2(A,B) computes the correlation coefficient between A
%   and B, where A and B are matrices or vectors of the same size.
%
%   Class Support
%   -------------
%   A and B can be numeric or logical. 
%   R is a scalar double.
%
%   Example
%   -------
%   I = imread('pout.tif');
%   J = medfilt2(I);
%   R = corr2(I,J)
%
%   See also CORRCOEF, STD2.

%   Copyright 1992-2010 The MathWorks, Inc.
%   $Revision: 5.18.4.11 $  $Date: 2011/08/09 17:49:25 $

[a,b] = ParseInputs(varargin{:});

a = a - mean2(a);
b = b - mean2(b);
r = sum(sum(a.*b))/sqrt(sum(sum(a.*a))*sum(sum(b.*b)));

%--------------------------------------------------------
function [A,B] = ParseInputs(varargin)

narginchk(2,2);

A = varargin{1};
B = varargin{2};

validateattributes(A, {'logical' 'numeric'}, {'real'}, mfilename, 'A', 1);
validateattributes(B, {'logical' 'numeric'}, {'real'}, mfilename, 'B', 2);

if any(size(A)~=size(B))
    error(message('images:corr2:notSameSize'))
end

if (~isa(A,'double'))
    A = double(A);
end

if (~isa(B,'double'))
    B = double(B);
end










