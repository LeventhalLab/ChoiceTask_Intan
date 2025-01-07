% script to calculate LFPs for all of Jen's rats; store in files in
% the processed data folders

parent_directory = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls_dir = fullfile(parent_directory, 'Probe Histology Summary');
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
threshold = 1000;  % amplitude threshold in microvolts
min_duration = target_Fs / 10;  % minimum duration for artifact in samples (e.g., 100 ms)
% min_duration doesn't look like it gets used
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
        %check to see if lfp exists, if it does, check for artifacts, if
        %not calculate lfps
        if isfile(full_lfp_name) == 1 
            sprintf('LFPs calculated for %s', full_lfp_name)
            variables_in_file = who('-file', full_lfp_name);

            if ~ismember('convert_to_microvolts', variables_in_file)
                % convert_to_microvolts wasn't written into all the lfp
                % files, but the conversion was used
                convert_to_microvolts = true;
                save(full_lfp_name, 'convert_to_microvolts', '-append');
            end
            %Check to see if artifact mask already found skip if done 
            if ismember('artifact_mask', variables_in_file)
                fprintf('%s already contains artifact_mask, skipping\n', lfp_fname);
                continue;
            else
                fprintf('Appending artifact_mask to %s\n', lfp_fname);
                % Load existing LFP data
                load(full_lfp_name, 'lfp', 'actual_Fs', 'convert_to_microvolts');
                % Perform artifact rejection:: Removed minimum duration
                % requirement 7/17/24
                [artifact_mask, artifact_timestamps] = reject_artifacts(lfp, threshold);
                % Append the artifact_mask and artifact_timestamps to the file
                save(full_lfp_name, 'artifact_mask', 'artifact_timestamps', '-append');
            end
        else
            %Run both LFP calculations and artifact detection
            sprintf('working on calculating LFPs and artifact detection for %s', session_name)
            [lfp, actual_Fs] = calculate_monopolar_LFPs_DL(phys_folder, target_Fs, convert_to_microvolts);
            [~, artifact_mask, artifact_timestamps] = reject_artifacts(lfp, threshold, min_duration);
            save(full_lfp_name, 'lfp', 'actual_Fs', 'convert_to_microvolts', 'artifact_mask', 'artifact_timestamps');
        end

    end

end