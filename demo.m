%% DEMO of VSA environment scripting
clear all
close all

% create the object of a specific VSA type
type = 'MAP_B'; % available types: 'MAP_C'; 'MAP_B'; 'MAP_I'; 'BSC'; 'BSDC'; 'BSDC_SHIFT'; 'HRR'; 'HRR_VTB'; 'FHRR'
VSA = vsa_env('vsa',type,'dim',1024);

% add vectors to item memory (randomly chosen)
VSA.add_vector('num',100);
% the VSA has the 100 random vectors in the item memory with random names 

% another way is to generate vectors without adding to the item memory
vectors = VSA.add_vector('num',100,'add_item',0); % set add_item to 0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. bundling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% single vector bundling 
v1 = VSA.add_vector('num',1,'add_item',0); 
v2 = VSA.add_vector('num',1,'add_item',0); 
v3 = VSA.add_vector('num',1,'add_item',0); 
bundle = VSA.bundle(v1,v2);

% bundle is similar to v1 and v2 but not to v3
sim = VSA.sim(bundle,[v1 v2 v3]);
disp('------- single vector bundling:')
disp(['Similarity of bundle to v1 = ' num2str(sim(1))]);
disp(['Similarity of bundle to v2 = ' num2str(sim(2))]);


%%% multiple vector bundling
% it is also possible to bundle multiple vectors (vectors arrays) 
% e.g. vectors array 1 as well as array 2 contain 10 vectors and can be
% bundled together into one vector
v_array_1 = VSA.add_vector('num',10,'add_item',0); 
v_array_2 = VSA.add_vector('num',10,'add_item',0); 
bundle = VSA.bundle(v_array_1, v_array_2);

% bundle is similar to all vectors of array 1 and 2
sim_array = VSA.sim(bundle,[v_array_1 v_array_2]);
disp('------- multiple vector bundling:')
disp(['Similarity of bundle to the first vector from vector array 1 = ' num2str(sim_array(1))]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. binding / unbinding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% single vector binding
v1 = VSA.add_vector('num',1,'add_item',0); 
v2 = VSA.add_vector('num',1,'add_item',0); 

bound_v = VSA.bind(v1,v2);

% bound_v is neither similar to v1 nor to v2
sim_bound = VSA.sim(bound_v,[v1 v2]);
disp('------- single vector binding:')
disp(['Similarity of bound vector to v1 = ' num2str(sim_bound(1))]);
disp(['Similarity of bound vector to v2 = ' num2str(sim_bound(2))]);

% unbinding and recovering of vector v2
r = VSA.unbind(v1,bound_v);

sim_v1 = VSA.sim(r,v1);
sim_v2 = VSA.sim(r,v2);
disp('------- unbinding:')
disp(['Similarity of recoverd (unbound) vector to v1 = ' num2str(sim_v1) ' and to v2: ' num2str(sim_v2)]);

%%% multiple vector binding
% it is possible to bind multiple vectors (vector-wise)
% e.g. vectors array 1 and 2 have 100 vectors (two array must have the same
% size) and can be bind together (vector-wise) -> output is an array with
% also 100 vectors
v_array_1 = VSA.add_vector('num',10,'add_item',0); 
v_array_2 = VSA.add_vector('num',10,'add_item',0); 
bound_array = VSA.bind(v_array_1, v_array_2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. use the item memory to find vectors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fill the item memor with random vectors
VSA = vsa_env('vsa',type,'dim',1024);
VSA.add_vector('num',10000);

% generate a probe vector
v = VSA.add_vector('name','probe');

% finde the probe vector in item memory
[v_clean, name, s] = VSA.find_k_nearest(v,1);
disp('----------- find vector in item memory:')
disp(['Found vector ' name{1} ' with similarity of ' num2str(s)]);

% bundle the probe with noise vector
noise = VSA.add_vector('add_item',0);
bundle = VSA.bundle(v,noise);
[v_clean, name, s] = VSA.find_k_nearest(bundle,1);
disp(['Found noisy vector ' name{1} ' with similarity of ' num2str(s)]);


