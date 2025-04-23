function session_pgf = create_processedgraphs_folder(rd_metadata, parent_directory)
%
% INPUTS
%   rd_metadata - structure with the following fields:
%       .ratID - ratID in format "RXXXX" where XXXX is a 4-digit number
%       .datevec - date vector containing month, day, year recording was
%           made
%       .session_name - ratID_YYYYMMDDz, where z is "a", "b", "c", etc.
%   

pgf = strcat(rd_metadata.ratID, '-processed-graphs');

session_pgf = fullfile(parent_directory, rd_metadata.ratID, pgf, rd_metadata.session_name);

if ~isfolder(session_pgf)
    
    mkdir(session_pgf)
    
end

end