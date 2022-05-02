% re-arrange monopolar field potentials into the order on shanks

% Test code to write in NNsite order; function lfp_NNsite =
% probe_site_mapping('NN8x8'); essentially does what this block is trying
% to do

% num_sites = size(lfp, 1);   % number of sites = number of rows in original lfp array
% num_lfp_points = size(lfp, 2);   %n number of points = number of columns in original lfp array
% % pre-allocate array
% lfps_by_shank = zeros(num_sites, num_lfp_points);
% num_shanks = 8;
% sites_per_shank = 8;
% for i_shank = 1 : num_shanks            % shank number
%     for i_site = 1 : num_shanks         % site number on each shank
%         lfp_row = (i_shank - 1) * 8 + i_site; % If i_shank = 1 then i_shank - 1 = 0 then this whole equation is 0 regardless of i_site? JM 20220501
%         % look up the row in the table containing the site ID - don't have that with me so 
%         % will need to look up variable names, etc.
%         orig_lfp_row = % code here to figure out which row is i_site on i_shank in original lfp array
%         lfps_by_shank(lfp_row, :) = lfp(orig_lfp_row, :);
%     end
% end

%% 

lfp_NNsite = probe_site_mapping('NN8x8');

% pre-allocate memory for differential LFPs
num_diff_rows = num_sites - num_shanks;
diff_lfps = zeros(num_diff_rows, num_lfp_points); 
for i_shank = 1 : num_shanks
    diff_start_row = (i_shank - 1) * (sites_per_shank - 1) + 1;
    diff_end_row = i_shank * (sites_per_shank - 1);
    orig_start_row = (i_shank - 1) * sites_per_shank + 1;
    orig_end_row = i_shank * sites_per_shank;
   % diff_lfps(diff_start_row:diff_end_row, :) = diff(lfps_by_shank(orig_start_row:orig_end_row, :));
   diff_lfps(diff_start_row:diff_end_row, :) = diff(lfp_NNsite(orig_start_row:orig_end_row, :));
end