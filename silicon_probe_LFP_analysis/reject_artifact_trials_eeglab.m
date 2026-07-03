function [outputArg1,outputArg2] = reject_artifact_trials_eeglab(event_triggered_lfps_cleaned, ...
                                              event_triggered_lfps_orig, ...
                                              cleanedEEG_channel, ...
                                              i_channel, ...
                                              event_ts, ...
                                              clean_sample_mask)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    event_triggered_lfps_cleaned
    event_triggered_lfps_orig
    cleanedEEG_channel
    i_channel
    event_ts
    clean_sample_mask
end

arguments (Output)
    outputArg1
    outputArg2
end

% reject trials that occurred within a masked out region
end