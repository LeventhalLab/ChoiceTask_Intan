function [valid_trial_flags,valid_trial_flags_preASRreject] = get_valid_scalos_eeglab(event_triggered_lfps_cleaned, ...
                                              event_triggered_lfps_preASR, ...
                                              trials, ...
                                              trial_feature, ...
                                              event_ts, ...
                                              invalid_times, ...
                                              clean_sample_mask, ...
                                              Fs, ...
                                              t_window, ...
                                              preASR_clean_diff_threshold)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    event_triggered_lfps_cleaned
    event_triggered_lfps_preASR
    trials
    trial_feature
    event_ts
    invalid_times
    clean_sample_mask
    Fs
    t_window
    preASR_clean_diff_threshold
end

% keep track of 1) trials that don't match selection criteria (e.g.,
% eliminate wrong trials if we're only looking at correct trials), 2)
% eliminate events that occurred during disconnects, 3) eliminate segments
% that occurred during eeglab-identified rejected segments, 4) eliminate
% events that occurred where ASR corrected the signal on an individual
% channels, but it still has a significant artifact

n_total_trials = length(trials);
n_orig_samples = length(clean_sample_mask);
samps_per_window = size(event_triggered_lfps_cleaned, 2);
t = linspace(t_window(1), t_window(2), samps_per_window);

% 1. find trials that meet trial_feature criteria
[~, valid_trial_flags] = extract_trials_by_features(trials, trial_feature);
valid_trial_flags_preASRreject = valid_trial_flags;

if ~isempty(invalid_times)
    % create a mask of user-identified bad stretches of the recording
    invalid_mask = false(1, n_orig_samples);
    invalid_samp_win = round(invalid_times * Fs);
    for ii = 1 : size(invalid_times, 1)
        invalid_mask(invalid_samp_win(ii, 1) : invalid_samp_win(ii,2)) = true;
    end
    invalid_mask = invalid_mask | ~clean_sample_mask;   % include samples rejected by eeglab clean_artifacts
else
    invalid_mask = ~clean_sample_mask;
end

for i_trial = 1 : n_total_trials
    if valid_trial_flags(i_trial)
        % check if this row is NaNs
        if isnan(event_triggered_lfps_cleaned(i_trial, 1))
            % this row contains NaNs for some reason (maybe event
            % overlapped with edge of recording, or sits on a time region
            % where eeglab cut out part of the recording, or this event 
            % doesn't exist for this trial)
            valid_trial_flags(i_trial) = false;
            valid_trial_flags_preASRreject(i_trial) = false;
            continue
        end

        % figure(5)
        % hold off
        % plot(t, event_triggered_lfps_cleaned(i_trial, :))
        % hold on
        % plot(t, event_triggered_lfps_preASR(i_trial, :))

        % 2 & 3. eliminate events that occurred during disconnects or segments
        % marked as bad by eeglab clean_artifacts
        trial_samps = false(1, n_orig_samples);
        samp_window_start = round((event_ts(i_trial) * Fs) + round(t_window(1)) * Fs);   % did it this way because it's identical to the way it's done in extract_perievent_data_fromEEG
        trial_samps(samp_window_start : samp_window_start + samps_per_window - 1) = true;
        if any(trial_samps & invalid_mask)
            % there is a region where the samples to be pulled out for this
            % trial overlap with rejected regions
            valid_trial_flags(i_trial) = false;
            valid_trial_flags_preASRreject(i_trial) = false;
            continue
        end

        trial_signal_diff = abs(event_triggered_lfps_cleaned(i_trial, :) - event_triggered_lfps_preASR(i_trial, :));
        if any(trial_signal_diff > preASR_clean_diff_threshold)
            % the difference between the pre-ASR (high-pass filtered) and
            % cleaned signals is large, suggesting that the signal had to
            % be excessively "cleaned" in eeglab
            valid_trial_flags(i_trial) = false;
        end
        
    end

end

end