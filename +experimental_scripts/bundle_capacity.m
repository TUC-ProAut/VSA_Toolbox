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



%% bundle capacity experiment
% refered to the paper "A comparison of Vector Symbolic Architectures"
% the bundle capacity experiment provides the data for Figure 2
% default parameters are used in the original paper
%
% scken, 2020


% params
item_memory_size=1000;
k_range=3:2:51;
dim_range_cap=[2:2:40].^2;

prob_correct_tensor=zeros([numel(dim_range_cap),numel(k_range),number_iterations]); % init tensor for saving the results

%% experimental capacity 
for it=1:number_iterations
    prob_correct_array=[];        

    disp(['iteration: ' num2str(it)])
 
    % iterate over dimension
    for d_idx=1:numel(dim_range_cap)
          
        % fill data base (item memory)
        VSA=vsa_env('vsa',vsa_dict{i,1},'dim',dim_range_cap(d_idx));
        VSA.add_vector('num',item_memory_size);

        prob_correct_answer=zeros([1 numel(k_range)]);
        
        % calculate the complete range of k 
        item_names = VSA.item_mem{1,2};
        parfor k_idx=1:numel(k_range)
            k=k_range(k_idx);
            bundle_names=datasample(item_names,k,'Replace',false);
            
            % sample the k vectors out of the item memory
            idx = find(ismember(item_names,bundle_names));
            
            bundle_vectors = VSA.item_mem{1,1}(:,idx);

            % one-step bundling:
            bundle=VSA.bundle(bundle_vectors,[]);

            % find the k nearest vectors to bundle 
            [vec, names, sim]=VSA.find_k_nearest(bundle,k);

            % check if the k similarest vectors are correct
            num_correct=numel(find(ismember(names,bundle_names)));

            prob_correct_answer(k_idx)=num_correct/k;
        end

        prob_correct_array=[prob_correct_array; prob_correct_answer];

    end

    % concat each iteration to one tensor
    prob_correct_tensor(:,:,it)= prob_correct_array;

end

% compute mean and variance    
results_capacity_mean{i}=[results_capacity_mean{i}; mean(prob_correct_tensor,3)];
results_capacity_var{i}=[results_capacity_var{i}; var(prob_correct_tensor,1,3)];
