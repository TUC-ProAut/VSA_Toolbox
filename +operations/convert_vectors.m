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
    case {'FHRR_fft'}
        % convert 
        values=angle(fft(Y,size(Y,2),2));
    case {'FHRR'} 
        % convert 
        values=Y;
        pd = makedist('Normal','mu',mean(Y(:)),'sigma',sqrt(var(Y(:))));
        values=cdf(pd,Y(:))*2*pi-pi;
        values=reshape(values,size(Y,1),[]);
    case 'FHRR_full'
        % convert 
        values=Y;
        parfor i=1:size(Y,1)
            values(i,:)=fft(double(Y(i,:)));
        end
    case {'BSDC','BSDC_test','BSDC_SHIFT','BSDC_SEG','BSDC_25'}
        % project values
        values = functions.get_sLSBH(Y,density); 
    case {'NONE', 'Proj.'}
        % use the original vectors without converting 
        values = Y;
    otherwise
        disp('Representation is not defined!')
end

end

