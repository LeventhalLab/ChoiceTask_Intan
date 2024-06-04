function pd_trials_data = parse_trials_struct_folder(trials_struct_folder)
% raw_data_folder should be the folder that actually contains the .dat
% intan files
[root_folder, pd_folder, ~] = fileparts(trials_struct_folder);

nameparts = split(pd_folder, '_');

pd_trials_data.ratID = nameparts{1};
try
    date_string = nameparts{2}(1:8);
catch
    keyboard
end
pd_trials_data.datevec = datevec(date_string, 'yyyymmdd');
pd_trials_data.session_name = pd_folder;