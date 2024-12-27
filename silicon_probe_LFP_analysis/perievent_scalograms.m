function [outputArg1,outputArg2] = perievent_scalograms(trials, lfp_file, eventList, t_win)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% possible events:
%   cueOn, houseLightOn, centerIn, centerOut

[lfp_folder, ~, ~] = fileparts(lfp_file);

n_trials = length(trials);
n_events = length(eventList);
n_trialevents = zeros(n_events, 1);   % number of trials with each event type; for pre-allocating arrays
trials_list = cell(n_events, 1);      % list of trials for each event so they can be matched up later      

for i_trial = 1 : n_trials

    tr = trials(i_trial);

    % figure out how many trials there are for each event
    for i_event = 1 : n_events
        eventName = eventList{i_event};
        if isfield(tr.timestamps, eventName)
            n_trialevents(i_event) = n_trialevents(i_event) + 1;
        end
    end
end

for i_event = 1 : n_events

    event_related_scalos = nan(n_events, )



outputArg1 = inputArg1;
outputArg2 = inputArg2;
end