function perievent_data = extract_perievent_data(ephys_data, trials, event_name, t_window, Fs)
%UNTITLED2 Summary of this function goes here
% INPUTS
%   ephys_data - num_channels x num_samples array
%   ts - vector of timestamps with times in seconds
%   
%   Detailed explanation goes here

ts = ts_from_trials(trials, event_name);
num_trials = length(ts);
num_channels = size(ephys_data, 1);
total_samples = size(ephys_data, 2);

samp_window = round(t_window * Fs);
center_samps = round(ts * Fs);
samp_windows = center_samps + samp_window;
samps_per_window = range(samp_window) + 1;

perievent_data = zeros(num_trials, num_channels, samps_per_window);

for i_trial = 1 : num_trials

    if samp_windows(i_trial, 1) < 1 || samp_windows(i_trial, 2) > total_samples
        % if window starts before start of recording or ends after end of
        % recording, skip
        continue
    end
    perievent_data(i_trial, :, :) = ephys_data(:, samp_windows(i_trial, 1) : samp_windows(i_trial, 2));
end