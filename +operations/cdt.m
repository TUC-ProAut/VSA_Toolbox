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

