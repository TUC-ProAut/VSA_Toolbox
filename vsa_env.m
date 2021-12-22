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


%% MATLAB class of different VSA implementation 


classdef vsa_env < handle

    properties
        dim        % number of dimensions
        vsa        % type of representation
        item_mem   % vectors in item memory (cell array--> first cell contains the matrix with column-wise vectors; second cell contains the names of the vectors)
        density    % density of the vetors (important for binary vectors)
        max_density% maximum density (important for thinng after bundling)
        M          % the basic M matrix (for MBAT vsa, all other VSAs do not use this property)
    end
    
    methods
        function obj = vsa_env(varargin)
         
            default_vsa         = 'MAP_B';
            default_dim         = 10000;
            default_density     = -1; % if -1, default density will be computed later
            default_max_density = 1;
         
            p=inputParser;

            addParameter(p,'vsa',default_vsa,@ischar);
            addParameter(p,'dim',default_dim);
            addParameter(p,'density',default_density);
            addParameter(p,'max_density',default_max_density);

            parse(p,varargin{:});

            % check if vsa is defined
            availabel_VSAs = {'MAP_C'; 'MAP_B'; 'MAP_I'; 'BSC'; 'BSDC'; 'BSDC_SHIFT'; 'HRR'; 'HRR_VTB'; 'FHRR'; 'BSDC_SEG';'MBAT'};
            assert(any(strcmp(availabel_VSAs,p.Results.vsa)),['The selected VSA is not defined. Please chose one out of ' cell2mat(join(availabel_VSAs))]);
            
            obj.dim = p.Results.dim;
            obj.vsa = p.Results.vsa;
            obj.item_mem = cell([1 2]); 
            obj.item_mem{1,2} = {};
            obj.max_density = p.Results.max_density;
            
            % define default density
            if p.Results.density == -1
                switch p.Results.vsa
                     case {'BSDC', 'BSDC_SHIFT'}
                         density=1/sqrt(obj.dim);  % density computing is optains from rachkovskji (most capacity and good stability)
                     case 'BSDC_25'
                         density=0.25;
                     case 'BSDC_SEG'
%                          density=0.05; % mean sparsity value of [1] M. Laiho, J. H. Poikonen, P. Kanerva, and E. Lehtonen, “High-dimensional computing with sparse vectors,” IEEE Biomed. Circuits Syst. Conf. Eng. Heal. Minds Able Bodies, BioCAS 2015 - Proc., pp. 1–4, 2015.
                         density=1/sqrt(obj.dim); % show better results 
                     otherwise
                         density=0.5;
                end
                obj.density = density;  
            else 
                obj.density = p.Results.density;
            end
            
            % create the basic M matrix for the MBAT VSA
            if strcmp(obj.vsa,'MBAT')
                obj.M = rand([obj.dim obj.dim]);
                obj.M = orth(obj.M);
            end
            
            % preallocate a matrix of zeros for the HRR_VTB matrix (otherwise it
            % takes a long time while binding)
            if strcmp(obj.vsa,'HRR_VTB')
                obj.M = zeros([obj.dim obj.dim]);
            end
            
        end
      
        function vectors = add_vector(obj, varargin)
        % add vector to item memory
        % INPUT (optinal):  
        %     vec       - predefined hypervectors (column-wise)
        %     num       - number of to defined vectors (if no predefined
        %                 vectors are given)
        %     name      - name [string], if nothing --> random name
        %     add_item  - [bool] true, if vectors should be added to the item
        %               memory
        % OUTPUT:
        %     vec_out:  - generated hypervectors
          
            default_name     = -1;
            default_num      = 1;
            default_vec      = 0;
            default_add_item = 1;
            default_return   = 1;
            p=inputParser;

            addOptional(p, 'vec', default_vec)
            addOptional(p, 'name', default_name)
            addOptional(p, 'num', default_num)
            addOptional(p, 'add_item', default_add_item)
            addOptional(p, 'return_vector', default_return)

            parse(p,varargin{:});

            num = p.Results.num;
            
            
            if p.Results.vec==0 
                % no input vectors given, generate radom vectors
                vectors = operations.generate_vectors('vsa',obj.vsa,'dim',obj.dim,'num',num, 'density',obj.density);  
            else
                vectors = p.Results.vec;
                num = size(vectors,2);
            end
            
            if p.Results.add_item
                obj.item_mem{1,1}=[obj.item_mem{1,1} vectors];

                % generate names (if not given)
                if isnumeric(p.Results.name) % if name is -1, then generate random name
                    names = obj.item_mem{1,2};
                    rand_names = cellstr(obj.rnd_name('size',[8,num]));
                    obj.item_mem{1,2} = cat(1,[rand_names(:); cellstr(names)]);             
                else
                    names = obj.item_mem{1,2};
                    obj.item_mem{1,2} = cat(1,[names(:); cellstr(p.Results.name)]);           
                end
            end
            
            % return vectors only if param is set
            if p.Results.return_vector == 0
                clear vectors;
            end
        end
      
        function [sim_matrix] = sim(obj,vectors_1,vectors_2)
            % compute the similarty between two vectors (arrays)
            sim_matrix = operations.compute_sim(obj.vsa, vectors_1, vectors_2);
        end
        
        function bound_vectors = bind(obj, vectors_1, vectors_2)
            % bind vectors_1 and vectors_2 --> see function bind_vectors.m
            bound_vectors = operations.bind_vectors(obj.vsa, vectors_1, vectors_2, 'density',obj.density, 'M', obj.M);
        end
              
        function unbound_vectors = unbind(obj, vectors_1, vectors_2)
            % unbind vectors_1 and vectors_2 --> see function unbind_vectors.m
            unbound_vectors = operations.unbind_vectors(obj.vsa, vectors_1, vectors_2, 'density', obj.density, 'M', obj.M);
        end
        
        function bundled_vectors = bundle(obj, vectors_1, vectors_2, normalize)
            % bundle vectors_1 and vectors_2 --> see function bundle_vectors.m
            if nargin <= 3
                bundled_vectors = operations.bundle_vectors(obj.vsa, vectors_1, vectors_2, 'density', obj.density, 'max_density', obj.max_density);
            else
                bundled_vectors = operations.bundle_vectors(obj.vsa, vectors_1, vectors_2, 'normalize',normalize, 'density', obj.density, 'max_density', obj.max_density);
            end
        end
        
        function permuted_vector = permute(obj, vector, p)
            % permute input vetor
            if nargin<=2
                p=1;
            end
            
            permuted_vector = circshift(vector,p);
        end
        
        function [vectors, names, s]=find_k_nearest(obj, vectors_in, k)
        %  find the k best matches in item memory with input vector
        % INPUT:
        %      vectors_in:      input vectors (can be more than one)
        %      k:               k nearest neighbors (default = 1)
        % OUTPUT: 
        %      name:            name of matched vectors (cell array)
        %      s:               similarity of best match (array)
            if nargin<=2
                k=1;
            end
            sim_vec = obj.sim(obj.item_mem{1,1},vectors_in);
            [sim_vec_sort, idx]=sort(sim_vec,'descend'); 
            s_highest=sim_vec_sort(1:k,:);

            rows = idx(1:k,:);
            
            names = obj.item_mem{1,2};
            names = names(rows,:);
            names = reshape(names,[k,size(vectors_in,2)]);
            vecs  = obj.item_mem{1,1};  
            vectors = vecs(:,rows);
            vectors = reshape(vectors,[size(vectors,1),k,size(vectors_in,2)]);
            s     = sim_vec(rows);
            s = reshape(s,[k,size(vectors_in,2)]);
            
            
        end

        function [vector] = find_by_name(obj, vector_name)
        %  find the vector by name
        % INPUT:
        %      vector_name:     vector name
        % OUTPUT: 
        %      vecotr:          vector with name 'vector_name'
            
            idx = strcmp(obj.item_mem{2},vector_name);
            if sum(idx)>=1
                vector = obj.item_mem{1}(:,idx);
            else
                disp(['No vector for name ' vector_name ' found!']);
                vector = [];
            end
        end
        
        function v = frac_binding(obj, vector, k)
        % FRAC_BINDING  BETA - currently not in use
            v = operations.fractional_binding(obj.vsa, vector, k);
        end
        
        function converted_vectors = convert(obj, vector_array)
        %  convert the input into the specific range of the
        %  corresponding vsa type
        % INPUT:
        %      vector_array:      vectors (each row is a vector)
        % OUTPUT: 
        %      converted_vectors: converted vectors 
            
            converted_vectors = operations.convert_vectors(obj.vsa, vector_array, obj.density);
        end
        
    end
    
    methods (Static, Access = public)
        function name = rnd_name(varargin)        
        %  generate random names 
        % INPUT:
        %      size:    vector with number of characters per name and
        %               number of random names
        % OUTPUT: 
        %      name:     random names as char-array


            default_size = [8,1];

            p=inputParser;

            addOptional(p, 'size', default_size)


            parse(p,varargin{:})

            % if no name defined, create a random name
            s = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
            rnd_idx=randi(numel(s), [p.Results.size(2) p.Results.size(1)]);
            s=s(rnd_idx);
            %find number of random characters to choose from
            numRands = length(s); 

            %specify length of random string to generate
            sLength = p.Results.size(1);

            %generate random string
            name = s( ceil(rand(p.Results.size(2),sLength)*numRands) ); 
        end
    end
end

   

   