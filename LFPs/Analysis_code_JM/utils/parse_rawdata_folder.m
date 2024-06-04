function rd_metadata = parse_rawdata_folder(raw_data_folder)
% raw_data_folder should be the folder that actually contains the .dat
% intan files
[root_folder, rd_folder, ~] = fileparts(raw_data_folder);
[~, session_folder, ~] = fileparts(root_folder);

nameparts = split(rd_folder, '_');

rd_metadata.ratID = nameparts{1};
try
    date_string = nameparts{2}(1:8);
catch
    keyboard
end
rd_metadata.datevec = datevec(date_string, 'yyyymmdd');
rd_metadata.session_name = session_folder;