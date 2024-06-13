function intan_to_site_map_DL = probe_site_mapping_all_probes(probe_type)
%
% INPUTS:
    % probe_type - this current mapping is for the  NeuroNexus H64LP A8x8 probe.
% OUTPUTS:
    % intan_to_site_map - structure containing reorganization of the lfp_amplifier
    % variable ordering each shank from ventral to dorsal

if strcmpi(probe_type, 'NN8x8')
    %this is how the lfp.mat file is organized
    %    lfp_organization = [1:64];
            
    %shank number - organized based on lfp.mat files generated in -processed
    %folders to match the intan_ampflier number; remember Intan_amplifer
    %numbers are 0:63, while matlab (aka .mat files) are 1:64
    % DL - this maps the numbering on the NeuroNexus omnetics connector to
    % the numbering on the Intan amplifier

    % NOTE: site 35 is entered twice in the matrix below
        % % % intan_amplifier = [49:56,...%shank1, nn sites 1-8
        % % % 57:64,...%shank2
        % % % 33:35, 37:39, 41:42,...%shank3
        % % % 35,40,43:48,...%shank4
        % % % 17:22,26,30,...%shank5
        % % % 23:25, 27:29, 31:32,...%shank6
        % % % 1:8,...%shank7
        % % % 9:16]; %shank8

    intan_amplifier_DL = [49, 48, 51, 50, 53, 52, 55, 54, ...
                          57, 56, 59, 58, 61, 60, 63, 62, ...
                          32, 33, 34, 36, 37, 38, 40, 41, ...
                          42, 44, 45, 46, 47, 43, 39, 35, ...
                          29, 25, 21, 17, 16, 19, 18, 20, ...
                          23, 22, 24, 27, 26, 28, 31, 30, ...
                          00, 01, 02, 03, 04, 05, 06, 07, ...
                          08, 09, 10, 11, 12, 13, 14, 15];
    % above is the actual intan channel numbers. Add one because Matlab
    % starts indexing at 1. Note that if this were ported to Python, would
    % NOT want to add 1 here
    intan_amplifier_DL = intan_amplifier_DL + 1;
    
    
% Map sites ventral to dorsal on the NeuroNexus H64LP A8x8 probe.
% THIS SECTION ORDERS THE NN-SITE BASED ON THE ACTUAL AMPLIFIER ORDER FROM
% THE LFP.MAT FILE OR REARRANGE FROM LINE 14-21 ABOVE.
% DL - this maps the ordering on the NN shank to the NN omnetics connector.
% Therefore, intan_amplifier(NNsite_order) gives the row in the original
% LFP file that corresponds to spatially ordered sites from DORSAL to
% VENTRAL
       % NNsite_order = [02, 07, 01, 08, 04, 05, 03, 06,... %shank 1
       %                 10, 15, 09, 16, 12, 13, 11, 14,... %shank2
       %                 17, 24, 18, 23, 19, 22, 20, 21,...%shank3
       %                 27, 25, 29, 26, 30, 28, 31, 32,...%shank4
       %                 40, 37, 39, 35, 38, 36, 34, 33,...%shank5
       %                 42, 47, 41, 48, 43, 46, 45, 44,...%shank6
       %                 49, 56, 50, 55, 51, 54, 52, 53,...%shank7
       %                 57, 64, 58, 63, 59, 62, 60, 61];  %shank8
%Dorsal-ventral probe site order below RL Verified 06/13/24    
    NNsite_order_DL = [05, 04, 06, 03, 07, 02, 08, 01, ...
                       13, 12, 14, 11, 15, 10, 16, 09, ...
                       21, 20, 22, 19, 23, 18, 24, 17, ...
                       29, 28, 30, 27, 31, 26, 32, 25, ...
                       37, 36, 38, 35, 39, 34, 40, 33, ...
                       45, 44, 46, 43, 47, 42, 48, 41, ...
                       53, 52, 54, 51, 55, 50, 56, 49, ...
                       61, 60, 62, 59, 63, 58, 64, 57];
    
%     % Map sites ventral to dorsal on the NeuroNexus H64LP A8x8 probe.
%     THIS CHUNK OF CODE IS THE LITERAL NEURONEXUS NUMBERS VENTRAL TO DORSAL ORDER.
%         NNsite_order = [1,8,2,7,3,6,4,5,... %shank 1
%         9,16,10,15,11,14,12,13,... %shank2
%         17,24,18,23,19,22,20,21,...%shank3
%         25,32,26,31,27,30,28,29,...%shank4
%         33,40,34,39,35,38,36,37,...%shank5
%         41,48,42,47,43,46,44,45,...%shank6
%         49,56,50,55,51,54,52,53,...%shank7
%         57,64,58,63,59,62,60,61];%shank8
    
   intan_to_site_map = intan_amplifier(NNsite_order)';            % THIS IS VENTRAL TO DORSAL
   intan_to_site_map_DL = intan_amplifier_DL(NNsite_order_DL)';   % THIS IS DORSAL TO VENTRAL
   
elseif strcmpi(probe_type, 'assy156')
    % Per Jen, Intan chip is facing down on the ASSY-156 probe, but this
    % numbering suggests the chip was facing up. This doesn't seem to match
    % with the way she did the NN mapping; for example, site 1 from
    % Cambridge DOES NOT map to site 0 intan. I redid the mapping and they
    % seem to match other than the duplication of site 36 in
    % Cambridge156_order
     intan_amplifier = [1:17,19:32,63,...% Shank A   
        18,33:62, 64]; % Shank B
     %verifying
     % intan_amplifier_DL = [47, 46, 45, 44, 43, 42, 41, 40, ...
     %                       39, 38, 37, 36, 35, 34, 33, 32, ...
     %                       31, 30, 29, 28, 27, 26, 25, 24, ...
     %                       23, 22, 21, 20, 19, 18, 17, 16, ...
     %                       15, 14, 13, 12, 11, 10, 09, 08, ...
     %                       07, 06, 05, 04, 03, 02, 01, 00, ...
     %                       63, 62, 61, 60, 59, 58, 57, 56, ...
     %                       55, 54, 53, 52, 51, 50, 49, 48];
     % intan_amplifier_DL = intan_amplifier_DL + 1;
%156 order is correct RL 06/04/2024 probe site order below
     Cambridge156_order_DL = [26, 35, 33, 24, 37, 28, 41, 39, ...
                              27, 40, 29, 50, 47, 32, 19, 44, ...
                              23, 36, 38, 25, 34, 21, 22, 43, ...
                              30, 20, 45, 17, 48, 18, 46, 42, ...
                              12, 53, 04, 14, 51, 03, 15, 01, ...
                              31, 49, 06, 57, 58, 62, 07, 11, ...
                              16, 02, 52, 13, 56, 54, 08, 61, ...
                              63, 10, 59, 55, 05, 09, 60, 64];
    % RL 06/07/24 1-64 scaled since matlab doesn't like zeros : intan order
    % below
     Cambridge156_intan_order= [23, 14, 16, 25, 12, 21, 8, 10, ...% Shank A.
                                22, 9, 20, 63, 2, 17, 30, 5,   ...
                                26, 13, 11, 23, 14, 27, 26, 6, ...
                                19, 29, 4, 32, 1, 31, 3, 7,    ...
                                37, 59, 47, 34, 62, 46, 34, 48,...% Shank B
                                18, 64, 43, 56, 55, 51, 42, 38,...
                                33, 47, 61, 36, 57, 59, 41, 52,...
                                50, 39, 54, 58, 44, 40, 53, 49];

     % THIS GOES FROM DORSAL TO VENTRAL - DL Intan order verified 61324 RL
%      intan_to_site_map = intan_amplifier(Cambridge156_order)';   
     intan_to_site_map_DL = (Cambridge156_intan_order)';   

elseif strcmpi(probe_type, 'assy236')

    % see Cambridge Neurotech Mini-Amp-64 User Guide 
    % this order assumes shank A is most lateral shank going dorsal to ventral  
    % verified intan site order 06/04/24 RL
    intan_amplifier_DL = [00, 08, 20, 03, 25, 04, 19, 26, ...
                          05,14,15,31,29,07,12,11, ...
                          10,24,16,02,22,01,09,17, ...
                          06,21,30,23,27,13,18,28, ...
                          53,45,58,36,33,50,40,48, ...
                          56,32,60,35,46,38,61,62, ...
                          47,57,43,52,34,49,63,44, ...
                          41,54,37,42,59,55,51,39];
     intan_amplifier_DL=  intan_amplifier_DL + 1;

     % verified probe site order below 06/13/24
     Cambridge236_order_DL = [64, 48, 16, 61, 13, 60, 29, 12, ...
                              59, 32, 42, 24, 09, 57, 44, 45, ...
                              47, 14, 31, 62, 15, 63, 46, 30, ...
                              58, 27, 10, 26, 25, 43, 28, 11, ...
                              34, 18, 54, 23, 07, 38, 22, 40, ...
                              56, 08, 52, 05, 17, 03, 51, 50, ...
                              41, 55, 20, 36, 06, 39, 49, 19, ...
                              01, 35, 04, 21, 53, 33, 37, 02];
%     intan_amplifier  = [1:32,...% Shank A % Verified 11/5/2022 JM
%         33:64]; % Shank B
%      Cambridge236_order = [1,9,21,4,26,5,20,27,...% Shank A % Verified 11/5/2022
%         6,15,16,32,30,8,13,12,...
%         11,25,17,3,23,2,10,18,...
%         7,22,31,24,28,14,19,29,...
%         54,46,59,37,34,51,41,49,...%shankB
%         57,33,61,36,47,39,62,63,...
%         48,58,44,53,35,50,64,45,...
%         42,55,38,43,60,56,52,40];
    
%    intan_to_site_map = intan_amplifier(Cambridge236_order)';
   intan_to_site_map_DL = (intan_amplifier_DL)';
end
end
