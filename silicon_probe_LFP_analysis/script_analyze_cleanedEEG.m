% script to check/analyze cleaned EEG files
t_window = [-2.5, 2.5];    % time windows for peri-event lfp extraction
event_list = {'cueOn', 'centerIn', 'tone', 'centerOut' 'sideIn', 'sideOut', 'foodClick', 'foodRetrieval'};
lfp_type = 'bipolar';

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
    intan2probe_mapping = probe_site_mapping_all_probes(probe_type);

    for i_session = 1 : num_sessions

        session_name = session_dirs(i_session).name;

        if ~ismember(session_name, valid_monopolar_channels.Properties.VariableNames)
            % this session isn't included in the channel quality table
            sprintf('%s is not in the valid channels table', session_name)
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

        EEG_preASR_fname = sprintf('%s_EEGpreASR.mat', session_name);
        EEG_preASR_fname = fullfile(processed_folder, session_name, EEG_preASR_fname);

        load(orig_EEG_fname)
        load(EEG_preASR_fname)

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
        samp_window = round(t_window * Fs);
        samples_per_event = range(samp_window) + 1;
        fb = cwtfilterbank('signallength', samples_per_event, ...
            'samplingfrequency', Fs, ...
            'wavelet','amor',...
            'frequencylimits', [1, 100]);

        for i_event = 1 : length(event_list)
            event_name = event_list{i_event};

            perievent_data_cleaned = extract_perievent_data_fromEEG(cleaned_EEG, trials, event_name, t_window, invalid_times, Fs);
            perievent_data_orig = extract_perievent_data_fromEEG(EEG, trials, event_name, t_window, invalid_times, Fs);
            perievent_data_preASR = extract_perievent_data_fromEEG(EEG_preASR, trials, event_name, t_window, invalid_times, Fs);
            n_channels = size(perievent_data_orig, 2);
    
            % calculate scalograms
            event_ts = extract_trial_ts(trials, event_name);

            scalo_folder = create_scalo_folder(session_name, event_name, choicetask_path);
            if ~exist(scalo_folder, 'dir')
                mkdir(scalo_folder)
            end

            for i_channel = 1 : n_channels
                if isfield(cleaned_EEG.etc, 'clean_channel_mask')
                    if ~cleaned_EEG.etc.clean_channel_mask(i_channel)
                        sprintf('channel %d was removed by clean_artifacts for %s', i_channel, session_name)
                        continue
                    end
                end
                probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);
                [shank_num, site_num] = get_shank_and_site_num(probe_lfp_type, i_channel);

                scalo_name = sprintf('%s_scalos_%s_%s_shank%02d_site%02d_eeglab.mat',session_name, lfp_type, event_name, shank_num, site_num);
                scalo_name = fullfile(scalo_folder, scalo_name);

                % if exist(scalo_name, 'file')
                %     continue
                % end

                if isfield(cleaned_EEG.etc, 'clean_channel_mask')
                    cleanedEEG_channel = sum(cleaned_EEG.etc.clean_channel_mask(1:i_channel));
                else
                    cleanedEEG_channel = i_channel;
                end
                event_triggered_lfps_cleaned = squeeze(perievent_data_cleaned(:, cleanedEEG_channel, :));
                event_triggered_lfps_orig = squeeze(perievent_data_orig(:, cleanedEEG_channel, :));
                event_triggered_lfps_preASR = squeeze(perievent_data_preASR(:, cleanedEEG_channel, :));
                clean_sample_mask = cleaned_EEG.etc.clean_sample_mask;

                sprintf('calculating scalograms for %s, %s, channel %d', session_name, event_name, i_channel)
                [event_related_scalos, ~, coi] = trial_scalograms(event_triggered_lfps_cleaned, fb);

                save(scalo_name, 'event_related_scalos', ...
                    'event_triggered_lfps_cleaned', ...
                    'event_triggered_lfps_orig',...
                    'event_triggered_lfps_preASR', ...
                    'clean_sample_mask',...
                    'fb', 'coi', ...
                    't_window', ...
                    'i_channel', ...
                    'event_ts', ...
                    'trials', ...
                    'probe_type', ...
                    'intan2probe_mapping', ...
                    'valid_bipolar_channels', ...   % valid_bipolar_channels is based on whether a monopolar channel was manually marked as bad in preprocessing
                    'invalid_times', ...            % invalid_times are based on manually identified disconnects in preprocessing
                    'cleanedEEG_channel',...        % channel index in the cleaned_EEG data array; channel index in the original EEG data array is just i_channel
                    'qc_channels');
% is there anything in cleaned_EEG that should be saved besides the data?

            end

        end

    end

end