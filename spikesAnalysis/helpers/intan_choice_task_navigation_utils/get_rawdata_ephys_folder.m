function rawdata_ephys_folder = get_rawdata_ephys_folder(rawdata_folder,session_name)
%
% function to find the electrophysiology data folder given the top-level
% raw data directory and recording session name
%
% INPUTS
%   rawdata_folder - path to the raw data folder
%   session_name - session name of the form ratID_YYYYMMDDz, where z is "a", "b", "c", etc.
%
% OUTPUT
%   rawdata_ephys_folder - path to the raw electrophysiology data folder
%   for this session
%
% file structure:
%  parent_directory-->ratID-->ratID-rawdata-->session_name-->ephys_name
%
% session_name is of the form ratID_YYYYMMDDz, where z is "a", "b", "c", etc.
%
% ephys_name is of the form: ratID_YYYYMMDD_sessionType_YYMMDD_recordID
%  sessionType is 'ChAdvanced', 'Testing', etc.
%  not sure exactly what recordID is, it's something that the Intan
%  software creates

rawdata_session_folder = fullfile(rawdata_folder, session_name);

session_name_parts = split(session_name, '_');
session_date_str = session_name_parts{2}(1:8);
intan_date_str = session_date_str(3:8);

test_name = strcat(session_name_parts{1}, '_', session_date_str, '*', intan_date_str, '*');
test_name = fullfile(rawdata_session_folder, test_name);

rawdata_ephys_dirs = dir(test_name);

if length(rawdata_ephys_dirs) == 1
    rawdata_ephys_folder = fullfile(rawdata_ephys_dirs.folder, rawdata_ephys_dirs.name);
elseif length(rawdata_ephys_dirs) > 1
    sprintf('multiple ephys folders found for %s', session_name)
    rawdata_ephys_folder = '';
else
    sprintf('no ephys folders found for %s', session_name)
    rawdata_ephys_folder = '';
end

end