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
% Author: Peer Neubert                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% sLSBH creation
% Y ... descriptors as m-by-n matrix with m descriptors and n features
% P ... Projection matrix; e.g. P = normc(randn(8192, 2*8192, 'single'));
% s ... sparsity with s = (0,1]
function L = get_sLSBH(Y, s)

  n = round(size(Y,2)*s);

  % random projection 
  Y2 = Y; % (already done)
  
  % sort
  [~, IDX] = sort(Y2,2, 'descend');
  
  % sparsification
  L1 = zeros(size(Y2), 'single');
%   L = zeros(size(Y2), 'single');
  
  for i = 1:size(Y2,1)
    L1(i,IDX(i,1:n)) = 1;
%     L(i,IDX(i,1:floor(n/2))) = 1;
  end
  
  % sort
  [~, IDX] = sort(Y2,2, 'ascend');
  
  % sparsification
  L2 = zeros(size(Y2), 'single');
  
  for i = 1:size(Y2,1)
    L2(i,IDX(i,1:n)) = 1;
%     L(i,IDX(i,1:floor(n/2))) = 1;
  end

  % concat
  L = [L1, L2];

end

