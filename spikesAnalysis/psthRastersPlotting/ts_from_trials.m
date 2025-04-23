function ts = ts_from_trials(trials, event_name)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

num_trials = length(trials);

ts = NaN(num_trials, 1);

for i_trial = 1 : num_trials

    if isfield(trials(i_trial).timestamps, event_name)
        ts(i_trial) = trials(i_trial).timestamps.(event_name);
    end

end

end
