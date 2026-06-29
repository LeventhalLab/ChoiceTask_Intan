function valid_channels = valid_bipolar_from_qc(qc_channels, probe_type)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    qc_channels
    probe_type
end

probe_site_mapping = probe_site_mapping_all_probes(probe_type);  % monopolar mapping
num_sites = length(probe_site_mapping);   % assume each row is a recording channel

switch lower(probe_type)
    case 'nn8x8'
        sites_per_column = 8;
    case 'assy156'
        sites_per_column = 16;
    case 'assy236'
        sites_per_column = 16;
end
num_columns = num_sites / sites_per_column;
num_bipolar_lfps = num_sites - num_columns;

cur_site = 0;
valid_channels = true(num_bipolar_lfps, 1);
for i_sitecol = 1 : num_columns

    column_channels = probe_site_mapping((i_sitecol-1)*sites_per_column + 1 : i_sitecol * sites_per_column);

    for i_site = 1 : sites_per_column - 1
        cur_site = cur_site + 1;
        if any(qc_channels(column_channels(i_site:i_site+1))==1)
            % at least one of the two channels that went into calculating
            % this bipolar channel was bad
            valid_channels(cur_site) = false;
        end
    end
end

end