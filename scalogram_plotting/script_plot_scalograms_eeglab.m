% script to plot scalograms based on cleaned lfp data
% run this after script_analyze_cleanedEEG.m
use_log_fscale = true;
reject_threshold = 500;  % threshold for difference between preASR and cleaned data; differences larger than this will lead to trial rejection

lfp_type = 'bipolar';
trial_type = 'correct';
trial_feature = 'all';
event_list = {'cueOn', 'centerIn', 'tone', 'centerOut' 'sideIn', 'sideOut', 'foodClick', 'foodRetrieval'};

power_ylims = [0, 80];
power_yticks = [0, 4, 20, 40, 80];
power_yticklabels = {0, 4, 20, 40, 80};
if use_log_fscale
    power_ylims = [0 log10(power_ylims(2))];
    power_yticks = [0, log10(power_yticks(2:end))];
    % power_yticklabels = {0, [], [], [], power_ylims(2)};
end
mrl_ylims = power_ylims;
mrl_yticks = power_yticks;
mrl_yticklabels = power_yticklabels;


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

    rat_sheet_name = strcat(ratID, '_finished');
    site_anatomy_table = read_Jen_xls_summary(summary_xls, rat_sheet_name);

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
    switch lower(lfp_type)
        case 'monopolar'
            n_rows = sites_per_shank;
        case 'bipolar'
            n_rows = sites_per_shank - 1;
    end
    intan2probe_mapping = probe_site_mapping_all_probes(probe_type);

    for i_session = 1 : num_sessions

        session_name = session_dirs(i_session).name;

        if ~ismember(session_name, valid_monopolar_channels.Properties.VariableNames)
            sprintf('no qc channels for %s', session_name)
            continue
        end
        if strcmpi(lfp_type, 'monopolar')
            power_clims = [2, 10];
        else
            power_clims = [0, 5];
        end
        mrl_clims = [0,1];

        [valid_bipolar_channels, invalid_times] = valid_bipolar_from_qc(valid_monopolar_channels, session_name, probe_type);
        n_bipolar_channels = length(valid_bipolar_channels);
        for i_event = 1 : length(event_list)
            event_name = event_list{i_event};
            scalo_folder = create_scalo_folder(session_name, event_name, choicetask_path);
            if ~exist(scalo_folder, 'dir')
                continue
            end
            scalo_plots_folder = create_scalo_plots_folder(session_name, event_name, choicetask_path);
            if ~exist(scalo_plots_folder, 'dir')
                status = mkdir(scalo_plots_folder);
            end

            test_scalo_name = sprintf('%s_scalos_%s_%s_shank%02d_site%02d_eeglab.mat',session_name, lfp_type, event_name, 1, 1);
            test_scalo_name = fullfile(scalo_folder, test_scalo_name);
            trials = load(test_scalo_name, 'trials');
            [trials_with_feature, valid_trial_flags] = extract_trials_by_features(trials.trials, trial_feature);
            n_trials = length(trials_with_feature);

            % find the ts as

            sprintf('working on session %s, event %s, %s', session_name, event_name, lfp_type)
            trial_feature = 'all';
            scalo_power_pdf_name = sprintf('%s_scalopower_%s_%s_%s_eeglab.pdf', session_name, lfp_type, trial_feature, event_name);
            scalo_power_pdf_name = fullfile(scalo_plots_folder, scalo_power_pdf_name);

            scalo_mrl_pdf_name = sprintf('%s_scalomrl_%s_%s_%s_eeglab.pdf', session_name, lfp_type, trial_feature, event_name);
            scalo_mrl_pdf_name = fullfile(scalo_plots_folder, scalo_mrl_pdf_name);

            [geometry_power_fig, geometry_power_axs] = create_single_event_scalogram_panels(n_rows, cols_per_shank, n_shanks, 'visible', 'on');
            header_string = sprintf('%s pwr, %s, %s trials, %s, total n=%d, clim %d-%d, bold edge=invld', lfp_type, session_name, trial_feature, event_name, n_trials, power_clims(1), power_clims(2));
            power_sgt = sgtitle(geometry_power_fig, header_string, interpreter='none', fontsize=10);
            [geometry_mrl_fig, geometry_mrl_axs] = create_single_event_scalogram_panels(n_rows, cols_per_shank, n_shanks, 'visible', 'on');
            header_string = sprintf('%s mrl, %s, %s trials, %s, n=%d, clim %d-%d, bold edge=invld', lfp_type, session_name, trial_feature, event_name, n_trials, mrl_clims(1), mrl_clims(2));
            mrl_sgt = sgtitle(geometry_mrl_fig, header_string, interpreter='none', fontsize=10);

            % [geometry_power_fig, geometry_power_axs] = create_single_event_scalogram_panels(n_rows, cols_per_shank, n_shanks, 'visible', 'on');
            % header_string = sprintf('%s pwr, %s, %s trials, %s, total n=%d, clim %d-%d, bold edge=invld', lfp_type, session_name, trial_feature, event_name, n_trials, power_clims(1), power_clims(2));
            % power_sgt = sgtitle(geometry_power_fig, header_string, interpreter='none', fontsize=10);
            % [geometry_mrl_fig, geometry_mrl_axs] = create_single_event_scalogram_panels(n_rows, cols_per_shank, n_shanks, 'visible', 'on');
            % header_string = sprintf('%s mrl, %s, %s trials, %s, n=%d, clim %d-%d, bold edge=invld', lfp_type, session_name, trial_feature, event_name, n_trials, mrl_clims(1), mrl_clims(2));
            % mrl_sgt = sgtitle(geometry_mrl_fig, header_string, interpreter='none', fontsize=10);

            for i_channel = 1 : n_bipolar_channels

                probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);
                [shank_num, site_num] = get_shank_and_site_num(probe_lfp_type, i_channel);

                if strcmpi(lfp_type, 'monopolar')
                    original_channel_num = map_shanksite2channel(shank_num, site_num, probe_type);
                else
                    original_channel_num = [map_shanksite2channel(shank_num, site_num, probe_type), map_shanksite2channel(shank_num, site_num+1, probe_type)];
                end

                scalo_name = sprintf('%s_scalos_%s_%s_shank%02d_site%02d_eeglab.mat',session_name, lfp_type, event_name, shank_num, site_num);
                scalo_name = fullfile(scalo_folder, scalo_name);

                if ~exist(scalo_name, 'file')
                    continue
                end

                load(scalo_name);
                n_samples = size(event_related_scalos, 3);
                t = linspace(t_window(1), t_window(2), n_samples);
                f = centerFrequencies(fb);

                Fs = fb.SamplingFrequency;

                t_ticks = [t_window(1), 0, t_window(2)];
                t_labels = [t_window(1), 0, t_window(2)];

                % WORKING HERE...
                % trials_during_disconnects = find_trials_during_disconnects(session_qc_check, ...
                %     session_name, ...
                %     trials, ...
                %     event_list{i_event}, ...
                %     scalo_data.t_window);
                % if isempty(trials_during_disconnects)
                %     % no trials with this event
                %     continue
                % end

                % find 

                [site_xyz,region_name] = site_anatomy_from_probe_mapping(original_channel_num, site_anatomy_table);
                % is_valid_chan = all(valid_channels(original_channel_num));

                [valid_scalos_bool, valid_scalos_bool_preASRreject] = get_valid_scalos_eeglab(event_triggered_lfps_cleaned, ...
                                              event_triggered_lfps_preASR, ...
                                              trials, ...
                                              trial_feature, ...
                                              event_ts, ...
                                              invalid_times, ...   % stored in the scalo .mat file; contains disconnect times
                                              clean_sample_mask, ...
                                              Fs, ...
                                              t_window, ...
                                              reject_threshold);   % threshold for difference between preASR and cleaned data; differences larger than this will lead to trial rejection

                % valid_scalos_matrix = event_triggered_lfps_cleaned(valid_scalos_bool, :);

                valid_scalos = event_related_scalos(valid_scalos_bool, :, :);
                n_valid_scalos = size(valid_scalos, 1);

                scalo_amplitudes = abs(valid_scalos);
                scalo_power = scalo_amplitudes .^ 2;
                scalo_phases = angle(valid_scalos);

                mean_power = mean(scalo_power, 1, 'omitnan');
                if ~ismatrix(mean_power)
                    mean_power = squeeze(mean_power);
                end
                mean_phases = circ_mean(scalo_phases, [], 1);
                mrl = circ_r(scalo_phases, [], [], 1);
                if ~ismatrix(mrl)
                    mrl = squeeze(mrl);
                end

                figure(geometry_power_fig)
                set(geometry_power_fig, 'CurrentAxes', geometry_power_axs(site_num, shank_num))
                h_power = pcolor(t, f, log10(mean_power));
                colormap('jet')
                clim(power_clims)
                h_power.EdgeColor = 'none';
                set(gca,'yscale', 'log');
                set(gca,ydir='normal',...
                    YLim=power_ylims,...
                    YTick=power_yticks,...
                    yticklabels=power_yticklabels,...
                    XLim=t_window);
                if shank_num > 1
                    set(gca,yticklabels=[]);
                end
                if site_num < sites_per_shank
                    set(gca, XTick=t_ticks, xticklabels=[]);
                else
                    set(gca, XTick=t_ticks, xticklabels=t_ticks)
                end
                text_x = 0.025;
                text_y = 1.04;
                n_regions = length(region_name);
                region_str = region_name{1};
                if length(region_name) == 2
                    region_str = sprintf('%s, %s', region_str, region_name{2});
                end
                text_str = sprintf('%s, n = %d',region_str, n_valid_scalos);
                text(text_x, text_y, text_str, units="normalized", ...
                    FontSize=7, Color='k');
                if site_num == n_rows
                    % last row, keep the x-labels
                    set(gca,'xtick',t_ticks,'xticklabel',t_labels,'fontsize',7)
                    xlabel('time (s)',FontSize=7)
                end

                % plot the mrl panel
                figure(geometry_mrl_fig)
                set(geometry_mrl_fig, 'CurrentAxes', geometry_mrl_axs(site_num, shank_num))
                h_power = pcolor(t, f, mrl);
                colormap('jet')
                clim(mrl_clims)
                h_power.EdgeColor = 'none';
                set(gca,'yscale', 'log');
                % imagesc(t, f, mrl, mrl_clims)
                set(gca,ydir='normal',...
                    YLim=mrl_ylims,...
                    YTick=mrl_yticks,...
                    yticklabels=mrl_yticklabels,...
                    XLim=t_window);
                if shank_num > 1
                    set(gca,yticklabels=[]);
                end
                if site_num < sites_per_shank
                    set(gca, XTick=t_ticks, xticklabels=[]);
                else
                    set(gca, XTick=t_ticks, xticklabels=t_ticks)
                end
                text(text_x, text_y, text_str, units="normalized", ...
                    FontSize=7, Color='k')
                if site_num == n_rows
                    % last row, keep the x-labels
                    set(gca,'xtick',t_ticks,'xticklabel',t_labels,'fontsize',7)
                    xlabel('time (s)',FontSize=7)
                end

                if strcmpi(lfp_type, 'monopolar')
                    if ~valid_channels(original_channel_num)
                        % this was an invalid channel, mark it in
                        % the plot with a bold border
                        set(gca,'linewidth', 3)
                    end
                else
                    % do the same for bipolar
                    if ~valid_channels(original_channel_num(1)) || ~valid_channels(original_channel_num(2))
                        % one of the channels that went into
                        % this bipolar calculation was bad
                        set(gca,'linewidth', 3)
                    end
                end


            end
        end
    end
end