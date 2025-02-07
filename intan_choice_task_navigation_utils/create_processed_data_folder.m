function session_pf = create_processed_data_folder(rd_metadata, parent_directory)
%
% INPUTS
%   rd_metadata - structure with the following fields:
%       .ratID - ratID in format "RXXXX" where XXXX is a 4-digit number
%       .datevec - date vector containing month, day, year recording was
%           made
%       .session_name - ratID_YYYYMMDDz, where z is "a", "b", "c", etc.

session_pf = processed_data_folder_from_rd_metadata(rd_metadata, parent_directory);

if ~isfolder(session_pf)
    
    mkdir(session_pf)
    
end