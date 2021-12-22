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


%% VPR experiment

% select datasets for evaluation
evals={};

if 1, evals(end+1,:)= {'Nordland288',  'fall',  'spring'}; end
if 1, evals(end+1,:)= {'Nordland288',  'fall',  'winter'}; end
if 1, evals(end+1,:)= {'Nordland288',  'spring',  'winter'}; end
if 1, evals(end+1,:)= {'Nordland288',  'winter',  'spring'}; end
if 1, evals(end+1,:)= {'Nordland288',  'summer',  'spring'}; end
if 1, evals(end+1,:)= {'Nordland288',  'summer',  'fall'}; end
if 1, evals(end+1,:)= {'oxford_2018_06_13',  '141209',  '141216'}; end
if 1, evals(end+1,:)= {'oxford_2018_06_13',  '141209',  '150203'}; end
if 1, evals(end+1,:)= {'oxford_2018_06_13',  '141209',  '150519'}; end
if 1, evals(end+1,:)= {'oxford_2018_06_13',  '150519',  '150203'}; end
if 1, evals(end+1,:)= {'StLucia',  '100909_0845',  '190809_0845'}; end
if 1, evals(end+1,:)= {'StLucia',  '100909_1000',  '210809_1000'}; end
if 1, evals(end+1,:)= {'StLucia',  '100909_1210',  '210809_1210'}; end
if 1, evals(end+1,:)= {'StLucia',  '100909_1410',  '190809_1410'}; end
if 1, evals(end+1,:)= {'StLucia',  '110909_1545',  '180809_1545'}; end
if 1, evals(end+1,:)= {'CMU',  '20110421',  '20100901'}; end
if 1, evals(end+1,:)= {'CMU',  '20110421',  '20100915'}; end
if 1, evals(end+1,:)= {'CMU',  '20110421',  '20101221'}; end
if 1, evals(end+1,:)= {'CMU',  '20110421',  '20110202'}; end
if 1, evals(end+1,:)= {'GardensPointWalking',  'day_left',  'night_right'}; end
if 1, evals(end+1,:)= {'GardensPointWalking',  'day_right',  'day_left'}; end
if 1, evals(end+1,:)= {'GardensPointWalking',  'day_right',  'night_right'}; end

normalization = 1
netvlad = 0
dim=4096
sequence=5

VSA_objects = cell([numel(vsa_dict) 1]);

for d=1:size(evals,1)
    
    dataset = evals{d,1};
    training_saison = evals{d,2};
    test_saison =   evals{d,3};

    workspace_path = mfilename('fullpath');
    workspace_path = workspace_path(1:find(workspace_path == '/',1,'last'));
    results_path=[workspace_path '../experimental_results/vpr/'];  

    if ~exist(results_path, 'dir')
           mkdir(results_path)
    end

    dataset_path = 'datasets/';
    
    names_mapping = containers.Map;
    names_mapping('NONE')='orig. Encoding';
    names_mapping('Proj')='projected orig. Encoding';
    names_mapping('MAP_B')='MAP {-1,1}';
    names_mapping('MAP_C')='MAP [-1,1]';
    names_mapping('MAP_I')='MAP integer';
    names_mapping('HRR') = 'HRR';
    names_mapping('HRR_VTB') = 'HRR with VTB';
    names_mapping('FHRR')='FHRR uniform encod.';
    names_mapping('FHRR_fft')='FHRR FFT encod.';
    names_mapping('BSC')='BSC';
    names_mapping('BSC_cosine')='BSC with cosine sim';
    names_mapping('BSDC_SHIFT')='sparse binary with shifting';
    names_mapping('BSDC_25')='sparse binary d=0.25';
    names_mapping('BSDC_SEG')='sparse binary with segment binding';
    names_mapping('MBAT')='MBAT';

    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp(['Dataset: ' dataset '_' training_saison '_' test_saison])

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% load and convert data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % training
    if netvlad==0
        D1=load([dataset_path 'descriptors/' dataset '/' training_saison '/alexnet_conv3.mat']);
        Y_train = D1.Y;
    else
        D1=load([dataset_path 'descriptors/' dataset '/' training_saison '/netvlad.mat']);
        if max(strcmp(dataset,{'StLucia','CMU','GardensPointWalking'}))>0
            Y_train = D1.Y;
        else
            Y_train = D1.Y';
        end
    end
    % testing
    if netvlad==0
        D2=load([dataset_path 'descriptors/' dataset '/' test_saison '/alexnet_conv3.mat']);
        Y_test = D2.Y;
    else
        D2=load([dataset_path 'descriptors/' dataset '/' test_saison '/netvlad.mat']);
        if max(strcmp(dataset,{'StLucia','CMU','GardensPointWalking'}))>0
            Y_test = D2.Y;
        else
            Y_test = D2.Y';
        end
    end
    
    %load GT
    if exist([dataset_path 'ground_truth/' dataset '/' training_saison '-' test_saison '/gt.mat'])
        load([dataset_path 'ground_truth/' dataset '/' training_saison '-' test_saison '/gt.mat']);
    else
        disp('GT is not defined!')  
    end

    if sum(strcmp(dataset,{'StLucia';'CMU';'GardensPointWalking'}))>0
        GThard = GT.GThard;
        GTsoft = GT.GTsoft;
    end
    
    disp('finished data loading')

    values_train=cell([numel(vsa_dict) 1]);
    values_test=cell([numel(vsa_dict) 1]);

    % random projection matrix
    % set random seed
    rng('default')
    rng(1)

    PN = randn(dim, size(Y_train,2));
    PN = normr(PN); 
    if normalization==1
        Y_train_proj =  normalize(Y_train * PN');
        Y_test_proj = normalize(Y_test * PN');
        Y_train = normalize(Y_train);
        Y_test = normalize(Y_test);
        % half the number of dimensions for sparse vectors (because sLSBH
        % doubled dimensions)
        Y_test_proj_half = normalize(Y_test * PN(1:floor(size(PN,1)/2),:)');
        Y_train_proj_half = normalize(Y_train * PN(1:floor(size(PN,1)/2),:)');

    else
        Y_train_proj =  Y_train * PN';
        Y_test_proj = Y_test * PN';

        Y_test_proj_half = Y_test * PN(1:floor(size(PN,1)/2),:)';
        Y_train_proj_half = Y_train * PN(1:floor(size(PN,1)/2),:)';
    end
    

    % convert training and test values 
    for i=1:size(vsa_dict,1)
        % convert values into specific ranges
        switch vsa_dict{i}
            case 'NONE'
                values_train{i}=Y_train';  
                values_test{i}=Y_test';
            case 'Proj'
                values_train{i}=Y_train_proj';  
                values_test{i}=Y_test_proj';
            case {'BSDC_SHIFT','BSDC_SEG'}
                VSA = vsa_env('vsa',vsa_dict{i},'dim',dim);
                values_train{i}=VSA.convert(Y_train_proj)';  
                values_test{i}=VSA.convert(Y_test_proj)'; 
                VSA.dim = size(values_train{i},1);
                VSA_objects{i} = VSA;
            otherwise
                VSA = vsa_env('vsa',vsa_dict{i},'dim',dim);
                values_train{i}=VSA.convert(Y_train_proj)';  
                values_test{i}=VSA.convert(Y_test_proj)'; 
                VSA_objects{i} = VSA;
        end
    end
    
    clear D1 D2 PN;
    disp('finished data converting')

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% pairwise comparison
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('pairwise comparison')
    
    % compute similarities 
    sim_arrays = cell([numel(vsa_dict) 1]);
    % sim_arrays(:) = zeros([size(Y_train,1) size(Y_test,1)]); 

    for i=1:size(vsa_dict,1)
       disp(['compute sim matrix of: ' vsa_dict{i}])
       sim_arrays{i}=operations.compute_sim(vsa_dict{i},values_train{i},values_test{i});
    end

    %compare the results
    mAP_pairwise=zeros([numel(vsa_dict) 1]);

    for i=1:size(vsa_dict,1)    
    %     [p,r] = pr_hard_soft(sim_arrays{i},GThard,GTsoft,100);
        [p, r, V, ~, ~, ~] = functions.createPR(sim_arrays{i},GThard,GTsoft,0,0,0);
        mAP_pairwise(i)=trapz(r,p);
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% sequence SLAM with VSAs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('sequence SLAM with VSAs')
    
    mAP=zeros([numel(vsa_dict) 1]);
    precision=cell([numel(vsa_dict) 1]);
    recall=cell([numel(vsa_dict) 1]);


    for i=1:size(vsa_dict,1)
        disp(['Place Recognition with VSA: ' vsa_dict{i}])
        sim_matrix = zeros(size(sim_arrays{1}));

        switch vsa_dict{i}
            case {'NONE';'Proj'}
                sim_matrix = functions.seqSLAMConv(sim_arrays{i},sequence);

            otherwise
                sim_matrix = experimental_scripts.place_recognition(VSA_objects{i},size(values_train{i},1),values_train{i},values_test{i},sequence);    
        end
        
        [precision{i}, recall{i}, ~, ~, ~, ~] = functions.createPR(sim_matrix,GThard,GTsoft,0,0,0);

        mAP(i)=trapz(recall{i},precision{i});
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% sequence SLAM with convolution for all encodings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('original sequence SLAM for all encodings')
    
    mAP_seqSLAMConv=zeros([numel(vsa_dict) 1]);
    precision_seqSLAMConv=cell([numel(vsa_dict) 1]);
    recall_seqSLAMConv=cell([numel(vsa_dict) 1]);


    for i=1:size(vsa_dict,1)
        disp(['Place Recognition with VSA: ' vsa_dict{i}])
        sim_matrix = zeros(size(sim_arrays{1}));

        sim_matrix = functions.seqSLAMConv(sim_arrays{i},sequence);    

        [precision_seqSLAMConv{i}, recall_seqSLAMConv{i}, ~, ~, ~, ~] = functions.createPR(sim_matrix,GThard,GTsoft,0,0,0);


        mAP_seqSLAMConv(i)=trapz(recall_seqSLAMConv{i},precision_seqSLAMConv{i});
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% save the results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for i=1:size(vsa_dict,1)
        current_path = [results_path vsa_dict{i} '/'];
        if ~exist(current_path, 'dir')
            mkdir(current_path);
        end
        
        
        if netvlad==1
            save_path = [current_path dataset '_' training_saison '_' test_saison '_normalize_' num2str(normalization) '_netvlad.mat'];
        else 
            save_path = [current_path dataset '_' training_saison '_' test_saison '_normalize_' num2str(normalization) '_alexnet.mat'];
        end
        
        mAP_pairwise_ = mAP_pairwise(i,:);
        mAP_ = mAP(i,:);
        mAP_seqSLAMConv_ = mAP_seqSLAMConv(i,:);
        
        save(save_path,...
            'mAP_pairwise_','mAP_','mAP_seqSLAMConv_',...
            'vsa_dict', 'sequence')
    end
end