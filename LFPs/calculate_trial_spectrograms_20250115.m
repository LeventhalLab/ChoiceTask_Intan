% script to calculate scalograms for all of Jen's rats; store in files in
% the processed data folders

% in this version, the event-related LFPs have all been extracted already
% and stored in separate .mat files

artifact_t_window = 1.5;   % how far the artifact can be from either side of the relevant event in seconds
% trial_features = {'all', 'correct', 'wrong', 'moveleft', 'moveright'};
trial_features = {'all'};
n_trialfeatures = length(trial_features);

parent_directory = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls_dir = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);
qualitycheck_xls = 'channels_qc_final.xlsx';
qualitycheck_xls = fullfile(summary_xls_dir, qualitycheck_xls);

% change the line below to allow looping through multiple trial types,
% extract left vs right, etc.
trials_to_analyze = 'correct';
lfp_types = {'monopolar', 'bipolar'};
lfp_type = 'monopolar';
% trials_to_analyze = 'all';

t_window = [-2.5, 2.5];
event_list = {'cueOn', 'centerIn', 'tone', 'centerOut' 'sideIn', 'sideOut', 'foodClick', 'foodRetrieval'};

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER
% INFORMATION OUT OF THAT SPREADSHEET

% [rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();
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

    for i_session = 1 : num_sessions

        clear monopolar_artifact_ts
        
        session_name = session_dirs(i_session).name;
        cur_dir = fullfile(session_dirs(i_session).folder, session_name);
        cd(cur_dir)

        for i_lfptype = 1 : length(lfp_types)

            lfp_type = lfp_types{i_lfptype};
            probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);

            ERP_folder = create_ERPs_folder(session_name, parent_directory);
            for i_event = 1 : length(event_list)
                event_name = event_list{i_event};
                ERP_name = sprintf('%s_ERPs_%s_%s.mat',session_name, lfp_type, event_name);
                ERP_name = fullfile(ERP_folder, ERP_name);

                if ~exist(ERP_name)
                    fprintf('no peri-event LFPs extracted for %s, %s, %s\n', lfp_type, session_name, event_name)
                    continue
                end

                perievent_LFPs = load(ERP_name);

                if strcmpi(lfp_type, 'monopolar')
                    monopolar_artifact_ts = perievent_LFPs.artifact_timestamps;
                    % save the monopolar artifact timestamps for the
                    % bipolar calculations; make sure monopolar
                    % calculations occur before bipolar
                end

                Fs = perievent_LFPs.Fs;
                t_window = perievent_LFPs.t_window;
                samp_window = round(t_window * Fs);
                samples_per_event = range(samp_window) + 1;
                fb = cwtfilterbank('signallength', samples_per_event, ...
                    'samplingfrequency', Fs, ...
                    'wavelet','amor',...
                    'frequencylimits', [1, 100]);

                n_channels = size(perievent_LFPs.event_triggered_lfps, 2);
    
                scalo_folder = create_scalo_folder(session_name, event_name, parent_directory);
    %             scalo_folder = sprintf('%s_scalos_%s', session_name, event_name);
    %             scalo_folder = fullfile(cur_dir, scalo_folder);
                if ~exist(scalo_folder, 'dir')
                    mkdir(scalo_folder)
                end

                if check_all_session_scalos_stored(session_name, lfp_type, event_name, probe_lfp_type, trial_features, scalo_folder)
                    % already calculated all of these, skip
                    continue
                end
                sprintf('working on session %s, event %s, %s', session_name, event_name, lfp_type)
        
                for i_channel = 1 : n_channels
                    [shank_num, site_num] = get_shank_and_site_num(probe_lfp_type, i_channel);

                    if isfield(perievent_LFPs, 'artifact_timestamps')
                        trials_with_artifacts = identify_artifact_trials(perievent_LFPs.trials, ...
                                                     perievent_LFPs.artifact_timestamps{i_channel}, ...
                                                     event_name, ...
                                                     artifact_t_window);
                    else
                        if ~exist('monopolar_artifact_ts', 'var')
                            % if didn't load the monopolar artifact
                            % timestamps for this session, load them now
                            monopolar_ERP_name = sprintf('%s_ERPs_%s_%s.mat',session_name, 'monopolar', event_name);
                            monopolar_ERP_name = fullfile(ERP_folder, monopolar_ERP_name);

                            monopolar_ERPs = load(monopolar_ERP_name);
                            monopolar_artifact_ts = monopolar_ERPs.artifact_timestamps;
                        end
                        if strcmpi(lfp_type, 'bipolar')
                            trials_with_artifacts = identify_bipolar_artifact_trials(perievent_LFPs.trials, ...
                                 monopolar_artifact_ts, ...
                                 event_name, ...
                                 artifact_t_window, ...
                                 perievent_LFPs.probe_type, ...
                                 perievent_LFPs.probe_site_mapping, ...
                                 i_channel);
                        end

                    end 

                    for i_trialfeature = 1 : n_trialfeatures
                        trial_feature = trial_features{i_trialfeature};
        
                        scalo_name = sprintf('%s_scalos_%s_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, trial_feature, event_name, shank_num, site_num);
                        scalo_name = fullfile(scalo_folder, scalo_name);
            
                        if exist(scalo_name, 'file')
                            continue
                        end

                        [~, trials_with_feature] = extract_trials_by_features(perievent_LFPs.trials, trial_feature);

                        target_trials = trials_with_feature & ~trials_with_artifacts;
                        if ~any(target_trials)
                            % there are no trials without artifacts that
                            % match the feature criteria
                            continue
                        end
                        event_triggered_lfps = squeeze(perievent_LFPs.event_triggered_lfps(target_trials, i_channel, :));
                        if sum(target_trials) == 1
                            % only one valid trial, make sure
                            % event_triggered_LFPs is 1 x n_samples
                            event_triggered_lfps = reshape(event_triggered_lfps, 1, []);
                        end
    
                                            % comment back in if running on a machine without a gpu
    %                     disp('cpu')
    %                     tic
    %                     [event_related_scalos, ~, coi] = trial_scalograms(event_triggered_lfps, fb);
    %                     toc
    
                        etl_g = gpuArray(event_triggered_lfps);
                        [event_related_scalos, ~, coi] = trial_scalograms(etl_g, fb);
    
                        trials = perievent_LFPs.trials;
                        save(scalo_name, 'event_related_scalos', 'event_triggered_lfps', 'fb', 'coi', 't_window', 'i_channel', 'target_trials', 'trials');
                        % saving i_channel is a check to make sure that shank
                        % and site are numbered correctly later

                    end
        
                end
            end
        end
    end

end