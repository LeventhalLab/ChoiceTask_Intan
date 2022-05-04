function lfp_NNsite_diff = diff_probe_site_mapping(probe_type);

%   OUTPUTS - % diff_probe_site_mapping - structure containing the differences
%       between neighboring sites of an NN8x8 probe ventral to dorsal

cd 'X:\Neuro-Leventhal\data\ChoiceTask\R0326\R0326-processed\R0326_20200227a';
load('R0326_20200227a_lfp.mat');

num_shanks = 8; %number of shanks on NN probe
num_sites = size(lfp, 1);
sites_per_shank = num_sites/num_shanks;
num_lfp_points = size(lfp, 2);
% pre-allocate memory for differential LFPs
num_diff_rows = num_sites - num_shanks;
diff_lfps = zeros(num_diff_rows, num_lfp_points); 

probe_type = 'NN8x8';
intan_to_site_map = probe_site_mapping(probe_type);

for i_shank = 1 : num_shanks
    diff_start_row = (i_shank - 1) * (sites_per_shank - 1) + 1;
    diff_end_row = i_shank * (sites_per_shank - 1);
    orig_start_row = (i_shank - 1) * sites_per_shank + 1;
    orig_end_row = i_shank * sites_per_shank;
    diff_lfps(diff_start_row:diff_end_row, :) = diff(lfp(intan_to_site_map(orig_start_row:orig_end_row), :));
    lfp_NNsite_diff = diff_lfps;
end