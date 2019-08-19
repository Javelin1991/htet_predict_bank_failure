% % XXXXXXXXXXXXXXXXXXXXXXXXXXX sus_determine_new_mf_no XXXXXXXXXXXXXXXXXXXXX
% % 
% % Author    :   Susanti
% % Date      :   Aug 1 2014
% % Function  :   
% % Syntax    :   sus_determine_new_mf_no(data_struct, data_value)
% % 
% % Algorithm -
% % XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
% 
% function s15 = sus_determine_new_mf_no(data_struct, data_value)
% %disp('sus_determine_new_mf_no');
% 
%     %function D = mar_generate_mf3(data_struct, data_value, current_count, default_width, phase
%     num_mf = size(data_struct.mf, 2);
%     % determine placement of new MF (after left, becoming left + 1)
%     left = 0;
%     for i = 1 : num_mf
%         current_centroid = data_struct.mf(i).params(2);
%         if current_centroid < data_value
%             left = i;
%         else
%             break;
%         end
%     end
% 
%     % shift and rename MF structure (left + 1 is now a hole)
%     new_mf = left + 1;
% 
%     s15.new_mf_no = new_mf;
% end
