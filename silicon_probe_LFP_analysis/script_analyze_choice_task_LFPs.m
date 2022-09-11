probe_mapping_fname = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\ProbeSite_Mapping_MATLAB.xlsx';

intan_parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';

rats_with_intan_sessions = find_rawdata_folders(intan_parent_directory);

% test_folder = '/Volumes/SharedX/Neuro-Leventhal/data/ChoiceTask/R0327/R0327-rawdata/R0327_20191218a/R0327_20191218_ChVE_191218_140437';
% cd(test_folder);

%%
for i_rat = 1 : length(rats_with_intan_sessions)
    
    intan_folders = rats_with_intan_sessions(i_rat).intan_folders;
    
    for i_sessionfolder = 1 : length(intan_folders)
        rd_metadata = parse_rawdata_folder(intan_folders{i_sessionfolder});
        pd_folder = create_processed_data_folder(rd_metadata, intan_parent_directory);
        
        lfp_fname = fullfile(pd_folder, create_lfp_fname(rd_metadata));
        
        if exist(lfp_fname, 'file')
            continue
        end
        
        [lfp, actual_Fs] = calculate_monopolar_LFPs(intan_folders{i_sessionfolder}, 500); % This file should not need to be probe_type specific JM 20220909
        
        save(lfp_fname, 'lfp', 'actual_Fs');
        
    end
    
end


% lfp_name = 
probe_anatomy_info = read_probe_mapping_xls(probe_mapping_fname); % Still not clear what Dan was trying to accomplish here. 
% The probe mapping file basically makes a table of R0326 even if the
% cur_sheet is for R0425?