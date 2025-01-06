function all_scalos_calculated = check_scalograms_calculated(session_name, event_list, lfp_type, probe_type, parent_directory)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

all_scalos_calculated = true;

% lfp_fname = strcat(session_name, '_', lfp_type, '_lfp.mat');

probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);
n_events = length(event_list);

probe_site_mapping = probe_site_mapping_all_probes(probe_type);
probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);

n_channels = n_channels_from_probetype(probe_type, lfp_type);

for i_event = 1 : length(event_list)
    event_name = event_list{i_event};
    scalo_folder = create_scalo_folder(session_name,event_name,parent_directory);

    if ~exist(scalo_folder, 'dir')
        % haven't even created the folder yet for these scalograms, so
        % return false
        all_scalos_calculated = false;
        return
    end

    % loop through folders and see if all the files have been calculated
    for i_channel = 1 : n_channels
        [shank_num, site_num] = get_shank_and_site_num(probe_lfp_type, i_channel);
        scalo_name = sprintf('%s_scalos_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, event_name, shank_num, site_num);
        scalo_name = fullfile(scalo_folder, scalo_name);
        if ~exist(scalo_name, 'file')
            all_scalos_calculated = false;
            return
        end

    end

end

end