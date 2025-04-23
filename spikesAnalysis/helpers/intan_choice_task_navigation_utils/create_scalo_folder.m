function scalo_folder = create_scalo_folder(session_name,event_name,parent_directory)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

session_name_parts = split(session_name,'_');
ratID = session_name_parts{1};
processed_folder = find_data_folder(ratID, 'processed', parent_directory);

session_folder = fullfile(processed_folder, session_name);

if exist(session_folder, 'dir')
    scalo_folder = sprintf('%s_scalos_%s', session_name, event_name);
    scalo_folder = fullfile(session_folder, scalo_folder);
else
    scalo_folder = '';
end

end