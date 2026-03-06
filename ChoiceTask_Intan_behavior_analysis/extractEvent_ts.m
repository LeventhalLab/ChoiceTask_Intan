function [ event_ts ] = extractEvent_ts( eventName, trials, onlyCorrect, includealltrials )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

arguments
    eventName
    trials
    onlyCorrect
    includealltrials logical = false
end

if includealltrials
    event_ts = NaN(length(trials), 1);
else
    event_ts = [];
end
for iTrial = 1 : length(trials)
    tr = trials(iTrial);
    if onlyCorrect
        if ~tr.correct; continue; end
    end
    
    if isfield(tr.timestamps, eventName)
        try
            thisevent_timestamp = tr.timestamps.(eventName)(1);
        catch
            % this event doesn't have a timestamps for this trial - maybe the end of a
            % session as time expired
            thisevent_timestamp = NaN;
        end
        if includealltrials
            event_ts(iTrial) = thisevent_timestamp;
        else
            event_ts = [event_ts; thisevent_timestamp];
        end
    end

end

