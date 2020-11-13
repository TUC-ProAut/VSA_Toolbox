%% binding and unbinding properties (repetitive binding/unbinding 
% refered to the paper "A comparison of Vector Symbolic Architectures"
% experimental setup is similar to [Gosmann 2019] with source code 
% https://github.com/ctn-archive/vtb/blob/master/Comparison%20of%20binding%20operations%20(VTB%20paper).ipynb
% default parameters are used in the original paper
% 
% scken, 2020

dim_range_bind=[2:2:35].^2;
bind_repetitions=40;

% init empty result tensor
sim_tensor=zeros([numel(dim_range_bind),bind_repetitions,number_iterations]);


for it=1:number_iterations
    sim_array=[];
    
    disp(['iteration: ' num2str(it)]);
    parfor d_idx=1:numel(dim_range_bind)
        % create VSA object
        VSA = vsa_env('vsa',vsa_dict{i,1},'dim',dim_range_bind(d_idx));
        
        similarities=[];
        
        % to normalize the similarity, calculate to highes and the lowest
        % similarity
        v1 = VSA.add_vector('add_item',0); 
        v2 = VSA.add_vector('add_item',0); 
        sim_equal=VSA.sim(v1,v1);
        sim_dif=VSA.sim(v1,v2);
        
        vec_a = VSA.add_vector('add_item',0); 
        recovered_a = vec_a; % recovered vector after each unbinding
        rand_vectors = [];
        bound = [vec_a];

        for r=1:bind_repetitions
            % repeat binding r times
            rand_vectors=[rand_vectors VSA.add_vector('add_item',0)];
            bound=[bound VSA.bind(rand_vectors(:,end),bound(:,end))];
            inverse=bound(:,end);
            for p=r:-1:1
                inverse=VSA.unbind(rand_vectors(:,p),inverse);
            end

            similarities=[similarities max([(VSA.sim(inverse,vec_a)-sim_dif)/(sim_equal-sim_dif) 0])];

        end
        sim_array=[sim_array; similarities];

    end
    sim_tensor(:,:,it)=sim_array;

end

results_bind_unbind1_mean{i}=[results_bind_unbind1_mean{i}; mean(sim_tensor,3)];
results_bind_unbind1_var{i}=[results_bind_unbind1_var{i}; var(sim_tensor,1,3)];
