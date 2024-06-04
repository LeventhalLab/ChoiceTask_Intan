function [event_related_scalos, f, coi] = trial_scalograms(event_triggered_lfps, fb)
%UNTITLED2 Summary of this function goes here
% INPUTS
%   event_triggered_lfps - num_trials x samples_per_event array
%   Detailed explanation goes here

num_trials = size(event_triggered_lfps, 1);
samples_per_event = size(event_triggered_lfps, 2);

f = centerFrequencies(fb);
num_freqs = length(f);

real_event_related_scalos = zeros(num_trials, num_freqs, samples_per_event);
event_related_scalos = complex(real_event_related_scalos, 0);

for i_trial = 1 : num_trials
    [event_related_scalos(i_trial, :, :), ~, coi] = wt(fb, squeeze(event_triggered_lfps(i_trial, :)));
end

end