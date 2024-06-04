function diff_lfps = diff_lfp_from_monopolar(monopolar_ordered_lfp,probe_type)
%UNTITLED8 Summary of this function goes here
% INPUTS
%   monopolar_ordered_lfp: num_channels x num_points array
%   probe_type: string containing probe type. possibilities are 'nn8x8',

num_sites = size(monopolar_ordered_lfp, 1);
num_points = size(monopolar_ordered_lfp, 2);
switch lower(probe_type)
    case 'nn8x8'
        % assume lfp is ordered such that monopolar_ordered_lfp(1:8,:) is
        % the signal from dorsal to ventral on shank 1,
        % monopolar_ordered_lfp(9:16,:) is the signal from dorsal to
        % ventral on shank 2, etc.

        sites_per_shank = 8;
        diff_sites_per_shank = sites_per_shank - 1;
        num_shanks = num_sites / sites_per_shank;

        num_diff_sites = diff_sites_per_shank * num_shanks;
        diff_lfps = zeros(num_diff_sites, num_points);

        for i_shank = 1 : num_shanks
            diff_chan_start_idx = (i_shank-1) * diff_sites_per_shank + 1;
            diff_chan_end_idx = i_shank * diff_sites_per_shank;

            mono_chan_start_idx = (i_shank-1) * sites_per_shank + 1;
            mono_chan_end_idx = i_shank * sites_per_shank;

            % take differences going down columns
            diff_lfps(diff_chan_start_idx:diff_chan_end_idx, :) = ...
                diff(monopolar_ordered_lfp(mono_chan_start_idx:mono_chan_end_idx,:),1,1);

        end

end


end