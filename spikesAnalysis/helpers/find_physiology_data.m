function physiology_folder = find_physiology_data(session_dir)

physiology_folder = '';

[~, session_name, ~] = fileparts(session_dir);
str_parts = split(session_name, '_');
ratID = str_parts{1};


if length(str_parts) == 1
    % workaround for a poorly named folder
    return
end
if strcmpi('str_parts{2}', 'check')
    % workaround for a poorly named pair of folders
    return
end

session_datestr = str_parts{2}(1:8);   % assume yyyymmdd date format

rat_date = strcat(ratID, '_', session_datestr);

subdirs = dir(fullfile(session_dir, strcat(rat_date, '*')));

num_subdirs = length(subdirs);

for i_dir = 1 : num_subdirs

    cur_path = fullfile(session_dir, subdirs(i_dir).name);
    if isfolder(cur_path)
        
        % look for an amplifier.dat and info.rhd file
        amp_file = fullfile(cur_path, 'amplifier.dat');
        info_file = fullfile(cur_path, 'info.rhd');

        if isfile(amp_file) && isfile(info_file)
            physiology_folder = cur_path;
        end
    end

end

end