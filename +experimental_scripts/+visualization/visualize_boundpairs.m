%% visualize bindpairs results

% load mat file
if use_saved_data, load(fullfile(image_path, '../', 'boundpairs.mat')), end;

k_curve=5; % plot explicit curve of k nearest neighbors
threshold=0.99;


%% plot specific curve of k role filler pairs

% plot results of capacity 2 experiment
figure()
lines=[];
cmap=colormap('lines');
leg={};
counter=1;
for i=1:size(vsa_dict,1)
    switch vsa_dict{i}
        case choice_boundpairs
            L=shadedErrorBar(dim_range_pairs,results_bindpairs_mean{i}(:,k_curve),results_bindpairs_var{i}(:,k_curve),'lineprops',{'color',cmap(counter,:)});
            lines=[lines; L.mainLine];
            leg={leg{:} strrep(vsa_dict{i},'_',' ')};% ' d=' num2str(vsa_dims(i))];
            hold on;
    end
    counter=counter+1;
end
title(['Increasing Number of Dimensions with ' num2str(k_range(k_curve)) ' role-filler Pairs and ' num2str(item_memory_size) ' items'],'FontWeight','bold', 'FontSize',14, 'FontName','Times New Roman')
xlabel('Number of dimensions')
ylabel('Probability of correct query answer')
xlim([1 1000])
legend(lines,strrep(leg,'_',' '),'Location','southeast')
set(gcf,'color','w')
set(gcf, 'Position', [700 700 900 600])
grid on
if exist('export_fig')
    export_fig([image_path 'boundpairs_accuracy_with_' num2str(k_range(k_curve)) '_pairs.pdf'],'-dpdf') 
else
    saveas(gcf,[image_path 'boundpairs_accuracy_with_' num2str(k_range(k_curve)) '_pairs.png'])
end


%% plot 2D results (increasing number of dimensions and number of pairs)
figure()
title('k role-filler paris - probability of correct answers','FontWeight','bold', 'FontSize',16, 'FontName','Times New Roman')
counter=1;
for i=1:size(vsa_dict,1)
    switch vsa_dict{i}
        case choice_boundpairs
            subplot(2,ceil(numel(choice_boundpairs)/2),counter)
            counter=counter+1;
            imshow(flipdim(results_bindpairs_mean{i},1),[0 1])
            colormap jet;
            axis on;
            xticks(1:4:numel(k_range))
            xticklabels(strsplit(num2str(k_range(1:4:numel(k_range)))))
            xtickangle(90)
            yticks(1:5:numel(dim_range_pairs))
            yticklabels(strsplit(num2str(flipdim(dim_range_pairs(1:5:numel(dim_range_pairs)),2))))
            ylabel(['# dimensions'])
            xlabel(['# pairs'])
            title(names_mapping_boundpairs(vsa_dict{i,1}));
    end
end
colorbar('Position', [0.92  0.1  0.01  0.8])
set(gcf,'color','w')
sgtitle(['Accuracies as Heatmaps'],'FontWeight','bold', 'FontSize',16, 'FontName','Times New Roman')
set(gcf, 'Position', [700 700 900 400])
if exist('export_fig')
    export_fig([image_path 'boundpairs_2D_results.pdf'],'-dpdf') 
else
    saveas(gcf,[image_path 'boundpairs_2D_results.png'])
end


%% plot minimum required number of dimenesion to reach threshold accuracy

result=zeros([numel(k_range) numel(vsa_dict)]);
figure()
lines=[];
cmap=colormap('lines');
marker = '-';
leg={};
nn=15; % number of neighbors for computing the minimum requiered number of dimensions to reach 100% accuracy with it
counter=1;
appr_grad_bb=zeros([numel(choice_boundpairs) 1]);
disp('Bound pairs: ')
for i=1:numel(vsa_dict)
    for l=1:numel(k_range)
        idx=find(results_bindpairs_mean{i}(:,l)>=threshold);
        if isempty(idx)==0, result(l,i)=dim_range_pairs(idx(1));, end;
    end
    
    switch vsa_dict{i}
        case choice_boundpairs
            valid_idx=find(result(:,i)>0);
            L_main=plot(k_range(valid_idx),result(valid_idx,i),':','color',cmap(counter,:),'LineWidth',0.5);
            hold on
            f=fit(k_range(valid_idx)',result(valid_idx,i),'poly1');
            disp([strrep(vsa_dict{i},'_',' ')  9 'Minimum required number of dimension to reach accuracy of ' num2str(threshold) ' is: ' num2str(round(f(nn),-1))])
            min_dim_nn(vsa_dict{i})=f(nn);
            appr_grad_bb(counter)=f.p1;
            if counter>7, marker = '-.'; end
            L=plot(f,marker);
            set(L,'color',cmap(counter,:),'LineWidth',2)
            lines=[lines; L];
            leg={leg{:} names_mapping_boundpairs(vsa_dict{i,1})};
            counter=counter+1;
    end


    xlabel('number of bundled pairs')
    ylabel('number of dimensions')
%     ylim([0 max(dim_range_pairs)])
    ylim([0 1200])
    xlim([1 max(k_range)])
    legend(lines,strrep(leg,'_',' '),'Location','southeast')
    set(gcf,'color','w')
    set(gcf, 'Position', [700 700 900 400])
    title(['Minimum required number of dimensions to reach ' num2str(threshold*100) '% accuracy'],'FontWeight','bold', 'FontSize',16, 'FontName','Times New Roman')
    grid on
    

end
if exist('export_fig')
    export_fig([image_path 'boundpairs_min_dim_at_thresh_of_' replace(num2str(threshold),'.','_') '.pdf'],'-dpdf') 
else
    saveas(gcf,[image_path 'boundpairs_min_dim_at_thresh_of_' replace(num2str(threshold),'.','_') '.png'])
end



