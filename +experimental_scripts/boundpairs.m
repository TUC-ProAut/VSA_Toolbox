%% bound pairs and retrive them
% refered to the paper "A comparison of Vector Symbolic Architectures"
% the bound pairs capacity experiment computes the results of bundling
% bound pairs (base for table 2)
% default parameters are used in the original paper
%
% scken, 2020


% params
item_memory_size=1000;
k_range=3:2:51;
dim_range_pairs=[2:2:40].^2;

% init empty result tensor 
prob_correct_tensor=zeros([numel(dim_range_pairs),numel(k_range),number_iterations]);


for it=1:number_iterations
    prob_correct_array=[];        

    disp(['iteration: ' num2str(it)])

    % iterate over dimension
    parfor d_idx=1:numel(dim_range_pairs)
        VSA=vsa_env('vsa',vsa_dict{i,1},'dim',dim_range_pairs(d_idx));
        
        % add vectors to container
        VSA.add_vector('num',item_memory_size); 

        % generate k (complete range) role-filler pairs
        item_names=VSA.item_mem{1,2};

        prob_correct=zeros([1 numel(k_range)]);

        % calculate the complete range of k 
        for k_idx=1:numel(k_range)
            k=k_range(k_idx);
            
            % sample roles and fillers
            pairs_names=datasample(item_names,k*2,'Replace',false);
            role_names=pairs_names(1:k,:);
            filler_names=pairs_names(k+1:end,:);
            filler_idx = find(ismember(item_names,filler_names));
            role_idx = find(ismember(item_names,role_names));
            
            role = VSA.item_mem{1,1}(:,role_idx);
            filler = VSA.item_mem{1,1}(:,filler_idx);

            % bind to role filler pairs
            pairs = VSA.bind(role,filler);

            % one-step bundling:
            bundle = VSA.bundle(pairs,[]);

            % unbind all roles and search in item memory          
            unbound_pairs = VSA.unbind(role,repmat(bundle,[1 k]));
            sim = VSA.sim(unbound_pairs, VSA.item_mem{1,1});
            [~, max_idx] = maxk(sim, 1, 2);
            item_names = VSA.item_mem{1,2}; % all names of the item memory
            unbound_filler_names = item_names(max_idx,:);
            
            % check if the unbinded filler names are the correct names
            num_correct=numel(find(ismember(filler_names,unbound_filler_names)));
            prob_correct(k_idx)=num_correct/k;

        end
        
        prob_correct_array=[prob_correct_array; prob_correct];

    end

    % concat each iteration to one tensor
    prob_correct_tensor(:,:,it)= prob_correct_array;

end

% compute mean and variance    
results_bindpairs_mean{i}=[results_bindpairs_mean{i}; mean(prob_correct_tensor,3)];
results_bindpairs_var{i}=[results_bindpairs_var{i}; var(prob_correct_tensor,1,3)];     
