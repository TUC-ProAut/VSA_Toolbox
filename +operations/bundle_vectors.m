function bundled_vectors = bundle_vectors(vsa, vectors_1, vectors_2, varargin)
 % bundle vector array 1 and vector array 2 
 % INPUT:
 %      vsa:                VSA type
 %      vectors_1:          vectors to bundle (column-wise vector array)
 %      vectors_2:          vectors to bundle (column-wise vector array)
 %      normalize:          if set (bool), the resulting vector will be
 %                          normalized after bundling (default if true)
 %      density:            density of the input vectors (important for
 %                          sparse vectors - CDT procedure)
 %      max_density:        maximum density after bundling (for BSDC
 %                          archtiectures)
 % OUTPUT:
 %      bundled_vectors:    result of bundling vectors_1 with vectors_2
 %
 % scken, 2020
 
default_normalize = 1;
default_density = 0.5;
default_max_density = 1;

p=inputParser;

addParameter(p,'normalize', default_normalize);
addParameter(p,'density',default_density);
addParameter(p,'max_density',default_max_density);

parse(p,varargin{:});

density = p.Results.density;
normalize = p.Results.normalize;
max_density = p.Results.max_density;
 
% concatenate the two input vectors 
vector_array=[vectors_1, vectors_2];
dim = size(vector_array,1);
 
     switch vsa
        case 'MAP_B'
            % majority rule
            values=sum(vector_array,2);
            if normalize
                values(find(values<-1))=-1;
                values(find(values>1))=1;
                random_choise=double(rand([dim 1])>0.5)*2-1;
                values(find(values==0))=random_choise(find(values==0));
            end
            bundled_vectors = values;
        case {'MAP_C'}
            values=sum(vector_array,2);
            if normalize
                % normalization of bundeld vectors
                values(find(values>1))=1;
                values(find(values<-1))=-1;
            end
            bundled_vectors = values;
        case {'MAP_I'}
            % sum
            bundled_vectors = sum(vector_array,2);
        case {'BSC'}
            values=sum(vector_array,2);
            if normalize
                % check if number of vectors is odd (apply majority rule)
                number_vec=size(vector_array,2);
                if mod(number_vec,2)==0
                    random_choise=double(rand([dim 1])>0.5)*1;
                    values=values+random_choise;
                    number_vec=number_vec+1;
                end
                
                thresh=number_vec/2;
                % if threshold highly differ from mean, than use mean
                % as threshold
                if abs(thresh-mean(values))>2
                    thresh = mean(values);
                end
                values = double(values>thresh);
            end
            bundled_vectors = values;
        case {'BSDC'}
            % elementwise disjunction
            bundled_vectors = double(sum(vector_array,2)>=1);        
        case {'BSDC_THIN'}
            % elementwise disjunction
            max_density = 0.5;
            k = floor(max_density*size(vector_array,1));

            values = sum(vector_array,2);            
            if normalize
                bundled_vectors = zeros([size(vector_array,1) 1]);
                [~, idx] = maxk(values,k);
                bundled_vectors(idx) = values(idx)>0;
            else
                bundled_vectors = values;
            end
        case {'HRR', 'HRR_VTB','MBAT'}
            % elementwise addition 
            values = sum(vector_array,2);
            if normalize 
                values = values/norm(values);
            end
            bundled_vectors = values;
        case {'FHRR','FHRR_fft'}
            % average angle 
            % check if values already complex - if not convert angles to complex
            % numbers
            if isreal(vectors_1)
                complex_vectors_1 = complex(cos(vectors_1),sin(vectors_1));
            else
                complex_vectors_1 = vectors_1;
            end
            if isreal(vectors_2)
                complex_vectors_2 = complex(cos(vectors_2),sin(vectors_2));
            else
                complex_vectors_2 = vectors_2;
            end
            complex_vector_array = [complex_vectors_1, complex_vectors_2];
            values = sum(complex_vector_array,2);
            if normalize
                values = angle(values);
            end
            bundled_vectors = values;
        case 'FHRR_full'
            values = sum(vector_array,2);
            if normalize
                 values = normalize(values);
            end
            bundled_vectors = values
        case {'BSDC_25','BSDC_SHIFT'}
            % elementwise disjunction and CDT procedure
            % select the k highest values (k is computed with the density)
            k = floor(max_density*size(vector_array,1));
            
            values = sum(vector_array,2);
            if normalize
                bundled_vectors = zeros([size(vector_array,1) 1]);
                [~, idx] = maxk(values,k);
                bundled_vectors(idx) = values(idx)>0;
            else
                bundled_vectors = values;
            end
         case 'BSDC_SEG'
            num_segments = floor(dim*density);
            size_segments = floor(dim/num_segments);
            k = floor(max_density*size_segments);
            
            values = sum(vector_array,2);
                      
            if normalize
                values_segments = reshape(values(1:size_segments*num_segments),[size_segments, num_segments]);
                [~, idx] = maxk(values_segments,k);
                idx = sub2ind(size(values_segments), idx, repmat(1:num_segments,[size(idx,1) 1]));
                bundled_vectors = zeros(size(values_segments));
                bundled_vectors(idx) = values_segments(idx);
                bundled_vectors = reshape(bundled_vectors, [], 1)>0;
            else
                bundled_vectors = values;
            end
            
            if size_segments*num_segments~=size(values,1)
                bundled_vectors = [bundled_vectors; values(size_segments*num_segments+1:end)];
            end
            
        otherwise
            disp('Representation is not defined!')
    end
end