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


%% visualize the results of the repetitive binding experiment 

% load mat file
if use_saved_data, load(fullfile(image_path, '../', 'repetitive_binding.mat')), end;

% plot accuracy at specific dimension
figure()
lines=[];
plot_dim=16;
counter=1;
cmap=colormap('Lines');
leg={};
for i=1:size(vsa_dict,1)
    switch vsa_dict{i}
        case choice_repBind
            L=shadedErrorBar(1:bind_repetitions,results_bind_unbind1_mean{i}(plot_dim,:),results_bind_unbind1_var{i}(plot_dim,:),'lineprops',{'color',cmap(counter,:)});
            lines=[lines; L.mainLine];
%                 leg={leg{:} upper(vsa_dict{i,1})};% ' d=' num2str(vsa_dims(i))];
            leg={leg{:} names_mapping_boundpairs(vsa_dict{i,1})};
            counter=counter+1;
            hold on;
    end
end
title(['Similarity of unbound vector with dimension D= ' num2str(dim_range_bind(plot_dim))],'FontWeight','bold', 'FontSize',14, 'FontName','Times New Roman')
xlabel('number of bind repetitions')
ylabel('normalized similarity to initial vector')
%     ylim([-1 1]);
xlim([1 bind_repetitions]);
legend(lines,strrep(leg,'_',' '),'Location','northeast')
set(gcf,'color','w')
grid on    
set(gcf, 'Position', [700 700 950 320])
if exist('export_fig')
    export_fig([image_path 'repetitive_binding.pdf'],'-dpdf')
else
    saveas(gcf,[image_path 'repetitive_binding.png'])
end

%% plot 2D
figure()
counter=1;
for i=1:size(vsa_dict,1)
    switch vsa_dict{i}
        case choice_repBind
            subplot(2,ceil(numel(choice_repBind)/2),counter)
            counter=counter+1;
            imshow(flipdim(results_bind_unbind1_mean{i},1),[0 1])
            colormap jet;
            axis on;
            xticks(1:4:bind_repetitions)
            xticklabels(strsplit(num2str(1:4:bind_repetitions)))
            xtickangle(90)
            yticks(1:5:numel(dim_range_bind))
            yticklabels(strsplit(num2str(flipdim(dim_range_bind(1:5:numel(dim_range_bind)),2))))
            ylabel(['# dimensions'])
            xlabel(['# bind repetitions'])
            title(strrep(vsa_dict{i,1},'_',' '));
    end
end
colorbar('Position', [0.92  0.1  0.02  0.8])
set(gcf,'color','w')
set(gcf, 'Position', [700 700 1400 800])
sgtitle(['Binding-unbinding properties'],'FontWeight','bold', 'FontSize',16, 'FontName','Times New Roman')
if exist('export_fig')
    export_fig([image_path 'bind_unbind_2d.pdf'],'-dpdf') 
else
    saveas(gcf,[image_path 'bind_unbind_2d.png'])
end
