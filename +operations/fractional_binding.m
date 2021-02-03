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