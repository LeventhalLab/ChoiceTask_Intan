function ERPs_folder = create_ERPs_folder(session_name,parent_directory)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

session_name_parts = split(session_name,'_');
ratID = session_name_parts{1};
processed_folder = find_data_folder(ratID, 'processed', parent_directory);

session_folder = fullfile(processed_folder, session_name);

if exist(session_folder, 'dir')
    ERPs_folder = sprintf('%s_ERPs', session_name);
    ERPs_folder = fullfile(session_folder, ERPs_folder);
else
    ERPs_folder = '';
end

end