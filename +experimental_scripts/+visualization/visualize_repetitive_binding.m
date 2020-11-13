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
