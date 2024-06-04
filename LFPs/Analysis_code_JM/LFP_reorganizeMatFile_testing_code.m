%%Organize lfp mat file by shank
%lfp.mat file is organized by amplifier number (0:63)
%down-sampled rate is 500 (starting sample rate is 20000kHz

lfp_shank1 = lfp(49:56,:);
lfp_shank2 = lfp(57:64,:);
lfp_shank3 = lfp([33:35, 37:39, 41:42],:);
lfp_shank4 = lfp([35,40,43:48],:);
lfp_shank5 = lfp([17:22,26,30],:);
lfp_shank6 = lfp([23:25, 27:29, 31:32],:);
lfp_shank7 = lfp(1:8,:);
lfp_shank8 = lfp(9:16,:);
lfp_amplifier = cat(1,lfp_shank1, lfp_shank2, lfp_shank3, lfp_shank4, lfp_shank5, lfp_shank6, lfp_shank7, lfp_shank8);
% This lfp_amplifier is ordered by amplifier number. See below for organization
% based on NNsite number

%% Verify data is correctly ordered and rearranged by amplifier channel

%Shank1
verify_lfp_shank1 = lfp_shank1(:,1:1000); %all 8 sites ordered by amplifier channel, first 1000 data points.
verify_lfp_original = lfp(49:56, 1:1000); 
verify_lfp_lfpAll = lfp_amplifier(1:8, 1:1000);
%Shank2
verify_lfp_shank2 = lfp_shank2(:,1:1000); %all 8 sites ordered by amplifier channel, first 1000 data points.
verify_lfp_original2 = lfp(57:64,1:1000);
verify_lfp_lfpAll2 = lfp_amplifier(9:16, 1:1000);

%Code above can be edited to verify for other shanks; did the two above for
%proof of principle and they seem accurate JM 2022/04/29

%% Order the lfp_shank data in the order of the NNsite. Try code here:

lfp_NNsite_shank1 = lfp_shank1([2,7,1,8,4,5,3,6],:); % all 8 sites on shank ordered from ventral to dorsal; 
% goal is to analyze neighboring sites (ordering by NNSite might make the diff function easier)
lfp_NNsite_shank2 = lfp_shank2([2,7,1,8,4,5,3,6],:);
lfp_NNsite_shank3 = lfp_shank3([1,8,2,7,3,6,4,5],:);
lfp_NNsite_shank4 = lfp_shank4([3,1,5,2,6,4,7,8],:);
lfp_NNsite_shank5 = lfp_shank5([8,5,7,3,6,4,2,1],:);
lfp_NNsite_shank6 = lfp_shank6([2,7,1,8,4,5,3,6],:);
lfp_NNsite_shank7 = lfp_shank7([1,8,2,7,3,6,4,5],:);
lfp_NNsite_shank8 = lfp_shank8([1,8,2,7,3,6,4,5],:);
lfp_all = cat(1,lfp_NNsite_shank1, lfp_NNsite_shank2, lfp_NNsite_shank3, lfp_NNsite_shank4, lfp_NNsite_shank5, lfp_NNsite_shank6, lfp_NNsite_shank7, lfp_NNsite_shank8);

%Alternatively can be written as (if pulled from the amplifier organized file previously NOT directly from actual NN site mapping of the H64LP map):
lfp_NNsite_shank1 = lfp_amplifier([2,7,1,8,4,5,3,6],:);
lfp_NNsite_shank2 = lfp_amplifier([10,15,9,16,12,13,11,14],:);
lfp_NNsite_shank3 = lfp_amplifier([17,24,18,23,19,22,20,21],:);
lfp_NNsite_shank4 = lfp_amplifier([27,25,29,26,30,28,31,32],:);
lfp_NNsite_shank5 = lfp_amplifier([40,37,39,35,38,36,34,33],:);
lfp_NNsite_shank6 = lfp_amplifier([42,47,41,48,43,46,45,44],:);
lfp_NNsite_shank7 = lfp_amplifier([49,56,50,55,51,54,52,53],:);
lfp_NNsite_shank8 = lfp_amplifier([57,64,58,63,59,62,60,61],:);
lfp_NNsite = cat(1,lfp_NNsite_shank1, lfp_NNsite_shank2, lfp_NNsite_shank3, lfp_NNsite_shank4, lfp_NNsite_shank5, lfp_NNsite_shank6, lfp_NNsite_shank7, lfp_NNsite_shank8);
%% Verify data from NNsite oriented file to the original lfp file
%Use site 17 as an example
% remember the original lfp.mat file is ordered 0:63 (not 1:64)

verify_lfp_site17 = lfp_NNsite(17,1:1000); % these three are correct. 
% This one is a 'bad' example as an individual line to pull out for verification
%because the amplifier order matches the NNsite concatanated order (showing
%for proof that you need to verify multiple sites not just one).
verify_lfp_site17_amplifier = lfp_amplifier(17,1:1000);
verify_lfp_site17_fromOriginal = lfp(33, 1:1000);

% Try site 29
verify_lfp_site29 = lfp_NNsite(32,1:1000); 
verify_lfp_site29_ampflifier = lfp_amplifier(32,1:1000);
verify_lfp_site29_fromOriginal = lfp(48, 1:1000);

%% Use diff function to write a for loop for comparing neighboring sites

% diff_1 = diff(lfp_NNsite(1:8,:)); - this runs the diff function
% on shank 1 by neighboring NNsite. Work on writing this as a for loop to
% run through all 8 shank_NNsite

% diff_1 = diff(lfp_NNsite(1:8,:)); %shank1
% diff_2 = diff(lfp_NNsite(9:16,:)); %shank2

%    diff_1  = diff(lfp_NNsite(1:8,:));
%    diff_1 = diff(lfp_NNsite(1:nrows <= 8, :));
%    diff_2 = diff(lfp_NNsite(9:16,:));
%    diff_3 = diff(lfp_NNsite(17:24,:));
%    diff_4 = diff(lfp_NNsite(25:32,:));
%    diff_5 = diff(lfp_NNsite(33:40,:));
%    diff_6 = diff(lfp_NNsite(41:48,:));
%    diff_7 = diff(lfp_NNsite(49:56,:));
%    diff_8 = diff(lfp_NNsite(57:end,:))

num_shanks = 8; %number of shanks on NN probe
num_sites = size(lfp_NNsite, 1);
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
    diff_lfps(diff_start_row:diff_end_row, :) = diff(lfp_NNsite(orig_start_row:orig_end_row, :));
end