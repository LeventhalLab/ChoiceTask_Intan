% script to plot scalograms for all of Jen's rats; store in files in
% the processed data folders

% in this version, the event-related LFPs have all been extracted already
% and stored in separate .mat files

% trial_features = {'all', 'correct', 'wrong', 'moveleft', 'moveright'};
trial_features = {'all'};
n_trialfeatures = length(trial_features);

use_log_fscale = false;

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
    rat_sheet_name = strcat(ratID, '_finished');
    site_coords = read_Jen_xls_summary(summary_xls, rat_sheet_name);

    for i_session = 1 : num_sessions

        session_name = session_dirs(i_session).name;
        cur_dir = fullfile(session_dirs(i_session).folder, session_name);
        cd(cur_dir)

        for i_lfptype = 1 : length(lfp_types)
            % lfp_type = 'bipolar';
            lfp_type = lfp_types{i_lfptype};
            if strcmpi(lfp_type, 'monopolar')
                power_clims = [2, 10];
                mrl_clims = [0, 1];
            else
                power_clims = [0, 10];
                mrl_clims = [0, 1];
            end

            probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);

            % todo: also make plots of mean scalograms for sequence of
            % events
            for i_event = 1 : length(event_list)
                event_name = event_list{i_event};
                scalo_folder = create_scalo_folder(session_name, event_name, parent_directory);
                
                if ~exist(scalo_folder, 'dir')
                    continue
                end
                scalo_plots_folder = create_scalo_plots_folder(session_name, event_name, parent_directory);
                if ~exist(scalo_plots_folder, 'dir')
                    status = mkdir(scalo_plots_folder);
                end

                sprintf('working on session %s, event %s, %s', session_name, event_name, lfp_type)
                trial_feature = 'all';
                scalo_power_pdf_name = sprintf('%s_scalopower_%s_%s_%s.pdf', session_name, lfp_type, trial_feature, event_name);
                scalo_power_pdf_name = fullfile(scalo_plots_folder, scalo_power_pdf_name);

                scalo_mrl_pdf_name = sprintf('%s_scalomrl_%s_%s_%s.pdf', session_name, lfp_type, trial_feature, event_name);
                scalo_mrl_pdf_name = fullfile(scalo_plots_folder, scalo_mrl_pdf_name);
                if exist(scalo_power_pdf_name, 'file') && exist(scalo_mrl_pdf_name, 'file')
                    continue
                end

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
                test_scalo_name = sprintf('%s_scalos_%s_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, trial_feature, event_name, 1, 1);
                test_scalo_name = fullfile(scalo_folder, test_scalo_name);
                trials = load(test_scalo_name, 'trials');
                trials_with_feature = extract_trials_by_features(trials.trials, trial_feature);
                n_trials = length(trials_with_feature);

                [geometry_power_fig, geometry_power_axs] = create_single_event_scalogram_panels(n_rows, cols_per_shank, n_shanks, 'visible', 'on');
                header_string = sprintf('%s lfp power, %s, %s trials, %s, n=%d', lfp_type, session_name, trial_feature, event_name, n_trials);
                power_sgt = sgtitle(geometry_power_fig, header_string, interpreter='none');
                [geometry_mrl_fig, geometry_mrl_axs] = create_single_event_scalogram_panels(n_rows, cols_per_shank, n_shanks, 'visible', 'on');
                header_string = sprintf('%s lfp mrl, %s, %s trials, %s, n=%d', lfp_type, session_name, trial_feature, event_name, n_trials);
                mrl_sgt = sgtitle(geometry_mrl_fig, header_string, interpreter='none');
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
                            scalo_name = sprintf('%s_scalos_%s_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, trial_feature, event_name, col_num, i_site);
                            scalo_name = fullfile(scalo_folder, scalo_name);
    
                            scalo_data = load(scalo_name);
                            n_samples = size(scalo_data.event_related_scalos, 3);
                            t = linspace(scalo_data.t_window(1), scalo_data.t_window(2), n_samples);
                            f = centerFrequencies(scalo_data.fb);
    
                            data_without_nans = scalo_data.event_related_scalos(~isnan(scalo_data.event_related_scalos));
                            scalo_amplitudes = abs(scalo_data.event_related_scalos);
                            scalo_power = scalo_amplitudes .^ 2;
                            scalo_phases = angle(scalo_data.event_related_scalos);
    
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
                            mrl = circ_r(scalo_phases, [], [], 1);
                            if ndims(mrl) > 2 %#ok<ISMAT>
                                mrl = squeeze(mrl);
                            end
                            
    
                            figure(geometry_power_fig)
                            set(geometry_power_fig, 'CurrentAxes', geometry_power_axs(i_site, col_num))
                            h_power = pcolor(t, f, log(mean_power));
                            colormap('jet')
                            clim(power_clims)
                            h_power.EdgeColor = 'none';
                            set(gca,'yscale', 'log');
                            
                            % imagesc(t, f, log(mean_power), power_clims)
                            set(gca,ydir='normal',...
                                    YLim=power_ylims,...
                                    YTick=power_yticks,...
                                    yticklabels=power_yticklabels,...
                                    XLim=t_window);
                            if col_num > 1
                                set(gca,yticklabels=[]);
                            end
                            if i_site < sites_per_shank
                                set(gca, XTick=t_ticks, xticklabels=[]);
                            else
                                set(gca, XTick=t_ticks, xticklabels=t_ticks)
                            end

                            figure(geometry_mrl_fig)
                            set(geometry_mrl_fig, 'CurrentAxes', geometry_mrl_axs(i_site, col_num))
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
                            if col_num > 1
                                set(gca,yticklabels=[]);
                            end
                            if i_site < sites_per_shank
                                set(gca, XTick=t_ticks, xticklabels=[]);
                            else
                                set(gca, XTick=t_ticks, xticklabels=t_ticks)
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
                print(geometry_power_fig, scalo_power_pdf_name, '-dpdf')
                print(geometry_mrl_fig, scalo_mrl_pdf_name, '-dpdf')
                scalo_power_fig_name = replace(scalo_power_pdf_name, '.pdf', '.fig');
                scalo_mrl_fig_name = replace(scalo_mrl_pdf_name, '.pdf', '.fig');
                savefig(geometry_power_fig, scalo_power_fig_name)
                savefig(geometry_mrl_fig, scalo_mrl_fig_name)
                close(geometry_power_fig)
                close(geometry_mrl_fig)
            end
        end
    end

end