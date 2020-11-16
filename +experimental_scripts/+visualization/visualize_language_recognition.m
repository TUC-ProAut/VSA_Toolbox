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


%% visualize results of language recognition experiment 

% load default mat file
if use_saved_data, load(fullfile(image_path, '../', 'language_recognition.mat')), end;

%% plot results 

figure()
lines=[];
cmap=colormap('lines');
leg={};
counter=1;
marker = '-';
for i=1:size(vsa_dict,1)
    switch vsa_dict{i}
        case choice_lang
            if counter>7, marker = '-.'; end
            L=plot(dim_range_lang(1:end-1),smooth(results_langRec{i}(1:end-1),3),marker,'color',cmap(counter,:), 'LineWidth',1.2);
            lines=[lines; L];
            leg={leg{:} strrep(vsa_dict{i,1},'_',' ')};
            hold on;
            counter = counter+1;
    end
    
end

title(['Accuracy in Language Recognition experiment wiht increasing number of dimensions'],'FontWeight','bold', 'FontSize',16, 'FontName','Times New Roman');
xlabel('Number of dimensions')
ylabel('Accuracy')
xlim([1 2116])
legend(lines,strrep(leg,'_',' '),'Location','southeast')
set(gcf,'color','w')
set(gcf, 'Position', [700 700 900 400])
grid on
if exist('export_fig')
    export_fig([image_path 'language_recognition_acc.pdf'],'-dpdf') 
else
    saveas(gcf,[image_path 'language_recognition_acc.png'])
end

