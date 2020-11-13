%% save results

if check_bundle_capacity
    save([results_path 'bundle_capacity_' replace(datestr(datetime),{':', ' ','-'},'_') '.mat'],...
        'results_capacity_mean',...
        'results_capacity_var',...
        'dim_range_cap',...
        'k_range',...
        'item_memory_size',...
        'number_iterations',...
        'vsa_dict')
end

if check_boundpairs
    save([results_path 'boundpairs_' replace(datestr(datetime),{':', ' ','-'},'_') '.mat'],...
        'results_bindpairs_mean',...
        'results_bindpairs_var',...
        'dim_range_pairs',...
        'k_range',...
        'item_memory_size',...
        'number_iterations',...
        'vsa_dict')
end


if check_repetitive_binding
    save([results_path 'repetitive_binding_' replace(datestr(datetime),{':', ' ','-'},'_') '.mat'],...
        'results_bind_unbind1_mean',...
        'results_bind_unbind2_mean',...
        'results_bind_unbind1_var',...
        'results_bind_unbind2_var',...
        'bind_repetitions',...
        'dim_range_bind',...
        'number_iterations',...
        'vsa_dict')
end

if check_langRec
    save([results_path 'language_recognition_' replace(datestr(datetime),{':', ' ','-'},'_') '.mat'],...
        'results_langRec',...
        'results_langRec_VSAs',...
        'dim_range_lang',...
        'vsa_dict')
end
