function channel_num = map_shanksite2channel(i_col, i_site, probe_type)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

switch lower(probe_type)
    case 'nn8x8'
        % 8 shanks with 8 sites each
        sites_per_col = 8;
        n_shanks = 8;
        cols_per_shank = 1;
    case 'assy156'
        sites_per_col = 16;
        n_shanks = 2;
        cols_per_shank = 2;
    case 'assy236'
        sites_per_col = 16;
        n_shanks = 2;
        cols_per_shank = 2;
end

intan_to_site_map = probe_site_mapping_all_probes(probe_type);

% need to figure out the original row in the raw data stream given the
% column number and site number. This is to match the lines labeled
% manually as bad with the sites

% this is the number of the site on the probe if labels were continuous in
% a single vector, going from most dorsal site in 1st column on shank 1 to
% the most ventral site on the last column of the last shank
site_on_probe = (i_col-1) * sites_per_col + i_site;

channel_num = intan_to_site_map(site_on_probe);
% column_num = ceil(row_idx / signals_per_column);
% site_num = row_idx - (column_num-1) * signals_per_column;

end