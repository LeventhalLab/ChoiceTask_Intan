function [ts,event_name] = ts_from_trials(trials, event_name)
%Extracting time stamps from trial data for psth and rasters

num_trials = length(trials);

ts = NaN(num_trials, 1);

for i_trial = 1 : num_trials
    %see if the event name is a field in that trial and extract the 
    % time stamps if not continue
    if isfield(trials(i_trial).timestamps, event_name)
        event_timestamps = trials(i_trial).timestamps.(event_name);
        ts(i_trial) = event_timestamps(1);
   end

end

end
