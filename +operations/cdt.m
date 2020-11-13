function Z = cdt(superposition_vector, max_iters, density)
% apply the CDT Procedure at given vector (superposition)
%   INPUT:
%       superposition_vector:   superimposed vector of all inputs
%       max_iters:              max number of iterations within CDT
%                               procedure
%       density:                density of original vector 
%   OUTPUT:
%       Z:      thinned output vector

 % apply CDT procedure
 Z=superposition_vector;
 counter=1;
%  rng('default')
%  rng(0);
 while mean(sum(Z)/size(Z,1))>density
%     r=randi(size(Z,1),1);  % random permutation
    r = counter; % detemine the shifting
    permutation=circshift(superposition_vector,r);
    thinned=and(superposition_vector,permutation);
    Z(thinned)=0;
    if counter>max_iters %if more then max_iters iteration, break loop
        break
    end
    counter=counter+1;
    
 end
%  rng('shuffle')
end

