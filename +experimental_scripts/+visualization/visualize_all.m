% visualization of results

% setup the saving-paths
if exist('workspace_path')
    image_path = [workspace_path '/experimental_results/plots/'];
else
    [filepath,~,~] = fileparts(mfilename('fullpath'));
    image_path = fullfile(filepath, '../../experimental_results/plots/');
end

if ~exist(image_path, 'dir')
   mkdir(image_path)
end

%% check if shaded error bar is available
if exist([workspace_path '/+functions/

%% check visualtion
% if the script is started stand alone, you have to chose which 
% results have to be visualized

if exist('check_repetitive_binding')==0
    check_repetitive_binding=            1;
end
if exist('check_bundle_capacity')==0
    check_bundle_capacity=               1;
end
if exist('check_boundpairs')==0
    check_boundpairs=                    1;
end
if exist('check_langRec')==0
    check_langRec=                       1;
end
if exist('use_saved_data')==0
    use_saved_data=                      1;
end


% chose vsa to plot 
% choice={'MAP_B';'MAP_C'; 'HRR'; 'FHRR'; 'HRR_VTB'; 'BSC'; 'BSDC_SHIFT'}; % are the VSA of the comparison paper
choice_boundpairs={'MAP_B';'MAP_C'; 'MAP_I'; 'HRR'; 'HRR_VTB'; 'MBAT'; 'FHRR'; 'BSC'; 'BSDC_SHIFT'; 'BSDC_SEG'}; % are the VSA of the comparison paper
choice_repBind = {'MAP_C'; 'HRR';'HRR_VTB'};
choice_cap={'MAP_B';'MAP_C'; 'MAP_I'; 'HRR'; 'FHRR'; 'BSC'; 'BSDC_SHIFT';'BSDC_THIN'}; % are the VSA of the comparison paper
choice_lang={'MAP_B';'MAP_C'; 'HRR'; 'HRR_VTB'; 'FHRR'; 'BSC'; 'BSDC_SHIFT'; 'BSDC_SEG';'MBAT'}; % are the VSA of the comparison paper

names_mapping_cap = containers.Map(choice_cap,{'MAP-B';'MAP-C'; 'MAP-I'; 'HRR, VTB, MBAT';'FHRR';'BSC';'BSDC-S, BSDC-SEG, BSDC-CDT';'BSDC-THIN'});
names_mapping_boundpairs = containers.Map(choice_boundpairs,{'MAP-B';'MAP-C'; 'MAP-I'; 'HRR'; 'VTB'; 'MBAT';'FHRR';'BSC';'BSDC-S'; 'BSDC-SEG'});


%% plot results


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
if check_bundle_capacity
    experimental_scripts.visualization.visualize_bundle_capacity
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
if check_boundpairs
    experimental_scripts.visualization.visualize_boundpairs
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
if check_repetitive_binding
    experimental_scripts.visualization.visualize_repetitive_binding
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
if check_langRec
    experimental_scripts.visualization.visualize_language_recognition
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% if check_computing_time
%     experimental_scripts.visualization.visualize_binding_time
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% if check_place_rec
%     vis_place_recognition   
% end


