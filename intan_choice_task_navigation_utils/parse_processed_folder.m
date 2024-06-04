function pd_processed_data = parse_processed_folder(processed_data_folder)
% raw_data_folder should be the folder that actually contains the .dat
% intan files
[root_folder, pd_folder, ~] = fileparts(processed_data_folder);

nameparts = split(pd_folder, '_');

pd_processed_data.ratID = nameparts{1};
try
    date_string = nameparts{2}(1:8);
catch
    keyboard
end
pd_processed_data.datevec = datevec(date_string, 'yyyymmdd');
pd_processed_data.session_name = pd_folder;