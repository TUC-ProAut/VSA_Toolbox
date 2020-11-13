function [sim_matrix] = place_recognition(VSA, dim, training_values, test_values, seq, permute_degree)
%   perform the place recognition experiment 
%   
%   INPUT:
%       VSA:                VSA object (vsa_env)
%       dim:                Dimesnion
%       training_values:    training vectors column wise vectors
%       test_values:        test vectors column wise vectors
%       seq:                number of sequences
%   OUTPUT:
%       sim_matrix:         similarit matrix
%
% scken, 2020

if nargin <=5
    permute_degree = 1;
end
    
%% preprocessing 

% create sequence vector
d=floor(seq/2);

timestamps = VSA.add_vector('num',2*d+1,'add_item',0);


%% training 
num_vecs = size(training_values,2);
training_sequences = training_values;

for i=d+1:num_vecs-d

    
    sequence = VSA.bind(timestamps,training_values(:,(i-d):i+d));

    training_sequences(:,i) = VSA.bundle(sequence,[]); 
%     % if sparse VSA, no normalization (no thinning)
%     if any(strcmp(VSA.vsa,{'BSDC_SHIFT','BSDC_SEG'}))
%         temp = VSA.density;
%         VSA.density = 1; % no thinning
%         training_sequences(:,i) = VSA.bundle(sequence,[],0);
%         VSA.density = temp;
%     else
%         training_sequences(:,i) = VSA.bundle(sequence,[]);   
%     end
end


%% test 

num_vecs = size(test_values,2);
test_sequences = test_values;

for i=d+1:num_vecs-d
    sequence = VSA.bind(timestamps,test_values(:,(i-d):i+d));

    test_sequences(:,i) = VSA.bundle(sequence,[]);  
%     % if sparse VSA, no normalization (no thinning)
%     if any(strcmp(VSA.vsa,{'BSDC_SHIFT','BSDC_SEG'}))
%         temp = VSA.density;
%         VSA.density = 1; % no thinning
%         test_sequences(:,i) = VSA.bundle(sequence,[],0);   
%         VSA.density = temp;
%     else
%          
%     end
end

%% similarity matrix 

sim_matrix = VSA.sim(training_sequences, test_sequences);


end