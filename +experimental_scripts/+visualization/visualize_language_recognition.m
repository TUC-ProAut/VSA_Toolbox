% visualize results of language recognition experiment 

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

