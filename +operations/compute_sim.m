function [sim_matrix] = compute_sim(vsa,vectors_1,vectors_2)
% compute similarity between vector array 1 and 2
% INPUT:  
%     vectors_1  - vector array 1 (column wise)
%     vectors_2  - vector array 2 (column wise)
% OUTPUT:
%     sim_matrix:- similarity array (or value if both are single
%                  vectors)
%
% scken, 2020

    % first transpose the arrays 
    vectors_1 = vectors_1';
    vectors_2 = vectors_2';

    sim_matrix = zeros([size(vectors_1,1) size(vectors_2,1)]);

    switch vsa 
      case {'MAP_B','MAP_C','HRR','HRR_VTB','NONE','MAP_I','MBAT','Proj'}
          % cosine similarity 
          sim_matrix = 1-pdist2(vectors_1,vectors_2,'cosine');          
      case 'BSC'
          % hamming distance
          sim_matrix = 1-pdist2(vectors_1,vectors_2,'hamming')*2;
      case {'BSDC','BSDC_SHIFT','BSDC_25', 'BSDC_SEG','BSDC_THIN'}
          % overlap (normalized by hamming weight)
%           density = round(mean([sum(vectors_1,2); sum(vectors_2,2)]));
          vectors_1 = vectors_1>0;
          vectors_2 = vectors_2>0;
          sim_matrix = vectors_1*vectors_2';
%           sim_matrix = sim_matrix./density;
      case {'FHRR','FHRR_fft'}
          % average of cosine of distance

          % convert to complex values
          v1_c = exp(vectors_1*1i);
          v2_c = exp(-vectors_2*1i);

          sim_matrix = real(conj(v1_c)*v2_c')/size(vectors_1,2);
      otherwise
          disp('Representation is not defined!')
    end

end
