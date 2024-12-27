function session_pf = processed_data_folder_from_rd_metadata(rd_metadata, parent_directory)
%
% INPUTS
%   rd_metadata - structure with the following fields:
%       .ratID - ratID in format "RXXXX" where XXXX is a 4-digit number
%       .datevec - date vector containing month, day, year recording was
%           made
%       .session_name - ratID_YYYYMMDDz, where z is "a", "b", "c", etc.

pf = strcat(rd_metadata.ratID, '-processed');
session_pf = fullfile(parent_directory, rd_metadata.ratID, pf, rd_metadata.session_name);
