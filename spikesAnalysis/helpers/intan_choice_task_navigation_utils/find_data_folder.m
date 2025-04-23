function session_path = find_data_folder(session_name, data_type, parent_directory)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


str_parts = split(session_name, '_');
ratID = str_parts{1};

rd_folder = find_rat_data_folder(parent_directory, ratID, data_type);

if length(ratID) == 5
    session_path = rd_folder;    
elseif isfolder(fullfile(rd_folder, session_name))
    session_path = fullfile(rd_folder, session_name);
else
    session_path = '';
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rd_folder = find_rat_data_folder(parent_directory, ratID, data_type)

rat_folder = fullfile(parent_directory, ratID);
rd_folder = fullfile(rat_folder, strcat(ratID, '-', data_type));

end