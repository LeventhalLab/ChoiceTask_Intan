function lfp_fname = create_lfp_fname(rd_metadata, lfp_type)
%
% INPUTS
%   rd_metadata - structure with the following fields:
%       .ratID - ratID in format "RXXXX" where XXXX is a 4-digit number
%       .datevec - date vector containing month, day, year recording was
%           made
%       .session_name - ratID_YYYYMMDDz, where z is "a", "b", "c", etc.
%   lfp_type - 'monopolar' or 'bipolar'
%
% OUTUPUTS
%   lfp_fname - filename for the lfp file. Does NOT include full path, just
%       the file name

if isempty(lfp_type)
    lfp_fname = strjoin({rd_metadata.session_name, 'lfp.mat'}, '_');
else
    lfp_fname = strjoin({rd_metadata.session_name, lfp_type, 'lfp.mat'}, '_');
end
    

% lfp_fname = strcat(rd_metadata.ratID, '_', rd_metadata.session_name(7:end), '_lfp.mat');