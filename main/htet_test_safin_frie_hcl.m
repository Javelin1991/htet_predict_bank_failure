% XXXXXXXXXXXXXXXXXXXXXXXXXXXX htet_test_safin_frie_hcl XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
%
% Author    :   Htet
% Date      :   Sep 11, 2019
% Function  :
% Stars     :
% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

function out = htet_test_safin_frie_hcl(TestData, net, net_2)

  IND = size(TestData,2)-1;
  OUTD = 1;

  for i = 1 : size(TestData,1)
      isHcl = true;
      net_out(i,:) = SaFIN_FRIE_test(TestData(i, 1:IND),IND,OUTD,net.no_InTerms,net.InTerms,net.no_OutTerms,net.OutTerms,net.Rules, isHcl);
      net_out_2(i,:) = SaFIN_FRIE_test(TestData(i, 1:IND),IND,OUTD,net_2.no_InTerms,net_2.InTerms,net_2.no_OutTerms,net_2.OutTerms,net_2.Rules, isHcl);

      if (net_out(i,:) >= net_out_2(i,:))
        out(i,:) = 1;
      else
        out(i,:) = 0;
      end
  end
end
