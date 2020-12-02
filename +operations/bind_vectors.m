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


function bound_vectors = bind_vectors(vsa,vectors_1, vectors_2, varargin)
% bind given vectors (vectors_1 bind vectors_2) --> it is possible to bind
% multiple vectors (column-wise in vectors_1 and vectors_2) - it is an
% vector-wise operation: m x n input vectors (m vectors with dimension n)
% produce an m x n output 
%
% INPUT:
%      vsa:            vsa type
%      vectors_1:      first vectors to bound (vector array)
%      vectors_2:      second vectors to bound (vector array)
%    optional:
%      density:        density of ones in a vector (important for binary
%                      sparse vectors)
% OUTPUT:
%      bound_vectors:  bound vectors 1 and 2
%
% scken, 2020

default_density=1/sqrt(size(vectors_1,1));  % density computing is optained from rachkovskji (most capacity and good stability)
default_M = 0; % basic matrix for MBAT VSA

p=inputParser;

addParameter(p,'M',default_M);
addParameter(p,'density',default_density);

parse(p,varargin{:});

density = p.Results.density;
M = p.Results.M;

% assert(sum(size(vectors_1)==size(vectors_2))==2,'Size of vector-arrays 1 and 2 has to be the same!');

switch vsa
    case {'MAP_B','MAP_C','MAP_I'}
        % elementwise multiplication
        bound_vectors = vectors_1.*vectors_2;
    case {'BSC'}
        % efficient xor implementation for multi inputs
        bound_vectors=double(bsxfun(@plus,vectors_1,vectors_2)==1);
    case {'BSDC'}
        % disjunction of given vectors
        values_disj=double(bsxfun(@plus,vectors_1,vectors_2));

        % CDT
        Z=operations.cdt(values_disj,50,1/sqrt(size(vectors_1,1)));
        bound_vectors = Z;
    case {'BSDC_SHIFT','BSDC_25','BSDC_THIN'}
        % calculate the shift number (sum of all ones-index)
        idx = [1:size(vectors_1,1)]*vectors_1;
        % shift each column with specific index number                             
        bound_vectors = zeros(size(vectors_1));
        for i=1:numel(idx)
            bound_vectors(:,i) = circshift(vectors_2(:,i),idx(i));            
        end
    case {'HRR',}
        % circular convolution 
        ccirc = ifft(fft(vectors_1,size(vectors_1,1),1).*fft(vectors_2,size(vectors_2,1),1));
        bound_vectors=ccirc;
    case 'HRR_VTB'
        % vector-derived transformation binding
        val_x=vectors_1;
        val_y=vectors_2;
        num_vecs = size(vectors_1,2);
        dim  = size(vectors_1,1);
        sub_d=round(sqrt(dim));
        
        % check whether vector size has an even root
        assert(size(val_x,1)==sub_d^2,"In VTB: The number of dimensions must have an even root.");
        
        bound_vectors = zeros(size(vectors_1));
        V_x = M;
        
        for i=1:num_vecs
            V_x_1 = reshape(val_x(:,i),[sub_d, sub_d]);    
            for j=1:sub_d
                V_x((j-1)*sub_d+1:j*sub_d,(j-1)*sub_d+1:j*sub_d) = V_x_1;
            end
            bound_vectors(:,i) = sqrt(sub_d)*(V_x*val_y(:,i));
        end
    case {'FHRR','FHRR_fft'}
        % elementwise complex multiplication 
        bound_vectors = wrapToPi(bsxfun(@plus,vectors_1,vectors_2));
    case 'FHRR_full'
         % convolution --> multiplicatioin
         complex_product=vectors_1.*vectors_2;
         bound_vectors=complex_product;
    case 'BSDC_SEG'
        % sparse vectors with segements   
        dim = size(vectors_1,1);
        num_segments = floor(dim*density);
        size_segments = floor(dim/num_segments);
        num_vecs = size(vectors_1,2);
        role = vectors_1(1:num_segments*size_segments,:);
        filler = vectors_2(1:num_segments*size_segments,:);
       
        % first part of the vector 
        role_segments = reshape(role,[size_segments, num_segments, num_vecs]);
        filler_segments = reshape(filler,[size_segments, num_segments, num_vecs]);
        role_idx = find(role_segments);
        filler_idx = find(filler_segments);
        
        [role_rows, ~, ~] = ind2sub(size(role_segments),role_idx);
        [filler_rows, filler_cols, filler_tables] = ind2sub(size(filler_segments),filler_idx);

        result_rows = mod(role_rows(filler_cols.*filler_tables) + filler_rows -1, size_segments)+1;
        bound_vectors = zeros(size(role_segments));
        
        idx = sub2ind(size(role_segments), result_rows, filler_cols, filler_tables);
        bound_vectors(idx) = 1;
        bound_vectors = reshape(bound_vectors,[size_segments*num_segments, num_vecs]);

        % if there is a remain part
        bound_vectors_part2 = [];
        if num_segments*size_segments ~= dim
            filler = vectors_2(num_segments*size_segments+1:end,:);
            bound_vectors_part2 = filler;
        end
        
        bound_vectors = [bound_vectors; bound_vectors_part2];
    case 'MBAT'
        % matrix multiplication
        % basically from Gallant and [1] M. D. Tissera and M. D. McDonnell, “Enabling ‘question answering’ in the MBAT vector symbolic architecture by exploiting orthogonal random matrices,” Proc. - 2014 IEEE Int. Conf. Semant. Comput. ICSC 2014, pp. 171–174, 2014.
        num_vecs = size(vectors_1,2);
        bound_vectors = zeros(size(vectors_1));
        
        for i=1:num_vecs
            role = vectors_1(:,i);
            filler = vectors_2(:,i);
            % generate specific order for the M matrix
            idx = (1:numel(role))*(role>0);
            M_ = circshift(M,[idx floor(idx/2)]);
%             M_ = M^idx;
                       
            bound_vectors(:,i) = M_*filler;
        end
                
     otherwise
         disp('Representation is not defined!')

 end

end