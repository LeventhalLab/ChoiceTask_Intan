% script to correlate LFP features with reaction time and movement time
% also need to average within rats, then across rats for each region

% in this version, the event-related LFPs have all been extracted already
% and stored in separate .mat files

% trial_features = {'all', 'correct', 'wrong', 'moveleft', 'moveright'};
clear all
trial_features = {'correct'};
n_trialfeatures = length(trial_features);

rejection_threshold = 2000;   % in microvolts

parent_directory = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls_dir = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);
qualitycheck_xls = 'channels_qc_final.xlsx';
qualitycheck_xls = fullfile(summary_xls_dir, qualitycheck_xls);

% change the line below to allow looping through multiple trial types,
% extract left vs right, etc.
trials_to_analyze = 'correct';
lfp_types = {'bipolar'};
lfp_type = 'bipolar';
% trials_to_analyze = 'all';

t_window = [-1, 1];
t_ticks = [t_window(1), 0, t_window(2)];
event_list = {'cueOn', 'centerIn', 'tone', 'centerOut' 'sideIn', 'sideOut', 'foodClick', 'foodRetrieval'};

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);

[rat_nums, ratIDs] = get_valid_choicetraskprobe_rats();    % these are the cleanest recordings

num_rats = length(ratIDs);

for i_rat = 1 : num_rats
    ratID = ratIDs{i_rat};
    rat_folder = fullfile(parent_directory, ratID);

    if ~isfolder(rat_folder)
        continue;
    end

    probe_type = probe_types{probe_types.ratID == ratID, 2};
    processed_folder = find_data_folder(ratID, 'processed', parent_directory);
    session_dirs = dir(fullfile(processed_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);

    session_qc_check = readtable(qualitycheck_xls, sheet=ratID);
    rat_sheet_name = strcat(ratID, '_finished');
    site_anatomy_table = read_Jen_xls_summary(summary_xls, rat_sheet_name);

    for i_session = 1 : num_sessions
        session_name = session_dirs(i_session).name;
        cur_dir = fullfile(session_dirs(i_session).folder, session_name);
        cd(cur_dir)

        trials_file = dir('*_trials.mat');
        if length(trials_file) ~= 1
            % load a sample scalogram file instead of the trials file
            scalo_folder = create_scalo_folder(session_name, 'cueOn', parent_directory);
            test_scalo_name = sprintf('%s_scalos_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, 'cueOn', 1, 1);
            test_scalo_name = fullfile(scalo_folder, test_scalo_name);
            if ~exist(test_scalo_name)
                sprintf('no scalogram file for %s', session_name)
                continue
            end
            trials_struct = load(test_scalo_name, 'trials');
        else
            % load the "trials" structure
            trials_struct = load(trials_file.name);
        end
        trials = trials_struct.trials;

        for i_lfptype = 1 : length(lfp_types)
            % lfp_type = 'bipolar';
            lfp_type = lfp_types{i_lfptype};
            if strcmpi(lfp_type, 'monopolar')
                power_clims = [2, 10];
                mrl_clims = [0, 1];
            else
                power_clims = [0, 5];
                mrl_clims = [0, 1];
            end

            probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);

            for i_trialfeature = 1 : n_trialfeatures
                trial_feature = trial_features{i_trialfeature};
                [trials_with_feature, valid_trial_flags] = extract_trials_by_features(trials, trial_feature);
                if ~any(valid_trial_flags)
                    % if no trials with these features for this session, continue the loop
                    continue
                end
                trials_with_feature_idx = find(valid_trial_flags);

                for i_event = 1 : length(event_list)
                    event_name = event_list{i_event};
                    scalo_folder = create_scalo_folder(session_name, event_name, parent_directory);
    
                    if ~exist(scalo_folder, 'dir')
                        continue
                    end
    
                    sprintf('working on session %s, event %s, %s', session_name, event_name, lfp_type)
    
                    % read in the scalograms for a site
    
                    switch lower(probe_type)
                        case 'nn8x8'
                            % 8 shanks with 8 sites each
                            sites_per_shank = 8;
                            n_shanks = 8;
                            cols_per_shank = 1;
                        case 'assy156'
                            sites_per_shank = 16;
                            n_shanks = 2;
                            cols_per_shank = 2;
                        case 'assy236'
                            sites_per_shank = 16;
                            n_shanks = 2;
                            cols_per_shank = 2;
                    end
    
                    [amp_map, probe_map] = probe_channel_mappings(probe_type);
    
                    n_monochannels = sites_per_shank * n_shanks * cols_per_shank;
                    % create figure with appropriate number of panels
                    switch lower(lfp_type)
                        case 'monopolar'
                            n_rows = sites_per_shank;
                        case 'bipolar'
                            n_rows = sites_per_shank - 1;
                    end
    
                    try
                        valid_channels = valid_channels_from_qc(session_qc_check, session_name);
                        % sometimes the valid channels aren't marked for this session in the
                        % quality check excel spreadsheet
                    catch
                        valid_channels = 1 : n_monochannels;
                    end
                    % test_scalo_name = sprintf('%s_scalos_%s_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, trial_feature, event_name, 1, 1);
    
                    for i_shank = 1 : n_shanks
                        for i_shankcol = 1 : cols_per_shank
                            for i_site = 1 : n_rows
    
                                col_num = (i_shank-1) * cols_per_shank + i_shankcol;
                                if strcmpi(lfp_type, 'monopolar')
                                    original_channel_num = map_shanksite2channel(col_num, i_site, probe_type);
                                else
                                    original_channel_num = [map_shanksite2channel(col_num, i_site, probe_type), map_shanksite2channel(col_num, i_site+1, probe_type)];
                                end
    
                                % above is for checking if the monopolar lfp or
                                % either of the channels for a bipolar lfp was
                                % bad
                                % "shank" in the line below really refers to the column of
                                % sites
    
                                [site_xyz,region_name] = site_anatomy_from_probe_mapping(original_channel_num, site_anatomy_table);
                                is_valid_chan = all(valid_channels(original_channel_num));
    
                                % scalo_name = sprintf('%s_scalos_%s_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, trial_feature, event_name, col_num, i_site);
                                scalo_name = sprintf('%s_scalos_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, event_name, col_num, i_site);
                                scalo_name = fullfile(scalo_folder, scalo_name);
                                corr_name = sprintf('%s_correlations_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, event_name, col_num, i_site);
                                corr_name = fullfile(scalo_folder, corr_name);

                                if exist(corr_name, 'file')
                                    continue
                                end
    
                                scalo_data = load(scalo_name);
                                n_samples = size(scalo_data.event_related_scalos, 3);
                                t_window = scalo_data.t_window;
                                fb = scalo_data.fb;
                                t = linspace(t_window(1), t_window(2), n_samples);
                                f = centerFrequencies(fb);
    
                                trials_during_disconnects = find_trials_during_disconnects(session_qc_check, ...
                                    session_name, ...
                                    scalo_data.trials, ...
                                    event_list{i_event}, ...
                                    scalo_data.t_window);
                                if isempty(trials_during_disconnects)
                                    % no trials with this event
                                    continue
                                end
    
                                % artifact rejection and make sure we only
                                % include scalograms for trials for which this
                                % event exists
                                nanrows = all(isnan(scalo_data.event_triggered_lfps), 2);
                                allzero_rows = all(scalo_data.event_triggered_lfps == 0, 2);
                                valid_trial_rows = ~nanrows & ~allzero_rows & valid_trial_flags;
                                valid_scalo_bool = reject_trial_lfp_artifacts(scalo_data.event_triggered_lfps, rejection_threshold);
                                valid_scalo_bool = valid_scalo_bool(:) & ~trials_during_disconnects(:) & valid_trial_rows(:);
                                valid_scalo_idx = find(valid_scalo_bool);
                                % added the colon subscript to make sure both
                                % are column vectors
                                valid_scalos = scalo_data.event_related_scalos(valid_scalo_idx, :, :);
    
                                n_valid_scalos = sum(valid_scalo_idx);
                                if n_valid_scalos == 0
                                    continue
                                end
    
                                % data_without_nans = valid_scalos(~isnan(valid_scalos));
                                % the function extract_perievent_data was used
                                % to, well, extract the perievent data for all
                                % trials
    
                                scalo_amplitudes = abs(valid_scalos);
                                scalo_power = scalo_amplitudes .^ 2;
                                scalo_phases = angle(valid_scalos);
    
                                % collect RT and MT from the valid trials
                                % valid_trial_rows_idx = find(valid_trial_rows);
                                n_validtrials = length(valid_scalo_idx);

                                RTs = zeros(n_validtrials, 1);
                                MTs = zeros(n_validtrials, 1);
                                for i_validtrial = 1 : n_validtrials
                                    RTs(i_validtrial) = trials_struct.trials(valid_scalo_idx(i_validtrial)).timing.RT;
                                    MTs(i_validtrial) = trials_struct.trials(valid_scalo_idx(i_validtrial)).timing.MT;
                                end
    
                                % calculate correlations
                                n_points = size(scalo_power, 3);
                                n_freqs = size(scalo_power, 2);
                                power_array = reshape(log(scalo_power), n_validtrials, []);
                                phase_array = reshape(scalo_phases, n_validtrials, []);

                                [power_RTcorr, power_RTp] = corr(RTs, power_array);
                                [power_MTcorr, power_MTp] = corr(MTs, power_array);
                                power_RTcorr_reshaped = reshape(power_RTcorr, [n_freqs, n_points]);
                                power_RTp_reshaped = reshape(power_RTp, [n_freqs, n_points]);
                                power_MTcorr_reshaped = reshape(power_MTcorr, [n_freqs, n_points]);
                                power_MTp_reshaped = reshape(power_MTp, [n_freqs, n_points]);

                                [phase_RTcorr, phase_RTp] = phase_behavior_correlations(phase_array, RTs);
                                [phase_MTcorr, phase_MTp] = phase_behavior_correlations(phase_array, MTs);
                                phase_RTcorr_reshaped = reshape(phase_RTcorr, [n_freqs, n_points]);
                                phase_RTp_reshaped = reshape(phase_RTp, [n_freqs, n_points]);
                                phase_MTcorr_reshaped = reshape(phase_MTcorr, [n_freqs, n_points]);
                                phase_MTp_reshaped = reshape(phase_MTp, [n_freqs, n_points]);

                                save(corr_name, 'scalo_power', 'scalo_phases', 'power_RTcorr_reshaped', ...
                                    'power_RTp_reshaped', 'power_MTcorr_reshaped', 'power_MTp_reshaped', ...
                                    'phase_RTcorr_reshaped', 'phase_RTp_reshaped', 'phase_MTcorr_reshaped', ...
                                    'phase_MTp_reshaped', 'valid_scalo_idx', 'trials', 'fb', 't_window')
                            end
                        end
                    end
                end
            end
        end
    end
end
