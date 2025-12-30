function [outputArg1,outputArg2] = exclude_disconnects(session_qc_check, session_name, trials, event_name, t_win)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    session_qc_check
    session_name
    trials
    event_name
    t_win
end

arguments (Output)
    outputArg1
    outputArg2
end

detached_intervals = find_detached_intervals(session_qc_check,session_name);
n_intervals = size(detached_intervals, 1);

event_ts = extractEvent_ts( event_name, trials, false );
n_ts = length(event_ts);

if n_intervals == 0
    valid_trials = true(1, n_ts);
    return
end

trials_during_disconnect = false(1, n_ts);

for i_ts = 1 : n_ts

    for i_int = 1 : n_intervals
        if event_ts(i_ts) > detached_intervals(i_int, 1) && event_ts(i_ts) < detached_intervals(i_int, 2)
            trials_during_disconnect(i_ts) = true;
        end
    end
end

end

