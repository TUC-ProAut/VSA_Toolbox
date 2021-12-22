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


function v = fractional_binding(vsa, vector, k)
% FRAC_BINDING  Apply fractional binding of a vector with an scalar
% k (see Eliasmith)
%  INPUT:
%   vsa:        VSA tpe
%   vector:     initial vector
%   k:          scalar for fractional binding of vector (can be a array
%               with multiple scalars)
%  OUTPUT:
%   v:          fractional bound vector (k encoded in vector)

switch vsa
    case {'FHRR','FHRR_fft'}
        v=wrapToPi(repmat(vector,[size(k)]).*k);
    case {'BSDC','BSDC_SEG','BSDC_SHIFT','BSC','BSDC_25'}
        values = ifft(fft(repmat(vector,[1 numel(k)]),size(vector,1),1).^k,size(vector,1),1);
        v=angle(values)>0;
    otherwise
        values = ifft(fft(repmat(vector,[1 numel(k)]),size(vector,1),1).^k,size(vector,1),1);
        v=real(values);
end

end