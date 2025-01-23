function trials_with_artifacts = identify_bipolar_artifact_trials(trials, monopolar_artifact_ts, event_name, t_diff, probe_type, probe_site_mapping, i_channel)
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

switch lower(probe_type)
       case 'nn8x8'
        % 8 shanks with 8 sites each
        sites_per_column = 8;
    
    case 'assy156'
        sites_per_column = 16;

    case 'assy236'
        sites_per_column = 16;
end
signals_per_column = sites_per_column - 1;
% figure out which are the two relevant monopolar channels for this bipolar
% channel
% this can be figured out because the first bipolar channel is the
% difference between probe_site_mapping(1) and probe_site_mapping(2),
% second bipolar is probe_site_mapping(2) - probe_site_mapping(3), etc.
% UNTIL the bottom of the shank. 
column_num = ceil(i_channel / signals_per_column);          % shank number
site_num = i_channel - (column_num-1) * signals_per_column;   % site along that shank

top_mono_idx = (column_num-1) * sites_per_column + site_num;
bottom_mono_idx = top_mono_idx + 1;
mono_channels = [probe_site_mapping(top_mono_idx), probe_site_mapping(bottom_mono_idx)];

for i_trial = 1 : n_trials

    if isfield(trials(i_trial).timestamps, event_name)
        trial_ts = trials(i_trial).timestamps.(event_name);
        
        for mono_ch_idx = 1 : 2
            if length(trial_ts) > 1
                % workaround for occasional errors where mutliple
                % timestamps are identified at the end of a session
                trial_ts = trial_ts(1);
            end
            if isempty(trial_ts)
                % part of a trial occurred as time was running out, so some
                % timestamps exist but others do not in the same trial
                continue
            end

            trial_artifact_diff = abs(monopolar_artifact_ts{mono_ch_idx} - trial_ts);

            if any(trial_artifact_diff < t_diff)
                trials_with_artifacts(i_trial) = true;
            end
        end
    end


end

end