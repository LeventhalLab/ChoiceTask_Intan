function chanlocs = create_eeglab_chanlocs(probe_type, lfp_type)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    probe_type
    lfp_type
end

if strcmpi(lfp_type, 'bipolar')
    subtract_site_num = 1;
else
    subtract_site_num = 0;
end


switch lower(probe_type)
    case 'nn8x8'
        sites_per_shank = 8 - subtract_site_num;
        n_shanks = 8;
    case 'assy156'
        sites_per_shank = 16 - subtract_site_num;
        n_shanks = 4;
    case 'assy236'
        sites_per_shank = 16 - subtract_site_num;
        n_shanks = 4;
end

n_sites = n_shanks * sites_per_shank;
chanlocs(1:n_sites) = struct('theta', [], ...
    'radius', [], ...
    'labels', [], ...
    'sph_theta', [], ...
    'sph_phi', [], ...
    'sph_radius', [], ...
    'x', [], ...
    'y', [], ...
    'z', []);
site_idx = 1;
for i_shank = 1 : n_shanks
    for i_site = 1 : sites_per_shank
        chanlocs(site_idx).labels = sprintf('sh%dsite%d', i_shank, i_site);
        site_idx = site_idx + 1;
    end
end

end