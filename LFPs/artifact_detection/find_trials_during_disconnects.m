function trials_during_disconnects = find_trials_during_disconnects(session_qc_check, session_name, trials, event_name, t_win)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% INPUTS
%
% OUTPUTS
%   trials_during_disconnects - boolean vector containing true for trials
%       in which the event in question occurred within t_win seconds of the
%       rat between detached

arguments (Input)
    session_qc_check
    session_name
    trials
    event_name
    t_win
end

arguments (Output)
    trials_during_disconnects
end

detached_intervals = find_detached_intervals(session_qc_check,session_name);
n_intervals = size(detached_intervals, 1);

event_ts = extractEvent_ts( event_name, trials, false );
n_ts = length(event_ts);

if n_intervals == 0
    trials_during_disconnects = false(1, n_ts);
    return
end

trials_during_disconnects = false(1, n_ts);

for i_ts = 1 : n_ts

    for i_int = 1 : n_intervals
        if event_ts(i_ts) + t_win(2) > detached_intervals(i_int, 1) && event_ts(i_ts) - t_win(1) < detached_intervals(i_int, 2)
            trials_during_disconnects(i_ts) = true;
        end
    end
end

end

