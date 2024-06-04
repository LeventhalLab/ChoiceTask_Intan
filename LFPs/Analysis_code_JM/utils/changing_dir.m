%%
data_parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
cd(data_parent_directory)
rat_directories = dir(data_parent_directory);

num_directories = length(rat_directories);

for i_dir = 1 : length(rat_directories)
    if rat_directories(i_dir).name(1) ~= 'R'
        % make sure name starts with 'R'
        disp(rat_directories(i_dir).name)
        continue;
    end
    
    if ~isfolder(rat_directories(i_dir).name)
        % make sure it's a directory
        disp(rat_directories(i_dir).name)
        continue;
    end
    % assume any directory that starts with 'R' is a rat directory
    
    cd(rat_directories(i_dir).name);
    
    % check that there is a processed data folder
    ratID = rat_directories(i_dir).name;
    if ~isfolder([ratID, '-processed'])
        % there is no processed data folder in this rat directory
        continue;
    end
    
% -- working here! recurse through subfolders (use if exist? or switch
% case?) to check for a .mat file
    
     cd('..');
     direct=dir([ratID '*']);
     numFolders = length(direct);

  %  dinfo = dir(fullfile(data_parent_directory, '**', '*.mat'));
  %  filenames = fullfile({dinfo.folder}, {dinfo.name}); % these two lines give filenames for the .mat files 
  
  % - trying to identify a way to recursively identify '_lfp.mat'files exist within the subfolders
    
        for iDir = 1:numFolders
            ii = iDir;
            cd(direct(ii).name);
            if isfile('_lfp.mat')
                continue;
            else
                cd('..');
            end
        end
    
    cd(data_parent_directory);
    
end   % end of loop through rat folders