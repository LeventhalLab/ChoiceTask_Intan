function valid_trials_logical = reject_trial_lfp_artifacts(event_triggered_lfps, ...
    rejection_threshold,full_t_window, ...
    Fs, ...
    rejection_t_window)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%
% INPUTS
%   event_triggered_lfps - m x n matrix where each row is an lfp - that is,
%       there are m lfp's each of duration n samples
%   rejection_threshold - threshold value above which LFPs are rejected
%       (should be in same units as event_triggered_lfps, usually
%       microvolts
%
% OUTPUTS
%   valid_trials_logical - boolean vector of m values; true values indicate
%       rows of event_triggered_lfps without artifacts

arguments (Input)
    event_triggered_lfps
    rejection_threshold
    full_t_window
    Fs
    rejection_t_window
end

arguments (Output)
    valid_trials_logical
end

n_samples = size(event_triggered_lfps, 2);
t = linspace(full_t_window(1), full_t_window(2), size(event_triggered_lfps, 2));
sample_test_region = (t > rejection_t_window(1)) & t < rejection_t_window(2);

% very simple artifact rejection based on thresholding
invalid_trials_logical = any(abs(event_triggered_lfps(:, sample_test_region)) > rejection_threshold, 2);
valid_trials_logical = ~invalid_trials_logical;

end