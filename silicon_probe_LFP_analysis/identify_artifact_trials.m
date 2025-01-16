function trials_with_artifacts = identify_artifact_trials(trials, artifact_timestamps, event_name, t_diff)
% determine if the perievent LFP for each trial includes an artifact
%
% INPUTS
%   trials - trials structure
%   artifact_timestamps - vector of timestamps of identified artifacts for
%       this channel
%   event_name - name of the event we're looking at (e.g., 'CueOn')
%   t_diff - time difference from the event to the artifact for which it
%       would be considered a contaminant
%
% OUTPUTS:
%   trials_with_artifacts - boolean array with true whenever an artifact
%       occurred within t_diff of that event for that trial

n_trials = length(trials);

trials_with_artifacts = zeros(n_trials, 1, 'logical');
for i_trial = 1 : n_trials

    if isfield(trials(i_trial).timestamps, event_name)
        trial_ts = trials(i_trial).timestamps.(event_name);

        trial_artifact_diff = abs(artifact_timestamps - trial_ts);

        if any(trial_artifact_diff < t_diff)
            trials_with_artifacts(i_trial) = true;
        end
    end


end

end