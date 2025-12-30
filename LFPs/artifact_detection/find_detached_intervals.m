function detached_intervals = find_detached_intervals(session_qc_check,session_name)
%UNTITLED4 Summary of this function goes here
%   function that will take the information from channels_qc_final.xlsx
%   (stored in session_qc_check) and extract the times when the rat was
%   disconnected for this session
%   INPUTS
%
%   OUTPUTS
%       detached_intervals - n x 2 array where each row is a (start time,
%       end time) pair for when the rat was detached and reattached

arguments (Input)
    session_qc_check
    session_name
end

arguments (Output)
    detached_intervals
end

cur_session_idx = strcmp(session_qc_check.session, session_name);
if ~any(cur_session_idx)
    detached_intervals = [];
    return
end

n_detached_intervals = sum(cur_session_idx);
detached_indices = find(cur_session_idx);
detached_intervals = zeros(n_detached_intervals, 2);

for i_int = 1 : n_detached_intervals

    detached_intervals(i_int, 1) = session_qc_check.detachtime(detached_indices(i_int));
    detached_intervals(i_int, 2) = session_qc_check.reattachtime(detached_indices(i_int));

end

end