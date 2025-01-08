function perievent_data = extract_perievent_data(ephys_data, trials, event_name, t_window, Fs)
%
% Function to extract peri-event field potentials
%
% INPUTS
%   ephys_data - num_channels x num_samples array
%   trials - trials structure
%   event_name - name of event around which to extract data and then
%       calculate scalograms
%   t_window - 2-element vector containing perievent start and end times
%       e.g., to extract +/- 1 second, t_window = [-1, 1]
%   Fs - sampling rate
%
% OUTPUTS
%   perievent_data - m x n x p array where m is the number of trials, n is
%       the number of channels, and p is the number of samples per trial

ts = extract_trial_ts(trials, event_name);
n_trials = length(ts);
n_channels = size(ephys_data, 1);
total_samples = size(ephys_data, 2);

samp_window = round(t_window * Fs);
center_samps = round(ts * Fs);

if isrow(center_samps)
    % make sure center_samps is a column vector so we can add samp_window
    center_samps = center_samps';
end

samp_windows = center_samps + samp_window;
samps_per_window = range(samp_window) + 1;

perievent_data = zeros(n_trials, n_channels, samps_per_window);

for i_trial = 1 : n_trials

    if samp_windows(i_trial, 1) < 1 || samp_windows(i_trial, 2) > total_samples
        % if window starts before start of recording or ends after end of
        % recording, skip
        continue
    end
    perievent_data(i_trial, :, :) = ephys_data(:, samp_windows(i_trial, 1) : samp_windows(i_trial, 2));

end