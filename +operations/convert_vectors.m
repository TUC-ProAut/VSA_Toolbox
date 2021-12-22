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


function values = convert_vectors(vsa, Y, density)
%CONVERT_NUMBERS 
%   convert the number space respective to the vsa 
% INPUT:
%   Y:              data values (each row is one data-point-vector)
%   vsa:            name of the vsa (string)
% optional:   
%   density:        density of on bits (for sparse binary vectors)
% OUTPUT:
%   values:         converted values of input data (respective to the vsa)

if nargin >2
    density = density;
else
    % set default density
    switch vsa
        case {'BSDC', 'BSDC_test','BSDC_SHIFT'}
            density=1/sqrt(size(Y,2));  % density computing is optains from rachkovskji (most capacity and good stability)
        case 'BSDC_25'
            density=0.25;
        case 'BSDC_SEG'
            density=1/sqrt(size(Y,2));
        otherwise
         density=0.5;
    end
end

switch vsa
    case {'MAP_C'}
        % convert 
        values=Y;
%         values=(values-min(values,[],2))./(max(values,[],2)-min(values,[],2));
        values(values>1)=1;
        values(values<-1)=-1;
    case 'map_trans_uniform'
        % convert 
        values=Y;
        parfor i=1:size(Y,1)
            pd = makedist('Normal','mu',mean(Y(i,:)),'sigma',sqrt(var(Y(i,:))));
            values(i,:)=cdf(pd,Y(i,:))*2-1;
        end
    case {'MAP_B','MAP_I'} 
        % convert 
        values=double(Y>0)*2-1;
    case {'BSC'}
        % convert         
        values=double(Y>0);
    case {'HRR', 'HRR_VTB','MBAT'}
        % convert 
        values=normr(Y);
    case {'FHRR'}
        % convert 
        values=angle(fft(Y,size(Y,2),2));
    case {'BSDC','BSDC_SHIFT','BSDC_SEG'}
        % project values
        values = functions.get_sLSBH(Y,density); 
    case {'NONE', 'Proj.'}
        % use the original vectors without converting 
        values = Y;
    otherwise
        disp('Representation is not defined!')
end

end

