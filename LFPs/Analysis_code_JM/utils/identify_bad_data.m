function trials_validchannels_marked_B = identify_bad_data(lfp_data, trials, intan_site_order_for_trials_struct, probe_type, trialEventParams, eventFieldnames)

%INPUTS
% lfp_data - m x n data containing un-ordered lfp data (NOT ordered) and Fs.
% trials - trials structure generated from createTrialsStruct_simpleChoice_Intan
% intan_site_order_for_trials_struct - structure (double) containing the probe sites ordered by probe_type
% probe_type - the implanted probe (NN8x8, ASSY156, ASSY236)

% Run Choice_Task_Workflow
% Run - [ordered_lfp, intan_site_order, site_order] = lfp_by_probe_site_ALL(lfp_data, probe_type); % this orders the lfp data
% Run getTrialEventParams.m (allgo)
% Run extractTrials.m
% Create Variable trials_to_run = trials(trIdx) (maybe not needed)
% load lfp data in an 'ordered' format based on probe type
    % load(lfp_data);
    % Fs = lfp_data.actual_Fs;
    % lfp = lfp_data.lfp;

Fs = lfp_data.actual_Fs;

% [ordered_lfp, intan_site_order, intan_site_order_for_trials_struct, site_order] = lfp_by_probe_site_ALL(lfp_data, probe_type);
 % this orders the lfp data -

 % not needed for the entire script to run but if you're debugging an
% individual session, need to run this function to get 'intan_site_order'
% prior to running this function.

lfp = lfp_data.lfp;

outlier_thresh = 1500;    % in mV
t_win = [-2.5 5];

% eventFieldnames = {'cueOn'};
% eventFieldnames = {'cueOn', 'centerIn', 'centerOut', 'tone', 'sideIn', 'sideOut', 'foodClick', 'foodRetrievel'};

% trialEventParams = getTrialEventParams('allgo');
trIdx = extractTrials(trials, trialEventParams);
num_trials = length(trIdx);
% I don't think we need to enter in eventFieldnames or to get trialEventParams in the code if we run it as part of the full script

num_channels = size(lfp, 1);
% num_channels_ordered = size(ordered_lfp, 1);

% set all trials to have all valid channels, which will be updated inside
% the i_taskevent loop. There, the code will check if there are
% out-of-range values for each event, and assign a channel as invalid if
% there are any out-of-range values for any events that occurred during
% that trial.
for i_trial = 1 : num_trials
    trials(trIdx(i_trial)).is_channel_valid = true(num_channels, 1); % generates an 'unordered' list of bad sites per trial (64x1)
  % trials(trIdx(i_trial)).is_channel_valid_ordered = true(num_channels_ordered, 1); % generates an 'ordered' list of bad sites per trial - will use the ordered_lfp data! (64x1)
end

for i_taskevent = 1 : length(eventFieldnames)
%     trial_ts = extract_trial_ts(trials(trIdx), eventFieldnames{i_taskevent});
    
    event_triggered_lfps = extract_event_related_LFPs(lfp, trials(trIdx), eventFieldnames{i_taskevent}, 'fs', Fs, 'twin', t_win); % un-ordered lfp data
 %  event_triggered_lfps_ordered = extract_event_related_LFPs(ordered_lfp, trials(trIdx), eventFieldnames{i_taskevent}, 'fs', Fs, 'twin', t_win); % ordered LFP data

    lfp_invalid = abs(event_triggered_lfps) > outlier_thresh; % need to check, but pretty sure NaNs will get flagged as false in this test (this is good)
%   lfp_invalid_ordered = abs(event_triggered_lfps_ordered) > outlier_thresh; % this has the sites ordered

    for i_trial = 1 : num_trials
        % generating a list of good and bad sites 'un-ordered'
        try
        invalid_trial_data = squeeze(lfp_invalid(i_trial, :, :));
        catch
            keyboard;
        end
        is_trial_invalid = any(invalid_trial_data, 2);   % check if there are any values out of range in each row
        trials(trIdx(i_trial)).is_channel_valid = trials(trIdx(i_trial)).is_channel_valid & ~is_trial_invalid; 
        
%         % generating a list of good and bad sites 'ordered'
%         invalid_trial_data_ordered = squeeze(lfp_invalid_ordered(i_trial,:,:));
%         is_trial_invalid_ordered = any(invalid_trial_data_ordered, 2);
%         trials(trIdx(i_trial)).is_channel_valid_ordered = trials(trIdx(i_trial)).is_channel_valid_ordered & ~is_trial_invalid_ordered;
        
        % adds 2 colums to trials structure - an un-ordered list (based on the original lfp.mat files) and an
        % ordered list (based on ordered_lfps)
        trials(trIdx(i_trial)).name = trials(i_trial).is_channel_valid;
        
    end

end

% now loop through every trial and create a re-ordered version that maps to
% physical channel order rather than intan recording channel order
for i_trial = 1 : num_trials
    trials(trIdx(i_trial)).is_channel_valid_ordered = trials(trIdx(i_trial)).is_channel_valid(intan_site_order_for_trials_struct);
end

% [trials.is_channel_valid_ordered] = trials.name; trials = orderfields(trials,[1:16,18,17:17]); trials = rmfield(trials,'name');
trials_validchannels_marked_B = trials;
% save('trials_with_valid_channels_marked.mat', 'trials_validchannels_marked'); % saves the trials structure within the folder. 
% within the script there will be a save line with a formal naming
% convention. For this individual function, can add in to check individual
% sessions.