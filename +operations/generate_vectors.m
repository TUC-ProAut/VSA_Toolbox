function gen_vecs = generate_vectors(varargin)
    % generate vectors within the specific ranges
    % INPUT (optinal):  
    %     dim       - number of dimensions
    %     vsa       - vsa representation
    %     num       - number of to generated vectors
    %     density   - density (for binary)
    % OUTPUT:
    %     gen_vecs: - column-wise matrix with generated vectors


    default_dim     = 10000;
    default_vsa     = 'map';
    default_density = -1;
    default_num     = 1;
    
    p=inputParser;

    addOptional(p, 'dim', default_dim)
    addOptional(p, 'vsa', default_vsa)
    addOptional(p, 'num', default_num)
    addOptional(p, 'density', default_density)

    parse(p,varargin{:}) 
    dim     = p.Results.dim;
    vsa     = p.Results.vsa;
    num     = p.Results.num;
    
    if p.Results.density == -1
        % define default density
        switch vsa
             case {'BSDC', 'BSDC_test','BSDC_SHIFT'}
                 density=1/sqrt(dim);  % density computing is optains from rachkovskji (most capacity and good stability)
             case 'BSDC_25'
                 density=0.25;
             case 'BSDC_SEG'
                 density=1/sqrt(dim);
             otherwise
                 density=0.5;
        end
    else
        density = p.Results.density;    
    end
    
    

    switch vsa
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MAP and MBAT
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case {'MAP_B','MAP_I'} % Gaylers Multiplication, Addition and Permutaiton Architecture with bipolar vector space {-1,1}
            gen_vecs = binornd(1,0.5,[dim num])*2-1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MAP
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
        case {'map','MAP_C'} % Gaylers Multiplication, Addition and Permutaiton Architecture
       
            rand_values = double(rand([dim num]));

            gen_vecs = double(rand_values)*2-1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BSC
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
        case {'BSC'}
            
            rand_values = double(rand([dim num]));
         
            % set values
            gen_vecs = double(rand_values>1-density)*1;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BSDC
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
        case {'BSDC','BSDC_SHIFT','BSDC_25','BSDC_THIN'}
            
            rand_values = double(rand([dim num]));
         
            % find the k highest idex (k correspond to
            % density)
            [~,rows] = maxk(rand_values, ceil(dim*density));
            values = zeros(size(rand_values));
            idx=sub2ind(size(rand_values),rows,repmat(1:size(rand_values,2),[size(rows,1) 1]));
            values(idx) = 1;

            gen_vecs = double(values);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BSDC-SEG
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
        case {'BSDC_SEG'}
            % create segments (depending on density) and set one bit per
            % segment to 1
            num_segments = floor(dim*density);
            size_segments = floor(dim/num_segments);
            
            z = zeros([size_segments num_segments num]);
            rand_r = randi(size_segments,[num_segments num]);
            rand_c = repmat((1:num_segments)', [1 num]);
            rand_t = repmat(1:num,[num_segments 1]);
            indices = sub2ind(size(z),rand_r, rand_c, rand_t);
            z(indices) = 1;
   
            gen_vecs = reshape(z,[], num);
            if dim~=num_segments*size_segments
                d = dim-num_segments*size_segments;
                gen_vecs = [gen_vecs; zeros([d num])]; 
            end
            
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % HRR
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
        case {'HRR','HRR_VTB','MBAT'}
            rand_values=double(randn([dim num]));

            % set values
            gen_vecs=double(rand_values*sqrt(1/dim));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % HRR complex
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
        case {'FHRR','FHRR_fft'}
            rand_values=double(rand([dim num]));
         
            % set values
            gen_vecs=double(rand_values*2*pi-pi);                     
         
        otherwise
            disp('Representation is not defined!')
    end

    
end