function rat_folders = get_rat_folders(parent_directory)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

test_string = fullfile(parent_directory, 'R*');
folder_list = dir(test_string);

n_poss_folders = length(folder_list);
n_rat_folders = 0;
ratID_pattern = 'R' + digitsPattern(4);

for i_folder = 1 : n_poss_folders

    if folder_list(i_folder).isdir
        if matches(folder_list(i_folder).name, ratID_pattern)
            n_rat_folders = n_rat_folders + 1;
            rat_folders{n_rat_folders} = folder_list(i_folder).name;
        end
    end

end

if ~exist('rat_folders', 'var')
    rat_folders = {};
end