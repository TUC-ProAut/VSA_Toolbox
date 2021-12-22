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


%% experiments on different vsa's
clear all 
close all 

vsa_dict={};
% chose the appropriate VSAs
if 1, vsa_dict{end+1,1} = 'MAP_B'; end;
if 1, vsa_dict{end+1,1} = 'MAP_C'; end;
if 1, vsa_dict{end+1,1} = 'MAP_I'; end; 
if 1, vsa_dict{end+1,1} = 'HRR'; end;
if 1, vsa_dict{end+1,1} = 'FHRR'; end;
if 1, vsa_dict{end+1,1} = 'HRR_VTB'; end;
if 1, vsa_dict{end+1,1} = 'BSC'; end;
if 1, vsa_dict{end+1,1} = 'BSDC_SHIFT'; end;
if 1, vsa_dict{end+1,1} = 'BSDC'; end;
if 1, vsa_dict{end+1,1} = 'BSDC_SEG'; end; 
if 1, vsa_dict{end+1,1} = 'MBAT'; end;

number_iterations = 10; % for statisitcal evaluation (mean, variance of the experiments)


%% check properties of given vsa's
% select the sub-experiment (set 1 to select and 0 to deselect)

check_repetitive_binding  = 1;
check_bundle_capacity     = 1;
check_boundpairs          = 1;

check_langRec             = 1;
check_vpr                 = 0; % you will need the datasets for testing the VPR experiment (not provided yet - comming soon)

% decide visualization 
vis=true; % set true, if you want to plot the results

%% path setup

workspace_path = mfilename('fullpath');
workspace_path = workspace_path(1:find(workspace_path == '/',1,'last'));
results_path=[workspace_path 'experimental_results/'];
 
%% define empty results arrays

results_capacity = cell([size(vsa_dict,1) 1]);
results_bindpairs_mean=cell([size(vsa_dict,1) 1]);
results_bindpairs_var=cell([size(vsa_dict,1) 1]);
results_bind_unbind1_mean=cell([size(vsa_dict,1) 1]);
results_bind_unbind1_var=cell([size(vsa_dict,1) 1]);
results_bind_unbind2_mean=cell([size(vsa_dict,1) 1]);
results_bind_unbind2_var=cell([size(vsa_dict,1) 1]);
results_bundle_mean=[];
results_bundle_var=[];
results_langRec = cell([size(vsa_dict,1) 1]);
results_langRec_VSAs = cell([size(vsa_dict,1) 1]);

%% main for loop (for all VSAs)
for i=1:size(vsa_dict,1)
 
    disp('####')
    disp(vsa_dict{i,1})
    disp('####')
    
        
    %% check binding and unbinding properties
    if check_repetitive_binding
        disp('---- check repetitive binding ----')
        
        experimental_scripts.repetitive_binding
    end
        
    %% capacity computing (k nearest nighbors)
    if check_bundle_capacity
        disp('---- check bundling capacity ----')
        fix_number = 1; % set 1 if use a fixed number of stored items, else 0 for vary the item memory size
        if fix_number
            % fix number of stored item (1000)
            item_memory_size = 1000;
            experimental_scripts.bundle_capacity
        else
            % variable number of stored item 
            item_memory_size = [15 20 30 50 100 200 300 500]% 1000 2000 3000 5000 10000 1e5 1e6];
            experimental_scripts.bundle_capacity
        end
    end

    %% binding k pairs and retrive them
    if check_boundpairs
        disp('---- check bound pairs capacity ----')
        
        experimental_scripts.boundpairs
    end

    %% language recognition experiment
    if check_langRec
        disp('---- language recognition experiment ----')
        dim_range_lang = [10:4:50].^2;
        results = zeros([1 numel(dim_range_lang)]);
        for d=1:numel(dim_range_lang)
            disp(['Dim = ' num2str(dim_range_lang(d))])
            [results(d), ~] = experimental_scripts.language_recognition(vsa_dict{i,1},dim_range_lang(d), 3);
        end
        results_langRec{i}=results;
    end
    
    %% binding k pairs and retrive them
    % datasets will  be provided as soon as possible
    if check_vpr
        disp('---- check visual place recognition ----')
        
        experimental_scripts.visual_place_recognition
    end
end
%% save results in mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist(results_path, 'dir')
       mkdir(results_path)
end

experimental_scripts.save_results

%% call visualization script

if vis
    use_saved_data=0; % if you want to use saved data, set to true
    experimental_scripts.visualization.visualize_all;
end
