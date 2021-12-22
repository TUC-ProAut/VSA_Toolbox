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


function unbound_vectors = unbind_vectors(vsa,vectors_1, vectors_2, varargin)
% unbind given vectors (vectors_1 unbind vectors_2) --> it is possible to unbind
% multiple vectors (column-wise in vectors_1 and vectors_2) - it is an
% vector-wise operation: m x n input vectors (m vectors with dimension n)
% produce an m x n output 
%
% INPUT:
%      vsa:             vsa type
%      vectors_1:       first vectors to unbound 
%      vectors_2:       second vectors to unbound
%    optional:
%      density:        density of ones in a vector (important for binary
%                      sparse vectors)
% OUTPUT:
%      unbound_vectors: bound vectors 1 and 2
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


switch vsa
    case {'MAP_B','MAP_C','MAP_I'}
        % elementwise multiplication
        unbound_vectors = vectors_1.*vectors_2;
    case {'BSC'}
        % efficient xor implementation for multi inputs
        unbound_vectors = double(bsxfun(@plus,vectors_1,vectors_2)==1);
    case {'BSDC'}
        % find the most similar item in item_mem  
        disp('There is no specific unbind operator for the selected VSA - use the finding of the most similar vectors in item memory instead!');
    case {'BSDC_SHIFT'}
        % calculate the shift number (sum of all ones-index)
        idx = [1:size(vectors_1,1)]*vectors_1;
        % shift each column with specific index number
        unbound_vectors = zeros(size(vectors_1));
        for i=1:numel(idx)
            unbound_vectors(:,i) = circshift(vectors_2(:,i),-idx(i));            
        end
    case {'HRR',}
        % involution as approximate inverse
        inverse=[vectors_1(1,:); flip(vectors_1(2:end,:))];
        unbound_vectors = ifft(fft(inverse,size(vectors_1,1),1).*fft(vectors_2,size(vectors_2,1),1));
    case 'HRR_VTB'
        val_x = vectors_1;
        val_y = vectors_2;
        dim  = size(vectors_1,1);
        sub_d = round(sqrt(dim));
        assert(size(val_x,1)==sub_d^2,"In VTB: The number of dimensions must have an even root.");
        num_vecs = size(vectors_1,2);
        
        unbound_vectors = zeros(size(vectors_1));
        V_x = M;
        
        for i=1:num_vecs
            % transpose the y vector
            V_x_1 = reshape(val_x(:,i),[sub_d, sub_d])';
            
            for j=1:sub_d
                V_x((j-1)*sub_d+1:j*sub_d,(j-1)*sub_d+1:j*sub_d) = V_x_1;
            end
            unbound_vectors(:,i) = sqrt(sub_d)*V_x*val_y(:,i);
        end
    case {'FHRR'}
        % complex multiplication with negative 'role' vector
        unbound_vectors = wrapToPi(bsxfun(@minus,vectors_2,vectors_1));
    case 'BSDC_SEG'
        % sparse vectors with segements
         
        dim = size(vectors_1,1);
        num_segments = floor(dim*density);
        num_vecs = size(vectors_1,2);
        size_segments = floor(dim/num_segments);
        role = vectors_1(1:num_segments*size_segments,:);
        filler = vectors_2(1:num_segments*size_segments,:);
                            
        % first part of the vector 
        role_segments = reshape(role,[size_segments, num_segments, num_vecs]);
        filler_segments = reshape(filler,[size_segments, num_segments, num_vecs]);
        role_idx = find(role_segments);
        filler_idx = find(filler_segments);
        
        [role_rows, role_cols, role_tables] = ind2sub(size(role_segments),role_idx);
        [filler_rows, filler_cols, filler_tables] = ind2sub(size(filler_segments),filler_idx);

        result_rows = mod(filler_rows - role_rows(filler_cols.*filler_tables) -1, size_segments)+1;
        unbound_vectors = zeros(size(role_segments));
        
        idx = sub2ind(size(role_segments), result_rows, filler_cols, filler_tables);
        unbound_vectors(idx) = 1;
        unbound_vectors = reshape(unbound_vectors,[size_segments*num_segments, num_vecs]);

        % if there is a remain part
        unbound_vectors_part2 = [];
        if num_segments*size_segments ~= dim
            filler = vectors_2(num_segments*size_segments+1:end,:);
            unbound_vectors_part2 = filler;
        end
        
        unbound_vectors = [unbound_vectors; unbound_vectors_part2];
    case 'MBAT'
        % matrix multiplication
        num_vecs = size(vectors_1,2);
        unbound_vectors = zeros(size(vectors_1));
        
        for i=1:num_vecs
            role = vectors_1(:,i);
            filler = vectors_2(:,i);
            % generate specific order for the M matrix
            idx = (1:numel(role))*(role>0);
            M_ = circshift(M,[idx floor(idx/2)])';
%             M = (M^idx)';
                      
            unbound_vectors(:,i) = M_*filler;
        end      
        
    otherwise
        disp('Representation is not defined!')
end

end