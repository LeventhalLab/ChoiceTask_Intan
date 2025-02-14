function scalo_plots_folder = create_scalo_plots_folder(session_name,trial_feature,parent_directory)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

session_name_parts = split(session_name,'_');
ratID = session_name_parts{1};
processed_graphs_folder = find_data_folder(ratID, 'processed-graphs', parent_directory);

session_folder = fullfile(processed_graphs_folder, session_name);

if exist(session_folder, 'dir')
    scalo_plots_folder = sprintf('%s_scaloplots_%s', session_name, trial_feature);
    scalo_plots_folder = fullfile(session_folder, scalo_plots_folder);
else
    scalo_plots_folder = '';
end

end