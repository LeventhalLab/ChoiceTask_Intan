% create an lfp_NNsite file
% lfp_original = load('R0372_20201125a_lfp.mat'); - sample line of code to
% load in the lfp_mat file

function [ordered_lfp, intan_site_order, intan_site_order_for_trials_struct, site_order] = lfp_by_probe_site_ALL(lfp_data, probe_type)

% INPUTS - 
%   lfp_data - num_sites x num_points array containing the original lfp data 
%       ordered as recorded in the amplifier.dat file.
%   probe_type - probe type
%       'NN8x8' - Neuronexus 8x8 array
%       'ASSY156' - Cambridge Omnetics Connector H6 style probe 2 shank @ 4 column/shank @ 16 site/column
%       'ASSY236' - Cambridge Molex Connector H6 style probe 2 shank @ 4 column/shank @ 16 site/column
%       OTHER PROBE TYPE LABELS GO HERE
%
% OUTPUTS -
%   ordered_lfp - m x n array of *_lfp.mat file rearranged by shank #
%       and site # along the shank. That is, first 8 rows should be the 
%       lfp at each site on shank 1, ordered from ventral to dorsal
%   intan_site_order - order of electrode sites by shank from ventral to
%       dorsal. That is, the first 8 elements are the shank 1 sites from
%       ventral to dorsal, indicating which row of the original LFP file is
%       at each site
%   site_order - order of NeuroNexus sites for each shank. Note this is
%       DIFFERENT from the intan order (see
%       https://www.neuronexus.com/files/probemapping/64-channel/H64LP-Maps.pdf)

% lfp_data = load('R0326_20200228a_lfp.mat'); % Use this catch for confirming
% data in single files.

if strcmpi(probe_type, 'nn8x8')
    if isstring(lfp_data)
        if exist(lfp_data, 'file')
            lfp = load(lfp_data);
            lfp_data = lfp.lfp;
        else
            intan_site_order = [];
            return
        end
    else
       lfp_data = lfp_data.lfp;
    end

   intan_amplifier = lfp_data([49:56,...%shank1, nn sites 1-8
            57:64,...%shank2
            33:35, 37:39, 41:42,...%shank3
            36,40,43:48,...%shank4  --- This was wrong on 10/24/22, 35 was listed twice - once for shank 3 and once for shank 4. -- Changed to 36 and is now accurate 10/24/22
            17:22,26,30,...%shank5
            23:25, 27:29, 31:32,...%shank6
            1:8,...%shank7
            9:16],:); %shank8
   intan_site_order = [6,3,5,4,8,1,7,2,...%shank 1 % This is the postion of the NNsites positioned dorsal to ventral
       14,11,13,12,16,9,15,10,...%shank2
       21,20,22,19,23,18,24,17,...%shank3
       32,31,28,30,26,29,25,27,...%shank4
       33,34,36,38,35,39,37,40,...%shank5
       44,45,46,43,48,41,47,42,...%shank6
       53,52,54,51,55,50,56,49,...%shank7
       61,60,62,59,63,58,64,57]; %shank8
   intan_site_order_for_trials_struct = [54,51,53,52,56,49,55,50,...
       62,59,61,60,64,57,63,58,...
       38,37,39,35,41,34,42,33,...
       48,47,44,46,40,45,36,43,...
       17,18,20,22,19,26,21,30,...
       27,28,29,25,32,23,31,24,...
       5,4,6,3,7,2,8,1,...
       13,12,14,11,15,10,16,9];
   
%    intan_site_order = [2,7,1,8,4,5,3,6,... %shank 1 % This is the postion of the NNsites positioned ventral to dorsal
%             10,15,9,16,12,13,11,14,... %shank2
%             17,24,18,23,19,22,20,21,...%shank3
%             27,25,29,26,30,28,31,32,...%shank4
%             40,37,39,35,38,36,34,33,...%shank5
%             42,47,41,48,43,46,45,44,...%shank6
%             49,56,50,55,51,54,52,53,...%shank7
%             57,64,58,63,59,62,60,61];  %shank8

   site_order = [5,4,6,3,7,2,8,1,...%shank1 % These are literal site numbers for the NN probes % using this to name the sites in graphs going from dorsal to ventral
       13,12,14,11,15,10,16,9,...%shank2
       21,20,22,19,23,18,24,17,...%shank3
       29,28,30,27,31,26,32,25,...%shank4
       37,36,38,35,39,34,40,33,...%shank5
       45,44,46,43,47,42,48,41,...%shank6
       53,52,54,51,55,50,56,49,...%shank7
       61,60,62,59,63,58,64,57]; %shank8

%    site_order = [1,8,2,7,3,6,4,5,...%shank1 % These are literal site numbers for the NN probes % using this to name the sites in graphs going from ventral to dorsal
%             9,16,10,15,11,14,12,13,...%shank2
%             17,24,18,23,19,22,20,21,...%shank3
%             25,32,26,31,27,30,28,29,...%shank4
%             33,40,34,39,35,38,36,37, ...%shank5
%             41,48,42,47,43,46,44,45,...%shank6
%             49,56,50,55,51,54,52,53,...%shank7
%             57,64,58,63,59,62,60,61]; %shank8
        
ordered_lfp = intan_amplifier(intan_site_order, :);

elseif strcmpi(probe_type, 'ASSY156')
    if isstring(lfp_data)
        if exist(lfp_data, 'file')
            lfp = load(lfp_data);
            lfp_data = lfp.lfp;
        else
            intan_site_order = [];
            return
        end
    else
       lfp_data = lfp_data.lfp;
    end
     intan_amplifier = lfp_data([1:17,19:32,63,...% Shank A. This is verified JM 11/5/2022
        18,33:62, 64],:); % Shank B
    
    intan_site_order = [22,14,16,24,12,20,8,10,...% Shank A. This is verified JM 11/5/2022
        21,9,19,32,2,17,29,5,...
        25,13,11,23,36,27,26,6,...
        18,28,4,31,1,30,3,7,...
        38,61,46,36,63,47,35,49,...% Shank B
        33,64,44,57,56,52,43,39,...
        34,48,62,37,58,60,42,53,...
        51,40,55,59,45,41,54,50];
     intan_site_order_for_trials_struct = [23,14,16,25,12,21,8,10,... % WORKING ON VERIFYING IF THIS IS NEEDED - ONE TEST SUGGESTED YES BUT ANOTHER CHECK SUGGESTED THE ISSUE COULD BE FROM A DIFFERENT ISSUE
         22,9,20,63,2,17,30,5,...
         26,13,11,24,35,28,27,6,...
         19,29,4,32,1,31,3,7,...
         37,60,45,35,62,46,34,48,...
         18,64,43,56,55,51,42,38,...
         33,47,61,36,57,59,41,52,...
         50,39,54,58,44,40,53,49];
     site_order = [26,35,33,24,37,28,41,39,...% Shank A. This is verified JM 11/5/2022
         27,40,29,50,47,32,19,44,...
         23,36,38,25,34,21,22,43,...
         30,20,45,17,48,18,46,42,...
         12,53,4,14,51,3,15,1,...% Shank B
         31,49,6,57,58,62,7,11,...
         16,2,52,13,56,54,8,61,...
         63,10,59,55,5,9,60,64];
        
% this was the original order but changed it for A to be left probe and B
% to be right.
%      intan_site_order = [39,43,52,56,57,44,64,33,... % Shank B
%         49,35,47,63,36,46,61,38,...
%         50,54,41,45,59,55,40,51,...
%         53,42,60,58,37,62,48,34,...
%         5,29,17,2,32,19,9,21,... % Shank A
%         10,8,20,12,24,16,14,22,...
%         7,3,30,1,31,4,28,18,...
%         6,26,27,36,23,11,13,25];
%      site_order = [31,49,6,57,58,62,7,11,...
%          12,53,4,14,51,3,15,1,...
%          63,10,59,55,5,9,60,64,...
%          16,2,52,13,56,54,8,61,...
%          27,40,29,50,47,32,19,44,...
%          26,35,33,24,37,28,41,39,...
%          30,20,45,17,48,18,46,42,...
%          23,36,38,25,34,21,22,43];

ordered_lfp = intan_amplifier(intan_site_order, :);   

elseif strcmpi(probe_type, 'ASSY236')
    if isstring(lfp_data)
        if exist(lfp_data, 'file')
            lfp = load(lfp_data);
            lfp_data = lfp.lfp;
        else
            intan_site_order = [];
            return
        end
    else
       lfp_data = lfp_data.lfp;
    end
    intan_amplifier = lfp_data([1:32,...% Shank A % Verified 11/5/2022 JM
        33:64],:); % Shank B
    intan_site_order = [1,9,21,4,26,5,20,27,...% Shank A % Verified 11/5/2022
        6,15,16,32,30,8,13,12,...
        11,25,17,3,23,2,10,18,...
        7,22,31,24,28,14,19,29,...
        54,46,59,37,34,51,41,49,...%shankB
        57,33,61,36,47,39,62,63,...
        48,58,44,53,35,50,64,45,...
        42,55,38,43,60,56,52,40];
    intan_site_order_for_trials_struct = [1,9,21,4,26,5,20,27,...% Shank A % Verified 11/5/2022
        6,15,16,32,30,8,13,12,...
        11,25,17,3,23,2,10,18,...
        7,22,31,24,28,14,19,29,...
        54,46,59,37,34,51,41,49,...%shankB
        57,33,61,36,47,39,62,63,...
        48,58,44,53,35,50,64,45,...
        42,55,38,43,60,56,52,40];
    site_order = [64,48,16,61,13,60,29,12,...% Shank A % Verified 11/5/2022
        59,32,42,24,9,57,44,45,...
        47,14,31,62,15,63,46,30,...
        58,27,10,26,25,43,28,11,...
        34,18,54,23,7,38,22,40,...%shankB
        56,8,52,5,17,3,51,50,...
        41,55,20,36,6,29,49,19,...
        1,35,4,21,53,33,37,2];

%     site_order = [56,8,52,5,17,3,51,50,...%shankB
%         34,18,54,23,7,38,22,40,...
%         1,35,4,21,53,33,37,2,...
%         41,55,20,36,6,39,49,19,...
%         59,32,42,24,9,57,44,45,...% Shank A
%         64,48,16,61,13,60,29,12,...
%         58,27,10,26,25,43,28,11,...
%         47,14,31,62,15,63,46,30];
    
ordered_lfp = intan_amplifier(intan_site_order, :);
end

end