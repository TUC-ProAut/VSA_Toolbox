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


% visualize results of capacity experiment 
% parameter

k_curve=5; % plot explicit curve of k bundled vectors 
threshold=0.99; 
plot_analytical_results = 0;

% load default mat file
if use_saved_data, load(fullfile(image_path, '../', 'bundle_capacity.mat')), end;

%% plot the dependency of the number of items in the memory and number of dimensions
if numel(item_memory_size)>1

    figure()
    cmap=colormap('lines');
    if max(item_memory_size)<10; item_memory_size=item_memory_size(1:3:end); end;
    
    for r = 1:numel(item_memory_size)
        s=subplot(ceil(numel(item_memory_size)/3),3,r);
        counter = 1;
        marker = '-';
        leg={};
        lines=[];
        for i=1:numel(vsa_dict)
            switch vsa_dict{i}
                case choice_cap
                    result = zeros([numel(k_range) 1]);
                    % average over all iterations (for better statistical
                    % robustness)
                    for k=1:numel(k_range)
                        results = median(results_capacity{i}(:,k,r,:),4); 
                        idx=find(results>=threshold);
                        if isempty(idx) == 0, result(k)=dim_range_cap(idx(1)); end;
                    end
                    valid_idx=find(result(:)>0);

                    % plot experimental results
                    L_main = plot(k_range(valid_idx),result(valid_idx),':','color',cmap(counter,:),'LineWidth',0.5);
                    hold on

                    % fit and plot experimental linear line
                    f = fit(k_range(valid_idx)',result(valid_idx),'poly1'); % fit results into polynom first order

                    L=plot(f, marker);
                    set(L,'color',cmap(counter,:),'LineWidth',2)
                    lines=[lines; L];
                    leg={leg{:} names_mapping_cap(vsa_dict{i,1})};
                    if max(item_memory_size)<10; title(['ratio N/D = ' num2str(item_memory_size(r))]); end;
                    if max(item_memory_size)>10; title(['item memory size = ' num2str(item_memory_size(r))]); end;
                    counter=counter+1;
                    
            end
        end
        xlabel('number of bundled vectors')
        ylabel('number of dimensions')
        ylim([0 1200])
        xlim([5 max(k_range)])
        legend(lines,strrep(leg,'_','-'),'Location','southeast','FontSize', 4)
        set(gcf,'color','w')
    %     title(['Minimum required number of dimensions to reach ' num2str(threshold*100) '% accuracy'],'FontWeight','bold', 'FontSize',16, 'FontName','Times New Roman')
    %     set(gcf, 'Position', [700 700 1000 400])
        grid on
          
    end

    if exist('export_fig')
        if min(item_memory_size)<1; export_fig([image_path 'bundle_capacity_memory_ratio.pdf'],'-dpdf'); end;
        if min(item_memory_size)>1; export_fig([image_path 'bundle_capacity_memory_size.pdf'],'-dpdf'); end;
    else
        if min(item_memory_size)<1; saveas(gcf,[image_path 'bundle_capacity_memory_ratio.png']); end;
        if min(item_memory_size)>1; saveas(gcf,[image_path 'bundle_capacity_memory_size.png']); end;
    end

    %% plot with fixed number of neighbors and different dimensions and item memory sizes
    figure()
    cmap=colormap('lines');
    fixed_k = 10;
    k_idx =  find(k_range==fixed_k);
    
    if min(item_memory_size)<1; is_ratio=1; else; is_ratio=0; end

    counter = 1;
    marker = '-';
    leg={};
    lines=[];
    vsa_results = [];
    vsas = {};
    for i=1:numel(vsa_dict)
            switch vsa_dict{i}
                case choice_cap
                    result = zeros([numel(item_memory_size) size(results_capacity,4)]);
                    for it=1:size(results_capacity{i},4)
                        for r = 1:numel(item_memory_size)
                            results = results_capacity{i}(:,k_idx,r,it);
                            idx=find(results>=threshold);
                            if isempty(idx) == 0, result(r,it)=dim_range_cap(idx(1)); end;
                        end
                    end

                    % average over all dimensions
                    result = mean(result,2);
                    valid_idx=find(result(:)>0);
                    
                    % write to matrix 
                    vsa_results(:,end+1) = result(valid_idx);
                    vsas{end+1} = vsa_dict{i};

                    % plot experimental results
                    L_main = plot(item_memory_size(valid_idx),result(valid_idx),':','color',cmap(counter,:),'LineWidth',0.5);
                    hold on

                    % fit and plot experimental linear line
                    ft = fittype('a + b*log(x)', 'dependent',{'y'},'independent',{'x'}, 'coefficients',{'a','b'});
                    f = fit(item_memory_size(valid_idx)',result(valid_idx),ft); % fit results into polynom first order

                    L=plot(f,item_memory_size(valid_idx),result(valid_idx));

                    set(L,'color',cmap(counter,:),'LineWidth',2,'Marker','none')
                    lines=[lines; L(end)];
                    leg={leg{:} names_mapping_cap(vsa_dict{i,1})};
                    counter=counter+1;
                    
            end
    end
    if is_ratio
        xlabel('ratio between number of items and number of dimenions [N/D]')
    else
        xlabel('item memory size')
    end
    ylabel('number of dimensions')
    ylim([0 700])
    legend(lines,strrep(leg,'_','-'),'Location','southeast','FontSize', 4)
    set(gcf,'color','w')
    set(gca, 'XScale', 'log')
    title(['Minimum required number of dimensions to reach ' num2str(threshold*100) '% accuracy with k=' num2str(fixed_k)],'FontWeight','bold', 'FontSize',16, 'FontName','Times New Roman')
    set(gcf, 'Position', [700 700 1000 400])
    grid on
          
    if exist('export_fig')
        if min(item_memory_size)<1; export_fig([image_path 'bundle_capacity_memory_ratio_fix_k.pdf'],'-dpdf'); end;
        if min(item_memory_size)>1; export_fig([image_path 'bundle_capacity_memory_size_fix_k.pdf'],'-dpdf'); end;
    else
        if min(item_memory_size)<1; saveas(gcf,[image_path 'bundle_capacity_memory_ratio_fix_k.png']); end;
        if min(item_memory_size)>1; saveas(gcf,[image_path 'bundle_capacity_memory_size_fix_k.png']); end;
    end
end 

%% plot results of one item memory size
item_size = 1000;
memory_idx = find(item_memory_size==item_size);
% if the searched item memory size is in the results, plot it
if numel(memory_idx)>0
    %% plot 2D results (increasing number of dimensions and number of neighbors)
    figure()
    counter = 1;
    arrow_offset = [-0.01 -0.009];
    arrow_length = [0.04 0.06];

    for i=1:size(vsa_dict,1)
        switch vsa_dict{i}
            case choice_cap
                if numel(size(results_capacity{i}))>3
                    results_capacity_mean = mean(results_capacity{i},4); 
                else
                    results_capacity_mean = results_capacity{i}; 
                end;
                s=subplot(2,ceil(numel(choice_cap)/2),counter);
                counter=counter+1;
                imshow(flipdim(squeeze(results_capacity_mean(:,:,memory_idx)),1))
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

    result=zeros([numel(k_range) numel(vsa_dict)]);
    result_analytical=zeros([numel(k_range) numel(vsa_dict)]);
    figure()
    lines=[];
    cmap=colormap('lines');
    marker = '-';
    leg={};
    nn=15; % number of neighbors for computing the minimum requiered number of dimensions to reach specific accuracy
    min_dim_nn=containers.Map;
    counter=1;
    appr_grad_cap=zeros([numel(choice_cap) 1]);
    disp('Bundling Capacity: ')
    for i=1:numel(vsa_dict)
        for k=1:numel(k_range)
            % average first and compute dimension second
            idx = find(mean(results_capacity{i}(:,k,memory_idx,:),4)>=threshold);
            if isempty(idx)==0, result(k,i)=dim_range_cap(idx(1)); end;
        end

        switch vsa_dict{i}
            case choice_cap
                valid_idx = find(result(:,i)>0);
                valid_idx_a = find(result_analytical(:,i)>0);
                % plot experimental results
                L_main = plot(k_range(valid_idx),result(valid_idx,i),':','color',cmap(counter,:),'LineWidth',0.5);
                hold on

                % fit and plot experimental linear line
                f = fit(k_range(valid_idx)',result(valid_idx,i),'poly1'); % fit results into polynom first order
                appr_grad_cap(counter)=f.p1;
                disp([strrep(vsa_dict{i},'_',' ')  9 'Minimum required number of dimension to reach accuracy of ' num2str(threshold) ' is: ' num2str(round(f(nn),-1))])
                min_dim_nn(vsa_dict{i})=f(nn);
                if counter>7, marker = '-.'; end
                L = plot(f, marker);
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
end



