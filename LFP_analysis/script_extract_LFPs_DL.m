% script to calculate LFPs for all of Jen's rats; store in files in
% the processed data folders

parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB.xlsx';
summary_xls_dir = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);

sessions_to_ignore = {'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a','R0427_20220919a' }; % R0425_20220728a debugging because the intan side was left on for 15 hours;

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER
% INFORMATION OUT OF THAT SPREADSHEET

%[rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();
ratIDs=probe_types.ratID;
target_Fs = 500;   % in Hz, target LFP sampling rate after decimating the raw signal
convert_to_microvolts = true;

num_rats = length(ratIDs);

for i_rat = 1 : num_rats
    ratID = ratIDs{i_rat};
    rat_folder = fullfile(parent_directory, ratID);

    if ~isfolder(rat_folder)
        continue;
    end

    probe_type = probe_types{probe_types.ratID == ratID, 2}; % changed probe_types.RatID to probe_types.ratID due to error
    processed_folder = find_data_folder(ratID, 'processed', parent_directory);
    rawdata_folder = find_data_folder(ratID, 'rawdata', parent_directory);
    session_dirs = dir(fullfile(rawdata_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);

    for i_session = 1 : num_sessions
        
        session_name = session_dirs(i_session).name;
        cur_dir = fullfile(session_dirs(i_session).folder, session_name);
        cd(cur_dir)

        phys_folder = find_physiology_data(cur_dir);

        if isempty(phys_folder)
            sprintf('no physiology data found for %s', session_name)
            continue
        end

        if any(strcmp(session_name, sessions_to_ignore)) % Jen added this in to ignore sessions as an attempt to debut "too many input arguments"
            continue;
        end

        lfp_fname = strcat(session_name, '_monopolar_lfp.mat');
        processed_session_folder = fullfile(processed_folder, session_name);
        full_lfp_name = fullfile(processed_session_folder, lfp_fname);
        if ~isfolder(processed_session_folder)
            mkdir(processed_session_folder)
        end
        if isfile(full_lfp_name) == 1 % the lfp_fname exists in the processed folder but this section is not recognizing it exists so still writes the file.
            sprintf('%s already calculated, skipping', lfp_fname)
            continue
        else
            sprintf('working on %s', session_name)
            [lfp, actual_Fs] = calculate_monopolar_LFPs_DL(phys_folder, target_Fs, convert_to_microvolts);
            save(full_lfp_name, 'lfp', 'actual_Fs', 'convert_to_microvolts');
        end

        %sprintf('working on %s', session_name)
        %[lfp, actual_Fs] = calculate_monopolar_LFPs_DL(phys_folder, target_Fs, convert_to_microvolts);

        %    %commented out for testing purposes 7/16/24
        %save(full_lfp_name, 'lfp', 'actual_Fs', 'convert_to_microvolts');
        % 
        % 
        % % Set artifact rejection parameters THIS IS THE NEW SCRIPT PURPOSED
        % % FOR ARTIFACT DETECTION
        % threshold = 1000;  % amplitude threshold in microvolts
        % min_duration = actual_Fs / 10;  % minimum duration for artifact in samples (e.g., 100 ms)
        % 
        % % Perform artifact rejection
        % [clean_lfp, artifact_mask, artifact_timestamps] = reject_artifacts(lfp, threshold, min_duration);
        % 
        % % Save the clean LFP data
        % full_lfp_name = fullfile(processed_session_folder, lfp_fname);
        % save(full_lfp_name, 'lfp', 'clean_lfp', 'actual_Fs', 'convert_to_microvolts', 'artifact_mask', "artifact_timestamps");

    end

end