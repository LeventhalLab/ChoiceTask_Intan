function scalo_folder = scalo_folder_from_rd_metadata(rd_metadata, event_name, parent_directory)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

processed_session_folder = processed_data_folder_from_rd_metadata(rd_metadata, parent_directory);

if exist(processed_session_folder, 'dir')
    scalo_folder = sprintf('%s_scalos_%s', rd_metadata.session_name, event_name);
    scalo_folder = fullfile(processed_session_folder, scalo_folder);
else
    scalo_folder = '';
end

end