function intan_to_site_map_ASSY156 = cambridge_probe_site_mapping_156(probe_type)

% INPUTS:
    % probe_type - this current mapping is for the  NeuroNexus H64LP A8x8 probe.
% OUTPUTS:
    % intan_to_site_map - structure containing reorganization of the lfp_amplifier
    % variable ordering each shank from ventral to dorsal

if strcmpi(probe_type, 'ASSY156')
    %this is how the lfp.mat file is organized
    %    lfp_organization = [1:64];
            
    %shank number - organized based on lfp.mat files generated in -processed
    %folders to match the intan_ampflier number; remember Intan_amplifer
    %numbers are 0:63, while matlab (aka .mat files) are 1:64
        intan_amplifier_ASSY156 = [1:17,19:32,63,...% Shank A
        18,33:62, 64]; % Shank B
    
    
% Map sites ventral to dorsal on the NeuroNexus H64LP A8x8 probe.
% THIS SECTION ORDERS THE NN-SITE BASED ON THE ACTUAL AMPLIFIER ORDER FROM
% THE LFP.MAT FILE OR REARRANGE FROM LINE 14-21 ABOVE.
        Cambridge156_order = [22,14,16,24,12,20,8,10,...% Shank A. This is verified JM 11/5/2022
        21,9,19,32,2,17,29,5,...
        25,13,11,23,36,27,26,6,...
        18,28,4,31,1,30,3,7,...
        38,61,46,36,63,47,35,49,...% Shank B
        33,64,44,57,56,52,43,39,...
        34,48,62,37,58,60,42,53,...
        51,40,55,59,45,41,54,50];
  
  intan_to_site_map_ASSY156 = intan_amplifier_ASSY156(Cambridge156_order)';
   % intan_to_site_map = Cambridge156_order';
end