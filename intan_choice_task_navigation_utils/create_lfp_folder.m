function lfp_path = create_lfp_folder(rd_metadata, parent_directory)
%
% INPUTS
%   rd_metadata - structure with the following fields:
%       .ratID - ratID in format "RXXXX" where XXXX is a 4-digit number
%       .datevec - date vector containing month, day, year recording was
%           made
%       .session_name - ratID_YYYYMMDDz, where z is "a", "b", "c", etc.

processed_folder = create_processed_data_folder(rd_metadata, parent_directory);
% lfp_folder_name = strjoin({rd_metadata.session_name, 'LFPs'}, '_');

lfp_path = processed_folder; % fullfile(processed_folder, lfp_folder_name);

if ~isfolder(lfp_path)
    
    mkdir(lfp_path)
    
end