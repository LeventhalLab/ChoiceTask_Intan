% script to calculate scalograms for all of Jen's rats; store in files in
% the processed data folders

parent_directory = 'Z:\data\ChoiceTask\';
summary_xls = 'ProbeSite_Mapping_MATLAB.xlsx';
summary_xls_dir = 'Z:\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);

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

[rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();

num_rats = length(ratIDs);

for i_rat = 1 : num_rats
    ratID = ratIDs{i_rat};
    rat_folder = fullfile(parent_directory, ratID);

    if ~isfolder(rat_folder)
        continue;
    end

    probe_type = probe_types{probe_types.RatID == ratID, 2};
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

        if ~exist(trials_name)
            sprintf('no trials structure found for %s', session_name)
            continue
        end

        load(trials_name)
        
        selected_trials = extract_trials_by_features(trials, trials_to_analyze);
        if isempty(selected_trials)
            sprintf('no %s trials found for %s', trials_to_analyze, session_name)
            continue
        end

        lfp_fname = strcat(session_name, '_lfp.mat');
        if ~isfile(lfp_fname)
            sprintf('%s not found, skipping', lfp_fname)
            continue
        end

        lfp_data = load(lfp_fname);

        Fs = lfp_data.actual_Fs;
        samp_window = round(t_window * Fs);
        samples_per_event = range(samp_window) + 1;
        fb = cwtfilterbank('signallength', samples_per_event, ...
                'samplingfrequency', Fs, ...
                'wavelet','amor',...
                'frequencylimits', [1, 100]);

        [ordered_lfp, intan_site_order, intan_site_order_for_trials_struct, site_order] = lfp_by_probe_site_ALL(lfp_data, probe_type);

        for i_lfptype = 1 : length(lfp_types)

            lfp_type = lfp_types{i_lfptype};
            if strcmpi(lfp_type, 'bipolar')
                ordered_lfp = diff_lfp_from_monopolar(ordered_lfp, probe_type);
            end
            probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);
            num_channels = size(ordered_lfp, 1);

            for i_event = 1 : length(event_list)
                event_name = event_list{i_event};
                sprintf('working on session %s, event %s, %s', session_name, event_name, lfp_type)
    
                perievent_data = extract_perievent_data(ordered_lfp, selected_trials, event_list{4}, t_window, Fs);
    
                scalo_folder = create_scalo_folder(session_name, event_name, parent_directory);
    %             scalo_folder = sprintf('%s_scalos_%s', session_name, event_name);
    %             scalo_folder = fullfile(cur_dir, scalo_folder);
                if ~exist(scalo_folder, 'dir')
                    mkdir(scalo_folder)
                end
        
                for i_channel = 1 : num_channels
                    [shank_num, site_num] = get_shank_and_site_num(probe_lfp_type, i_channel);
        
                    scalo_name = sprintf('%s_scalos_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, event_name, shank_num, site_num);
                    scalo_name = fullfile(scalo_folder, scalo_name);
        
%                     if exist(scalo_name, 'file')
%                         continue
%                     end
        
                    event_triggered_lfps = squeeze(perievent_data(:, i_channel, :));
                    
                    % comment back in if running on a machine without a gpu
%                     disp('cpu')
%                     tic
%                     [event_related_scalos, ~, coi] = trial_scalograms(event_triggered_lfps, fb);
%                     toc
                    
                    etl_g = gpuArray(event_triggered_lfps);
                    [event_related_scalos, ~, coi] = trial_scalograms(etl_g, fb);

                    save(scalo_name, 'event_related_scalos', 'event_triggered_lfps', 'fb', 'coi', 't_window', 'i_channel');
                    % saving i_channel is a check to make sure that shank
                    % and site are numbered correctly later
        
                end
            end
        end
    end

end