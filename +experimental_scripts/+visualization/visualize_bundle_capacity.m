% visualize results of capacity experiment 
% parameter

k_curve=5; % plot explicit curve of k bundled vectors 
threshold=0.99; 
plot_analytical_results = 0;

% load default mat file
if use_saved_data, load(fullfile(image_path, '../', 'bundle_capacity.mat')), end;

%% plot results of the bundle capacity experiment at specific number of neighbors k

figure()
lines=[];
cmap=colormap('lines');
leg={};
counter=1;
for i=1:size(vsa_dict,1)
    switch vsa_dict{i}
        case choice_cap
            L=shadedErrorBar(dim_range_cap,results_capacity_mean{i}(:,k_curve),results_capacity_var{i}(:,k_curve),'lineprops',{'color',cmap(counter,:)});
            lines=[lines; L.mainLine];
            leg={leg{:} strrep(vsa_dict{i,1},'_',' ')};
            hold on;
    end
    counter = counter+1;
end
title(['Increasing Number of Dimensions with ' num2str(k_range(k_curve)) ' neighbors and ' num2str(item_memory_size) ' items'],'FontWeight','bold', 'FontSize',16, 'FontName','Times New Roman')
xlabel('Number of dimensions')
ylabel('Probability of correct query answer')
xlim([1 1000])
legend(lines,strrep(leg,'_',' '),'Location','southeast')
set(gcf,'color','w')
set(gcf, 'Position', [700 700 900 600])
grid on
if exist('export_fig')
    export_fig([image_path 'bundle_capacity_' num2str(k_range(k_curve)) '_neighbors.pdf'],'-dpdf') 
else
    saveas(gcf,[image_path 'bundle_capacity_' num2str(k_range(k_curve)) '_neighbors.png'])
end


%% plot 2D results (increasing numbro of dimensions and number of neighbors
figure()
counter=1;
arrow_offset=[-0.01 -0.009];
arrow_length=[0.04 0.06];
for i=1:size(vsa_dict,1)
    switch vsa_dict{i}
        case choice_cap
            s=subplot(2,ceil(numel(choice_cap)/2),counter);
            counter=counter+1;
            imshow(flipdim(results_capacity_mean{i},1))
            colormap jet;
            axis on;
            xticks(1:4:numel(k_range))
            xticklabels(strsplit(num2str(k_range(1:4:numel(k_range)))))
            xtickangle(90)
            yticks(1:5:numel(dim_range_cap))
            yticklabels(strsplit(num2str(flipdim(dim_range_cap(1:5:numel(dim_range_cap)),2))))
            ylabel(['# dimensions'])
            xlabel(['# bundled vectors'])
            title(names_mapping_cap(vsa_dict{i,1}));
    end
end
colorbar('Position', [0.92  0.1  0.01  0.8])
set(gcf,'color','w')
set(gcf, 'Position', [700 700 900 400])
sgtitle(['Accuracies as Heatmaps'],'FontWeight','bold', 'FontSize',16, 'FontName','Times New Roman')
if exist('export_fig')
    export_fig([image_path 'bundle_capacity_2D_results.pdf'],'-dpdf') 
else
    saveas(gcf,[image_path 'bundle_capacity_2D_results.png'])
end

%% plot minimum required number of dimenesion to reach threshold accuracy

% plot each VSA except the thinned BSDC
ex_idx = find(contains(choice_cap,'BSDC_THIN'));
choice_cap{ex_idx} = '-';

result=zeros([numel(k_range) numel(vsa_dict)]);
result_analytical=zeros([numel(k_range) numel(vsa_dict)]);
figure()
lines=[];
cmap=colormap('lines');
marker = '-';
leg={};
nn=15; % number of neighbors for computing the minimum requiered number of dimensions to reach 100% accuracy with it
min_dim_nn=containers.Map;
counter=1;
appr_grad_cap=zeros([numel(choice_cap) 1]);
disp('Bundling Capacity: ')
for i=1:numel(vsa_dict)
    for l=1:numel(k_range)
        idx=find(results_capacity_mean{i}(:,l)>=threshold);
        if isempty(idx)==0, result(l,i)=dim_range_cap(idx(1)); end;
        if plot_analytical_results
            idx_analyt=find(round(results_capacity_analytical{i}(:,l),2)>=threshold);
            if isempty(idx_analyt)==0, result_analytical(l,i)=dim_range_cap(idx_analyt(1)); end;
        end
    end
    
    switch vsa_dict{i}
        case choice_cap
            valid_idx=find(result(:,i)>0);
            valid_idx_a=find(result_analytical(:,i)>0);
            % plot experimental results
            L_main=plot(k_range(valid_idx),result(valid_idx,i),':','color',cmap(counter,:),'LineWidth',0.5);
            hold on
            
            % fit and plot experimental linear line
            f=fit(k_range(valid_idx)',result(valid_idx,i),'poly1'); % fit results into polynom first order
            appr_grad_cap(counter)=f.p1;
            disp([strrep(vsa_dict{i},'_',' ')  9 'Minimum required number of dimension to reach accuracy of ' num2str(threshold) ' is: ' num2str(round(f(nn),-1))])
            min_dim_nn(vsa_dict{i})=f(nn);
            if counter>7, marker = '-.'; end
            L=plot(f, marker);
            set(L,'color',cmap(counter,:),'LineWidth',2)
            
            % fit and plot analytical results
            if numel(result_analytical(valid_idx_a,i))>2 && plot_analytical_results==1
                f_analyt=fit(k_range(valid_idx_a)',result_analytical(valid_idx_a,i),'poly1');
                L_analyt=plot(f_analyt,'--');
                set(L_analyt,'color',cmap(counter,:),'LineWidth',2)
                lines=[lines; L; L_analyt];
                leg={leg{:} vsa_dict{i,1} [vsa_dict{i,1} ' analytical']};
            else
                lines=[lines; L];
                leg={leg{:} names_mapping_cap(vsa_dict{i,1})};
            end
            
            counter=counter+1;
    end

 
    xlabel('number of bundled vectors')
    ylabel('number of dimensions')
%     ylim([0 max(dim_range_cap)])
    ylim([0 1200])
    xlim([5 max(k_range)])
    legend(lines,strrep(leg,'_','-'),'Location','southeast')
    set(gcf,'color','w')
    title(['Minimum required number of dimensions to reach ' num2str(threshold*100) '% accuracy'],'FontWeight','bold', 'FontSize',16, 'FontName','Times New Roman')
    set(gcf, 'Position', [700 700 1000 400])
    grid on
    
end
if exist('export_fig')
    export_fig([image_path 'bundle_capacity_min_dim_at_thresh_of_' replace(num2str(threshold),'.','_') '.pdf'],'-dpdf') 
else
    saveas(gcf,[image_path 'bundle_capacity_min_dim_at_thresh_of_' replace(num2str(threshold),'.','_') '.png'])
end




