% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_prepare_raw_data XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :   used to read raw data files for all banks, and count total number of banks  in the raw data
% Syntax    :
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

% bank_data = readtable('/Users/htetnaing/Development/htet_mces_bank_data/emfis/data/raw_data/Tv2emd_001.xls','Range','H:AF');
% s1 = '/Users/htetnaing/Development/htet_mces_bank_data/emfis/data/raw_data/Tv2emd_001.xls'
% s2 =
% s = strcat(s1,s2,s3)
clc;
clear;
load Survived_Banks;
load Failed_Banks;

total_bank_count = 0;

% path_failed_bank = '/Users/htetnaing/Development/htet_mces_bank_data/emfis/data/failed_bank_raw_data.xls';
% failed_banks = readtable(path_failed_bank,'Range','H:I');
% failed_banks = failed_banks{:,:}
% tmp = [];
% [v,ic,id]=unique(failed_banks(:,1))
% for i=1:length(v)
%   A = failed_banks(id==i,:);
%   tmp = [tmp; {A}];
% end
% failed_bank_list = tmp;

for i = 1:126
    s1 = '/Users/htetnaing/Development/htet_mces_bank_data/emfis/data/raw_data/Tv2emd_';
    s2 = '';

    if i < 10
        s2 = '00';
    end

    if i >= 10 && i <= 99
        s2 = '0';
    end

    s3 = int2str(i);
    s4 = '.xls';

    path = strcat(s1,s2,s3,s4)
    bank_data = readtable(path,'Range','H:AF');
    bank_data = bank_data(:, [1 7 8 10:13 16 19 20 24]);

    input = bank_data{:,:}

    out1 = [];
    [v,ic,id]=unique(input(:,1))
    for i=1:length(v)
      A = input(id==i,:);
      out1 = [out1; {A}];
    end
    result = out1;
    total_bank_count = total_bank_count + length(result);
end
