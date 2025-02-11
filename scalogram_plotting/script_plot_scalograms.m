% script to plot scalograms for all of Jen's rats; store in files in
% the processed data folders

% in this version, the event-related LFPs have all been extracted already
% and stored in separate .mat files

% trial_features = {'all', 'correct', 'wrong', 'moveleft', 'moveright'};
trial_features = {'all'};
n_trialfeatures = length(trial_features);

power_clims = [2, 16];
power_ylims = [0, 80];
power_yticks = [0, 80];

parent_directory = '\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB.xlsx';
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

        session_name = session_dirs(i_session).name;
        cur_dir = fullfile(session_dirs(i_session).folder, session_name);
        cd(cur_dir)

        for i_lfptype = 1 : length(lfp_types)

            lfp_type = lfp_types{i_lfptype};
            % if strcmpi(lfp_type, 'bipolar')
            %     ordered_lfp = diff_lfp_from_monopolar(ordered_lfp, probe_type);
            % end
            probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);

            % todo: also make plots of mean scalograms for sequence of
            % events
            for i_event = 1 : length(event_list)
                event_name = event_list{i_event};
                scalo_folder = create_scalo_folder(session_name, event_name, parent_directory);

                if ~exist(scalo_folder, 'dir')
                    continue
                end

                sprintf('working on session %s, event %s, %s', session_name, event_name, lfp_type)
                trial_feature = 'all';

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

                % create figure with appropriate number of panels
                switch lower(lfp_type)
                    case 'monopolar'
                        n_rows = sites_per_shank;
                    case 'bipolar'
                        n_rows = sites_per_shank - 1;
                end
                [geometry_amp_fig, geometry_amp_axs] = create_single_event_scalogram_panels(n_rows, cols_per_shank, n_shanks, 'visible', 'off');
                header_string = sprintf('%s lfp power, %s, %s trials, %s', lfp_type, session_name, trial_feature, event_name);
                power_sgt = sgtitle(geometry_amp_fig, header_string, interpreter='none');
                [geometry_phase_fig, geometry_phase_axs] = create_single_event_scalogram_panels(n_rows, cols_per_shank, n_shanks);
                amp_sgt = sgtitle(geometry_amp_fig, header_string, interpreter='none');
                for i_shank = 1 : n_shanks
                    for i_site = 1 : sites_per_shank
                        scalo_name = sprintf('%s_scalos_%s_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, trial_feature, event_name, i_shank, i_site);
                        scalo_name = fullfile(scalo_folder, scalo_name);

                        scalo_data = load(scalo_name);
                        n_samples = size(scalo_data.event_related_scalos, 3);
                        t = linspace(scalo_data.t_window(1), scalo_data.t_window(2), n_samples);
                        f = centerFrequencies(scalo_data.fb);

                        data_without_nans = scalo_data.event_related_scalos(~isnan(scalo_data.event_related_scalos));
                        scalo_amplitudes = abs(scalo_data.event_related_scalos);
                        scalo_power = scalo_amplitudes .^ 2;
                        scalo_phases = angle(data_without_nans);

                        % scalo_data.event_related_scalos contains the
                        % complex scalograms.
                        % scalo_data.event_related_scalos(i, j, k) is the
                        % scalogram for the i'th trial, j'th frequency,
                        % k'th time sample
                        mean_power = mean(scalo_power, 1, 'omitnan');
                        if ndims(mean_power) > 2 %#ok<ISMAT>
                            mean_power = squeeze(mean_power);
                        end
                        mean_phases = circ_mean(scalo_phases, [], 1);

                        set(geometry_amp_fig, 'CurrentAxes', geometry_amp_axs(i_site, i_shank))
                        imagesc(t, f, log(mean_power), power_clims)
                        set(gca,ydir='normal',...
                                YLim=power_ylims,...
                                YTick=power_yticks);
                        if i_shank > 1
                            set(gca,yticklabels=[]);
                        end
                        if i_shank < sites_per_shank
                            set(gca,xticklabels=[]);
                        end

                    end
                end

            end
        end
    end

end