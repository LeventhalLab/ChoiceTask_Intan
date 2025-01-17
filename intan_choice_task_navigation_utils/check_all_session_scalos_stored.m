function all_sessions_stored = check_all_session_scalos_stored(session_name, lfp_type, event_name, probe_lfp_type, trial_features, scalo_folder)
%
%

all_sessions_stored = true;

n_trialfeatures = length(trial_features);

probe_parts = split(probe_lfp_type, '_');
% which style of probe was used?
switch lower(probe_parts{1})
    case 'nn8x8'
        % 8 shanks with 8 sites each
        sites_per_column = 8;
        n_mono_channels = 64;
        n_shanks = 8;
    case 'assy156'
        sites_per_column = 16;
        n_mono_channels = 64;
        n_shanks = 4;
    case 'assy236'
        sites_per_column = 16;
        n_mono_channels = 64;
        n_shanks = 4;
end
% monopolar vs bipolar
switch lower(probe_parts{2})

    case 'monopolar'
        signals_per_column = sites_per_column;
        n_channels = n_mono_channels;
    case 'bipolar'
        signals_per_column = sites_per_column - 1;
        n_channels = n_mono_channels - n_shanks;
end

for i_channel = 1 : n_channels

    [shank_num, site_num] = get_shank_and_site_num(probe_lfp_type, i_channel);

    for i_trialfeature = 1 : n_trialfeatures
        trial_feature = trial_features{i_trialfeature};

        scalo_name = sprintf('%s_scalos_%s_%s_%s_shank%02d_site%02d.mat',session_name, lfp_type, trial_feature, event_name, shank_num, site_num);
        scalo_name = fullfile(scalo_folder, scalo_name);

        if ~exist(scalo_name, 'file')
            all_sessions_stored = false;
            return
        end

    end

end