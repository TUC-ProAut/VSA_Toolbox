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


%% visualization of results

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
choice_boundpairs={'MAP_B';'MAP_C'; 'MAP_I'; 'HRR'; 'HRR_VTB'; 'MBAT'; 'FHRR'; 'BSC'; 'BSDC_SHIFT'; 'BSDC_SEG'}; % are the VSA of the comparison paper
choice_repBind = {'MAP_C'; 'HRR';'HRR_VTB'};
choice_cap={'MAP_B';'MAP_C'; 'MAP_I'; 'HRR'; 'FHRR'; 'BSC'; 'BSDC_SHIFT'}; % are the VSA of the comparison paper
choice_lang={'MAP_B';'MAP_C'; 'MAP_I'; 'HRR'; 'HRR_VTB';'MBAT' ; 'FHRR'; 'BSC'; 'BSDC_SHIFT'; 'BSDC_SEG'}; % are the VSA of the comparison paper

names_mapping_cap = containers.Map(choice_cap,{'MAP-B';'MAP-C'; 'MAP-I'; 'HRR, VTB, MBAT';'FHRR';'BSC';'BSDC-S, BSDC-SEG, BSDC-CDT'});
names_mapping_boundpairs = containers.Map(choice_boundpairs,{'MAP-B';'MAP-C'; 'MAP-I'; 'HRR'; 'VTB'; 'MBAT';'FHRR';'BSC';'BSDC-S'; 'BSDC-SEG'});
names_mapping_lang_rec = containers.Map(choice_lang,{'MAP-B';'MAP-C'; 'MAP-I'; 'HRR'; 'VTB'; 'MBAT';'FHRR';'BSC';'BSDC-S'; 'BSDC-SEG'});

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
% if check_place_rec
%     vis_place_recognition   
% end


