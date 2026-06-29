function event = create_eeglab_event(trials, actual_Fs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    trials
    actual_Fs
end

n_trials = length(trials);
event = struct('type', [],...
    'position', [],...
    'latency', [],...
    'urevent', [],...
    'epoch', []);
n_events = 0;
for i_trial = 1 : n_trials
    if trials(i_trial).logConflict.isConflict
        continue
    end

    trialEventNames = fieldnames(trials(i_trial).timestamps);
    n_trialevents = length(trialEventNames);
    for i_trialevent = 1 : n_trialevents
        n_events = n_events + 1;
        event(n_events).type = trialEventNames{i_trialevent};
        % event(n_events).position;
        event(n_events).latency = trials(i_trial).timestamps.(trialEventNames{i_trialevent}) * actual_Fs;
        % event(n_events).urevent;
    end
end


end