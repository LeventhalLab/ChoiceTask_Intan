%% 
% eventFieldnames = {'centerIn'};
% [ trialEventParams ] = getTrialEventParams('allgo'); % Need to verify this section. Working Here
% trIdx = extractTrials(trials, trialEventParams);
% 
% trial_ts = extract_trial_ts(trials(trIdx), eventFieldnames);
% event_triggered_lfps = extract_LFP_around_timestamps(lfp, trial_ts, t_win, Fs);
% num_trials = size(event_triggered_lfps, 1);
% num_trials_to_plot = 5;                   
% trial_idx_to_plot = randperm(num_trials, num_trials_to_plot);
% [channel_information, intan_site_order, site_order] = channel_by_probe_site_ALL(probe_channel_info, probe_type);
% valid_sites_reordered = channel_information.(session_name); % need to specify column to use - really do need session_name here
%%

function plot_channel_lfps = plot_trials_valid_channels_marked(event_triggered_lfps, trials_validchannels_marked, valid_sites_reordered)

% INPUTS
% event_triggered_lfps - m x n array extracted from LFPs around timestamps
% trials_validchannels_marked - trials structure with the last two columns
%       containing information regarding whether the channel was good or bad
% valid_sites_reordered - info of where to pull the bad data information

fname = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\Rat_Information_channels_to_discard.xlsx'; % for channels etc
num_trials_to_plot = 5; 
num_trials = size(event_triggered_lfps, 1);
trial_idx_to_plot = randperm(num_trials, num_trials_to_plot);
ratID = 'R0326'; % This can get commented out for lengthy scripts bc it should be input as it runs through the script.
sheetname = ratID;
% lists for ratID probe_type
probe_type = 'NN8x8';
NN8x8 = ["R0326", "R0327", "R0372", "R0379", "R0374", "R0376", "R0378", "R0394", "R0395", "R0396", "R0412", "R0413"]; % Specify list of ratID associated with each probe_type; again comment this out.
probe_channel_info = load_channel_information(fname, sheetname);
[channel_information, intan_site_order, site_order] = channel_by_probe_site_ALL(probe_channel_info, probe_type);

for i_trial = 1:num_trials_to_plot
    trial_idx = trial_idx_to_plot(i_trial);
        channel_lfps = squeeze(event_triggered_lfps(trial_idx,:, :)); 
        % trials, create a 64channel graph for each trial?
    
        % Plot the data
        figure;
        num_rows = size(event_triggered_lfps,2);
        LFPs_per_shank = num_rows/ 8;   % will be 8 for 64 channels, 7 for 56 channels (diff)
    for i_row = 1 : num_rows

        y_lim = [-1500, 1500];
        plot_col = ceil(i_row / LFPs_per_shank);
        plot_row = i_row - LFPs_per_shank * (plot_col-1);
        plot_num = (plot_row-1) * 8 + plot_col;

        subplot(LFPs_per_shank,8,plot_num);
%         switch trials_validchannels_marked(i_trial).is_channel_valid_ordered(i_row) % valid_sites_reordered(i_row)  % make sure is_valid_lfp is a boolean with true if it's a good channel; make sure this is in the same order as channel_lfps

        if trials_validchannels_marked(i_trial).is_channel_valid_ordered(i_row) == 0 && valid_sites_reordered(i_row) == 0
            % this is a trial marked bad by software, and the whole channel
            % is bad
            plot_color = 'r';
        elseif trials_validchannels_marked(i_trial).is_channel_valid_ordered(i_row) == 0 && valid_sites_reordered(i_row) == 1
            % this is a trial marked bad by software, but the whole
            % channel is considered good
            plot_color = 'g';
        elseif trials_validchannels_marked(i_trial).is_channel_valid_ordered(i_row) == 0 && valid_sites_reordered(i_row) == 2
            % this is a trial marked bad by software, and the whole
            % channel is considered variable
            plot_color = 'o';
        elseif trials_validchannels_marked(i_trial).is_channel_valid_ordered(i_row) == 1 && valid_sites_reordered(i_row) == 0
            % this is a trial marked good by software, but the whole
            % channel was considered bad
            plot_color = 'c';
        elseif trials_validchannels_marked(i_trial).is_channel_valid_ordered(i_row) == 1 && valid_sites_reordered(i_row) == 1
            % this is a trial marked good by software, and the whole
            % channel was considered good
            plot_color = 'm';
        elseif trials_validchannels_marked(i_trial).is_channel_valid_ordered(i_row) == 1 && valid_sites_reordered(i_row) == 2
            % this is a trial marked good by software, and the whole
            % channel was considered variable
            plot_color = 'k';
        end

        plot_channel_lfps = plot(channel_lfps(i_row, :), plot_color); % change to log10 -- plot(f, 10*log10(power_lfps(:,1)))
        set(gca, 'ylim',y_lim);
        grid on
        
        if contains(ratID, NN8x8) % if the ratID is in the list, it'll assign it the correct probe_type for ordering the LFP data correctly
            caption = sprintf('NN8x8 #%d', site_order(i_row));
        elseif contains(ratID, ASSY156)
            caption = sprintf('ASSY156 #%d', site_order(i_row));
        elseif contains(ratID, ASSY236)
            caption = sprintf('ASSY236 #%d', site_order(i_row));
        end 
        title(caption, 'FontSize', 8);


%              switch valid_sites_reordered(i_row)   % make sure is_valid_lfp is a boolean with true if it's a good channel; make sure this is in the same order as channel_lfps
%                                     case 0
%                                         plot_color = 'r';
%                                     case 1
%                                         plot_color = 'k';
%                                     case 2
%                                         plot_color = 'b';
%                                     otherwise
%                                         plot_color = 'b';
%                                 end

        if plot_row < LFPs_per_shank
            set(gca,'xticklabels',[])
        end

        if plot_col > 1
            set(gca,'yticklabels',[])
        end

    end
end
