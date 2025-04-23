function rd_metadata = parse_rawdata_folder(raw_data_folder)
% 
%
% INPUTS
%   raw_data_folder - the session folder inside the RXXXX-rawdata
%       folder. of the form RXXXX_YYYYMMDDz, z = "a", "b", etc.
%
% OUTPUTS:
%   rd_metadata - structure with the following fields:
%       .ratID - ratID in format "RXXXX" where XXXX is a 4-digit number
%       .datevec - date vector containing month, day, year recording was
%           made
%       .session_name - ratID_YYYYMMDDz, where z is "a", "b", "c", etc.

% [root_folder, rd_folder, ~] = fileparts(raw_data_folder);
[~, session_folder, ~] = fileparts(raw_data_folder);

% nameparts = split(rd_folder, '_');
nameparts = split(session_folder, '_');

rd_metadata.ratID = nameparts{1};
try
    date_string = nameparts{2}(1:8);
catch
    keyboard
end
rd_metadata.datevec = datevec(date_string, 'yyyymmdd');
rd_metadata.session_name = session_folder;