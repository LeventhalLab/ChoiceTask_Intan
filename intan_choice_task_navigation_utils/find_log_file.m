function log_fname = find_log_file(session_name, parent_directory)
%UNTITLED15 Summary of this function goes here
%   Detailed explanation goes here

session_name_parts = split(session_name, '_');
ratID = session_name_parts{1};
session_date = session_name_parts{2}(1:8);

rawdata_folder = find_data_folder(ratID, 'rawdata', parent_directory);
rawdata_session_folder = fullfile(rawdata_folder, session_name);

test_name = strcat(ratID, '_', session_date, '_*.log');
test_name = fullfile(rawdata_session_folder, test_name);

poss_logs = dir(test_name);

log_fname = '';
if isempty(poss_logs)
    sprintf('no log file found for %s', session_name);
else
    for ii = 1 : length(poss_logs)
        if contains(poss_logs(ii).name, 'old')
            continue
        else
            log_fname = fullfile(poss_logs(ii).folder, poss_logs(ii).name);
        end
    end
end

end