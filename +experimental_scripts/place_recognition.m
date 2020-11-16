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