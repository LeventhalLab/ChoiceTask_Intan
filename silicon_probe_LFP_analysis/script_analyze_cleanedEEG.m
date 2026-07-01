% script to check/analyze cleaned EEG files
event_name = 'centerOut';  % hard-coded for testing

choicetask_path = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';
summary_xls_dir = fullfile(choicetask_path, 'Probe Histology Summary');
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls = fullfile(summary_xls_dir, summary_xls);

qc_xls = 'channels_qc_final_DL.xlsx';
qc_xls = fullfile(summary_xls_dir, qc_xls);

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);

unit_csv_path = choicetask_path;
unit_csv_name = 'AllROIs_unitTable.csv';
unit_csv_name = fullfile(unit_csv_path, unit_csv_name);

unit_table = read_unit_info_from_csv(unit_csv_name);
unit_table_updated = clean_units_table(unit_table);

[rat_nums, ratIDs] = get_valid_choicetraskprobe_rats();    % these are the cleanest recordings

num_rats = length(ratIDs);

for i_rat = 1 : num_rats
    ratID = ratIDs{i_rat};
    rat_folder = fullfile(choicetask_path, ratID);

    if ~isfolder(rat_folder)
        continue;
    end

    processed_folder = find_data_folder(ratID, 'processed', choicetask_path);
    session_dirs = dir(fullfile(processed_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);

    valid_monopolar_channels = readtable(qc_xls,sheet=ratID);
    probe_type = probe_types.probe_type(probe_types.ratID==ratID);

    for i_session = 1 : num_sessions

        session_name = session_dirs(i_session).name;

        if ~ismember(session_name, valid_monopolar_channels.Properties.VariableNames)
            % this session isn't included in the channel quality table
            sprintf('%s is not in the valid channels table')
            continue
        end

        % load trials structure
        trials_name = sprintf('%s_trials.mat', session_name);
        trials_name = fullfile(processed_folder, session_name, trials_name);

        if ~exist(trials_name, 'file')
            sprintf('no trials structure found for %s', session_name)
            continue
        end

        load(trials_name)   % contains the structure "trials"

        cleaned_EEG_fname = sprintf('%s_cleanedEEG.mat', session_name);
        cleaned_EEG_fname = fullfile(processed_folder, session_name, cleaned_EEG_fname);

        orig_EEG_fname = sprintf('%s_EEG.mat', session_name);
        orig_EEG_fname = fullfile(processed_folder, session_name, orig_EEG_fname);

        load(orig_EEG_fname)

        if exist(cleaned_EEG_fname, 'file')
            sprintf('loading cleaned LFPs for %s', session_name)
            load(cleaned_EEG_fname);
        else
            sprintf('no cleaned LFP file for for %s', session_name)
            continue
        end

        qc_channels = valid_monopolar_channels.(session_name);
        [valid_bipolar_channels, invalid_times] = valid_bipolar_from_qc(valid_monopolar_channels, session_name, probe_type);

        % vis_artifacts(cleaned_EEG, EEG)
        Fs = cleaned_EEG.srate;
        perievent_data = extract_perievent_data_fromEEG(cleaned_EEG, trials, event_name, t_window, invalid_times, Fs);

    end

end