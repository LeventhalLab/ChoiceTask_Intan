function excluded_trials = extract_bad_data(lfp, trials, Fs)

%INPUTS
% lfp - m x n data containing un-ordered lfp data
% Fs - frequency of decimated LFP data - typically 500
% trials - trials structure generated from createTrialsStruct_simpleChoice_Intan


% Run Choice_Task_Workflow
% Run getTrialEventParams.m (allgo)
% Run extractTrials.m
% Create Variable trials_to_run = trials(trIdx) (maybe not needed)
% load lfp data in an 'ordered' format based on probe type
    % load(lfp_data);
    % Fs = lfp_data.actual_Fs;
    % lfp = lfp_data.lfp;

outlier_thresh = 1500;    % in mV

threshold = 1.5; % data is input into matrices with a multiplication factor of 1.0e+03 so need to account for this when selecting datapoints that are outliers
excluded_trials = [];

% eventFieldnames = {'cueOn'};
eventFieldnames = {'cueOn', 'centerIn', 'centerOut', 'tone', 'sideIn', 'sideOut', 'foodClick', 'foodRetrievel'};
t_win = [-2.5 2.5];

trialEventParams = getTrialEventParams('allgo');
trIdx = extractTrials(trials, trialEventParams);
num_trials = length(trIdx);
num_channels = size(lfp, 1);

% set all trials to have all valid channels, which will be updated inside
% the i_taskevent loop. There, the code will check if there are
% out-of-range values for each event, and assign a channel as invalid if
% there are any out-of-range values for any events that occurred during
% that trial.
for i_trial = 1 : num_trials
    trials(trIdx(i_trial)).is_channel_valid = true(num_channels, 1);
end

for i_taskevent = 1 : length(eventFieldnames)
%     trial_ts = extract_trial_ts(trials(trIdx), eventFieldnames{i_taskevent});
    
    event_triggered_lfps = extract_event_related_LFPs(lfp, trials(trIdx), eventFieldnames{i_taskevent}, 'fs', Fs, 'twin', t_win);

    lfp_invalid = abs(event_triggered_lfps) > outlier_thresh;   % need to check, but pretty sure NaNs will get flagged as false in this test (this is good)

    for i_trial = 1 : num_trials
        invalid_trial_data = squeeze(lfp_invalid(i_trial, :, :));

        is_trial_invalid = any(invalid_trial_data, 2);   % check if there are any values out of range in each row
        trials(trIdx(i_trial)).is_channel_valid = trials(trIdx(i_trial)).is_channel_valid & ~is_trial_invalid;
    end
    save('trials', '*_.mat')
end


