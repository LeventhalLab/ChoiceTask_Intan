function eventrelatedLFPs_saved = check_eventrelatedLFPs(session_name, event_list, lfp_type, probe_type, parent_directory)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

eventrelatedLFPs_saved = true;

probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);
n_events = length(event_list);

probe_site_mapping = probe_site_mapping_all_probes(probe_type);
probe_lfp_type = sprintf('%s_%s', probe_type, lfp_type);

n_channels = n_channels_from_probetype(probe_type, lfp_type);
ERPs_folder = create_ERPs_folder(session_name,parent_directory);
if ~exist(ERPs_folder, 'dir')
    % haven't even created the folder yet for these scalograms, so
    % return false
    eventrelatedLFPs_saved = false;
    return
end
for i_event = 1 : length(event_list)
    event_name = event_list{i_event};
    
    % [shank_num, site_num] = get_shank_and_site_num(probe_lfp_type, i_channel);
    ERPs_name = sprintf('%s_ERPs_%s_%s.mat',session_name, lfp_type, event_name);
    ERPs_name = fullfile(ERPs_folder, ERPs_name);
    if ~exist(ERPs_name, 'file')
        eventrelatedLFPs_saved = false;
        return
    end

end

end