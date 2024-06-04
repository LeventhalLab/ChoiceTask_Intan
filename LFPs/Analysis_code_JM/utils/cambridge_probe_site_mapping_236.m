function intan_to_site_map_ASSY236 = cambridge_probe_site_mapping_236(probe_type)

% INPUTS:
    % probe_type - this current mapping is for the  NeuroNexus H64LP A8x8 probe.
% OUTPUTS:
    % intan_to_site_map - structure containing reorganization of the lfp_amplifier
    % variable ordering each shank from ventral to dorsal

if strcmpi(probe_type, 'ASSY236')
    %this is how the lfp.mat file is organized
    %    lfp_organization = [1:64];
            
    %shank number - organized based on lfp.mat files generated in -processed
    %folders to match the intan_ampflier number; remember Intan_amplifer
    %numbers are 0:63, while matlab (aka .mat files) are 1:64
        intan_amplifier_ASSY236 = [1:32,...% Shank A % Verified 11/5/2022 JM
        33:64]; % Shank B
    
    
% Map sites ventral to dorsal on the NeuroNexus H64LP A8x8 probe.
% THIS SECTION ORDERS THE NN-SITE BASED ON THE ACTUAL AMPLIFIER ORDER FROM
% THE LFP.MAT FILE OR REARRANGE FROM LINE 14-21 ABOVE.
        Cambridge236_order = [1,9,21,4,26,5,20,27,...% Shank A % Verified 11/5/2022
        6,15,16,32,30,8,13,12,...
        11,25,17,3,23,2,10,18,...
        7,22,31,24,28,14,19,29,...
        54,46,59,37,34,51,41,49,...%shankB
        57,33,61,36,47,39,62,63,...
        48,58,44,53,35,50,64,45,...
        42,55,38,43,60,56,52,40]; 
    
   intan_to_site_map_ASSY236 = intan_amplifier_ASSY236(Cambridge236_order)';
end