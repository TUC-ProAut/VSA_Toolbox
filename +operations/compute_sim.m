%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of VSA_Toolbox.                                       %
%                                                                         %
% Copyright (C) 2020 Chair of Automation Technology / TU Chemnitz         %
% For more information see https://www.tu-chemnitz.de/etit/proaut/vsa     %
%                                                                         %
% VSA_Toolbox is free software: you can redistribute it and/or modify     %
% it under the terms of the GNU General Public License as published by    %
% the Free Software Foundation, either version 3 of the License, or       %
% (at your option) any later version.                                     %
%                                                                         %
% VSA_Toolbox is distributed in the hope that it will be useful,          %
% but WITHOUT ANY WARRANTY; without even the implied warranty of          %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           %
% GNU General Public License for more details.                            %
%                                                                         %
% You should have received a copy of the GNU General Public License       %
% along with Foobar.  If not, see <http://www.gnu.org/licenses/>.         %
%                                                                         %
% Author: Kenny Schlegel (kenny.schlegel@etit.tu-chemnitz.de)             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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

    warning('off')
    switch vsa 
      case {'MAP_B','MAP_C','HRR','HRR_VTB','NONE','MAP_I','MBAT','Proj','FHRR_cos'}
          % cosine similarity 
          sim_matrix = (vectors_1./sqrt(sum(vectors_1.^2,2)))*(vectors_2./sqrt(sum(vectors_2.^2,2)))';
      case 'BSC'
          % hamming distance
          sim_matrix = 1-pdist2(vectors_1,vectors_2,'hamming');
      case {'BSDC','BSDC_SHIFT','BSDC_25', 'BSDC_SEG','BSDC_THIN'}
          % overlap 
          vectors_1 = vectors_1>0;
          vectors_2 = vectors_2>0;
          sim_matrix = vectors_1*vectors_2';
      case {'FHRR_fft','FHRR'}
          % average of cosine of distance

          % convert to complex values
          sim_matrix = real(exp(vectors_1*1i)*exp(vectors_2*1i)')/size(vectors_1,2);
      otherwise
          disp('Representation is not defined!')
    end

    warning('on')

end
