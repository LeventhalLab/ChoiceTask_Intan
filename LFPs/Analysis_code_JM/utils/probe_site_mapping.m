function intan_to_site_map = probe_site_mapping(probe_type)

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
        intan_amplifier = [49:56,...%shank1, nn sites 1-8
        57:64,...%shank2
        33:35, 37:39, 41:42,...%shank3
        35,40,43:48,...%shank4
        17:22,26,30,...%shank5
        23:25, 27:29, 31:32,...%shank6
        1:8,...%shank7
        9:16]; %shank8
    
    
% Map sites ventral to dorsal on the NeuroNexus H64LP A8x8 probe.
% THIS SECTION ORDERS THE NN-SITE BASED ON THE ACTUAL AMPLIFIER ORDER FROM
% THE LFP.MAT FILE OR REARRANGE FROM LINE 14-21 ABOVE.
        NNsite_order = [2,7,1,8,4,5,3,6,... %shank 1
        10,15,9,16,12,13,11,14,... %shank2
        17,24,18,23,19,22,20,21,...%shank3
        27,25,29,26,30,28,31,32,...%shank4
        40,37,39,35,38,36,34,33,...%shank5
        42,47,41,48,43,46,45,44,...%shank6
        49,56,50,55,51,54,52,53,...%shank7
        57,64,58,63,59,62,60,61];  %shank8
    
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
    
   intan_to_site_map = intan_amplifier(NNsite_order)';
   %intan_to_site_map = NNsite_order';
   
elseif strcmpi(probe_type, 'ASSY156')
     intan_amplifier_ASSY156 = [1:17,19:32,63,...% Shank A
        18,33:62, 64]; % Shank B
    
     Cambridge156_order = [22,14,16,24,12,20,8,10,...% Shank A. This is verified JM 11/5/2022
        21,9,19,32,2,17,29,5,...
        25,13,11,23,36,27,26,6,...
        18,28,4,31,1,30,3,7,...
        38,61,46,36,63,47,35,49,...% Shank B
        33,64,44,57,56,52,43,39,...
        34,48,62,37,58,60,42,53,...
        51,40,55,59,45,41,54,50];

     intan_to_site_map = intan_amplifier_ASSY156(Cambridge156_order)';

elseif strcmpi(probe_type, 'ASSY236')
    intan_amplifier_ASSY236 = [1:32,...% Shank A % Verified 11/5/2022 JM
        33:64]; % Shank B
    Cambridge236_order = [1,9,21,4,26,5,20,27,...% Shank A % Verified 11/5/2022
        6,15,16,32,30,8,13,12,...
        11,25,17,3,23,2,10,18,...
        7,22,31,24,28,14,19,29,...
        54,46,59,37,34,51,41,49,...%shankB
        57,33,61,36,47,39,62,63,...
        48,58,44,53,35,50,64,45,...
        42,55,38,43,60,56,52,40];
    intan_to_site_map = intan_amplifier_ASSY236(Cambridge236_order)';
end