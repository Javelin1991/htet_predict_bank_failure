% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_concat_denfis_recon_data_with_years XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Stars     :   *
% purpose   :   to populate corresponding years in reconstructed data
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
clear;
clc;

load Survived_Banks;
load Failed_Banks;
load Reconstructed_Data_denfis;

Survived_Banks(any(isnan(Survived_Banks), 2), :) = [];
Failed_Banks(any(isnan(Failed_Banks), 2), :) = [];

SB = [];
FB = [];
Recon_FB = RECONSTRUCTED_DATA{1, 1};
Recon_SB = RECONSTRUCTED_DATA{2, 1};

[v,ic,id]=unique(Survived_Banks(:,1))
for i=1:length(v)
  A = Survived_Banks(id==i,:); SB = [SB; {A}];
end

clear A; clear v; clear ic; clear id;

[v,ic,id]=unique(Failed_Banks(:,1))
for i=1:length(v)
  A = Failed_Banks(id==i,:); FB = [FB; {A}];
end

DENFIS_FB = [];
DENFIS_SB = [];

for i=1:size(Recon_FB,1)
  A = cell2mat(Recon_FB(i));
  B = cell2mat(FB(i));
  last_col = B(:,size(B,2));
  DENFIS_FB = [DENFIS_FB; [A last_col]];
end

clear A; clear B;

for i=1:size(Recon_SB,1)
  A = cell2mat(Recon_SB(i));
  B = cell2mat(SB(i));
  last_col = B(:,size(B,2));
  DENFIS_SB = [DENFIS_SB; [A last_col]];
end
