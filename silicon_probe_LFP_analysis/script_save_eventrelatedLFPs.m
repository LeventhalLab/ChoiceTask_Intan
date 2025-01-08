% script to store event-triggered LFPs for all of Jen's rats; store in files in
% the processed data folders

% parent_directory = 'Z:\data\ChoiceTask\';
parent_directory = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB.xlsx';
% summary_xls_dir = 'Z:\data\ChoiceTask\Probe Histology Summary';
summary_xls_dir = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);

% channel quality checking
histo_folder = fullfile(parent_directory, 'Probe Histology Summary');
qc_file = 'channels_qc_final.xlsx';
qc_file = fullfile(histo_folder, qc_file);

% change the line below to allow looping through multiple trial types,
% extract left vs right, etc.
lfp_types = {'bipolar', 'monopolar'};
% lfp_type = 'monopolar';
% trials_to_analyze = 'all';
% script currently uses all trials

t_window = [-5., 5.];
event_list = {'cueOn', 'centerIn', 'tone', 'centerOut' 'sideIn', 'sideOut', 'foodClick', 'foodRetrieval'};

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER
% INFORMATION OUT OF THAT SPREADSHEET

[ratIDs, ratIDs_goodhisto] = get_rat_list('all', parent_directory);

n_rats = length(ratIDs);

for i_rat = 1 : n_rats
    ratID = ratIDs{i_rat};
    rat_folder = fullfile(parent_directory, ratID);

    if ~isfolder(rat_folder)
        continue;
    end

    probe_type = probe_types{probe_types.ratID == ratID, 2};
    processed_folder = find_data_folder(ratID, 'processed', parent_directory);
    session_dirs = dir(fullfile(processed_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);

    for i_session = 1 : num_sessions
        
        session_name = session_dirs(i_session).name;
        cur_dir = fullfile(session_dirs(i_session).folder, session_name);
        cd(cur_dir)

        % load trials structure
        trials_name = sprintf('%s_trials.mat', session_name);
        trials_name = fullfile(cur_dir, trials_name);

        if ~exist(trials_name, 'file')
            sprintf('no trials structure found for %s', session_name)
            continue
        end

        load(trials_name)
        
        % selected_trials = extract_trials_by_features(trials, trials_to_analyze);
        % if isempty(selected_trials)
        %     sprintf('no %s trials found for %s', trials_to_analyze, session_name)
        %     continue
        % end
        % 
        % lfp_data = load(lfp_fname);
        % 
        % Fs = lfp_data.actual_Fs;
        % samp_window = round(t_window * Fs);
        % samples_per_event = range(samp_window) + 1;
        % fb = cwtfilterbank('signallength', samples_per_event, ...
        %         'samplingfrequency', Fs, ...
        %         'wavelet','amor',...
        %         'frequencylimits', [1, 100]);

%         [ordered_lfp, intan_site_order, intan_site_order_for_trials_struct, site_order] = lfp_by_probe_site_ALL(lfp_data, probe_type);

        for i_lfptype = 1 : length(lfp_types)

            lfp_type = lfp_types{i_lfptype};
            lfp_fname = strcat(session_name, '_', lfp_type, '_lfp.mat');

            lfp_fname = fullfile(cur_dir, lfp_fname);
            if ~isfile(lfp_fname)
                sprintf('%s not found, skipping', lfp_fname)
                continue
            end

            eventrelatedLFPs_saved = check_eventrelatedLFPs(session_name, event_list, lfp_type, probe_type, parent_directory);
            if eventrelatedLFPs_saved
                sprintf('all event-related LFPs extracted for %s, %s trials', session_name)
                continue
            end
            lfp_data = load(lfp_fname);
            Fs = lfp_data.actual_Fs;
            
            if strcmpi(lfp_type, 'bipolar')
                ordered_lfp = lfp_data.bipolar_lfp;
                probe_site_mapping = lfp_data.intan2probe_mapping;
            else
                ordered_lfp = lfp_data.lfp(probe_site_mapping, :);
                probe_site_mapping = probe_site_mapping_all_probes(probe_type);
            end

            probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);
            n_channels = size(ordered_lfp, 1);

            ERP_folder = create_ERPs_folder(session_name, parent_directory);
            for i_event = 1 : length(event_list)
                event_name = event_list{i_event};
                ERP_name = sprintf('%s_ERPs_%s_%s.mat',session_name, lfp_type, event_name);
                ERP_name = fullfile(ERP_folder, ERP_name);

                if exist(ERP_name)
                    continue
                end
                sprintf('working on session %s, event %s, %s', session_name, event_name, lfp_type)

                event_triggered_lfps = extract_perievent_data(ordered_lfp, trials, event_name, t_window, Fs);

    %             scalo_folder = sprintf('%s_scalos_%s', session_name, event_name);
    %             scalo_folder = fullfile(cur_dir, scalo_folder);
                if ~exist(ERP_folder, 'dir')
                    mkdir(ERP_folder)
                end

                if isfield(lfp_data, 'artifact_timestamps')
                    artifact_timestamps = lfp_data.artifact_timestamps;
                else
                    artifact_timestamps = cell(n_channels, 1);
                end

                if strcmpi(lfp_type, 'monopolar')
                    note = 'monopolar LFPs in site order, NOT original recording order';
                    save(ERP_name, 'event_triggered_lfps', 't_window', 'trials', 'Fs', 'probe_type', 'probe_site_mapping', 'artifact_timestamps', 'note');
                else
                    note = 'bipolar LFPs in site order';
                    save(ERP_name, 'event_triggered_lfps', 't_window', 'trials', 'Fs', 'probe_type', 'probe_site_mapping', 'note');
                end 

                % for just storing ERPs, I think OK to just store all the channels in one file since no scalograms stored there        
                % for i_channel = 1 : n_channels
                %     [shank_num, site_num] = get_shank_and_site_num(probe_lfp_type, i_channel);
                % 
                %     ERP_name = sprintf('%s_ERPs_%s_%s.mat',session_name, lfp_type, event_name, shank_num, site_num);
                %     ERP_name = fullfile(ERP_folder, ERP_name);
                % 
                %     if exist(ERP_name, 'file')
                %         continue
                %     end
                % 
                %     event_triggered_lfps = squeeze(perievent_data(:, i_channel, :));
                % 
                % 
                %     % saving i_channel is a check to make sure that shank
                %     % and site are numbered correctly later
                % 
                % end
            end
        end
    end

end