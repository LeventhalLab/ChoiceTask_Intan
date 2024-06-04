% DEPENDENCIES
% intan_choice_task_navigation_utils-->find_rawdata_folders
% Helpers-->get_rats2process

%%
% this segment finds all the rat folders with electrophysiology data. It
% takes a minute to run, but then know which rat folders can be ignored
% probe_mapping_fname = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\ProbeSite_Mapping_MATLAB.xlsx';

% change the line below depending on where SharedX is mounted on each
% computer
intan_parent_directory = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';

rats_with_intan_sessions = find_rawdata_folders(intan_parent_directory);

% test_folder = '/Volumes/SharedX/Neuro-Leventhal/data/ChoiceTask/R0327/R0327-rawdata/R0327_20191218a/R0327_20191218_ChVE_191218_140437';
% cd(test_folder);

%%
% calculate the monopolar and bipolar LFPs
% at the end of this calculation, the LFP matrix is still in the order of
% the recorded channels, NOT the order of electrical sites along each probe
% shank

probe_mapping_fname = fullfile(intan_parent_directory, 'Probe Histology Summary', 'ProbeSite_Mapping_MATLAB.xlsx');

probe_type_sheet = 'probe_type';
probe_types = read_choicetask_xls_summary(probe_mapping_fname, probe_type_sheet);

ratIDs = get_rats2process(probe_mapping_fname);   % not sure we need this...

convert_to_microvolts = true;
target_Fs = 500;    % target downsampled sampling rate
for i_rat = 1 : length(rats_with_intan_sessions)
    
    intan_folders = rats_with_intan_sessions(i_rat).intan_folders;
    ratID = rats_with_intan_sessions(i_rat).ratID;
    
    for i_sessionfolder = 1 : length(intan_folders)
        [session_folder, ~, ~] = fileparts(intan_folders{i_sessionfolder});
        rd_metadata = parse_rawdata_folder(session_folder);
        pd_folder = create_processed_data_folder(rd_metadata, intan_parent_directory);
        
        full_lfp_name = fullfile(pd_folder, create_lfp_fname(rd_metadata, 'monopolar'));

        if ~any(probe_types.ratID == ratID)
            % if this rat isn't included in the excel workbook, skip.
            % Presumably, the data aren't any good
            continue
        end
        
        monopolar_lfp_calculated = false;
        if ~exist(full_lfp_name, 'file')

            textstr = sprintf('calculating monopolar LFP for %s', rd_metadata.session_name);
            disp(textstr)
        
            [lfp, actual_Fs] = calculate_monopolar_LFPs(intan_folders{i_sessionfolder}, target_Fs, convert_to_microvolts); % This file does not need to be probe_type specific
            
            save(full_lfp_name, 'lfp', 'actual_Fs');

            monopolar_lfp_calculated = true;

        end

        bp_lfpname = fullfile(pd_folder, create_lfp_fname(rd_metadata, 'bipolar'));

        if ~exist(bp_lfpname, 'file')

            if ~monopolar_lfp_calculated
                % if monopolar lfp file already existed but bipolar
                % doesn't, load the monopolar file
                load(full_lfp_name);
            end

            textstr = sprintf('calculating monopolar LFP for %s', rd_metadata.session_name);
            disp(textstr)
            
            probe_type = probe_types{probe_types.ratID == ratID, 2};
            [bipolar_lfp, intan2probe_mapping] = calculate_bipolar_LFPs(lfp, probe_type);

            save(bp_lfpname, 'bipolar_lfp', 'actual_Fs', 'probe_type', 'intan2probe_mapping', 'full_lfp_name');

        end
        
    end
    
end