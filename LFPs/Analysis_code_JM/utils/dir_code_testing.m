data_parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
cd(data_parent_directory)
rat_directories = dir(data_parent_directory);

ratID = 'R0326'
parentFolder = fullfile(data_parent_directory, ...
         ratID, ...
         [ratID '-processed']);

cd(parentFolder);
direct=dir([ratID '*']);
numFolders = length(direct);

for i_dir = 1 : length(rat_directories)
    if rat_directories(i_dir).name(1) ~= 'R'
        % make sure name starts with 'R'
        disp(rat_directories(i_dir).name)
        continue;
 %   end    
    %go through all dirs
    for i = 1:length(rat_directories) %ignore . and ..
          current_dir = rat_directories(i_dir).name;
          if (current_dir.isdir)
              cd(current_dir.name); %move to this directory and list all files
              fprintf(1, ' Stepped into directory %s/\n', current_dir.name)
              d = dir('_lfp.m'); %list all .m files starting with g
              for i = 1:length(d)
                  fprintf(1, 'Found the file %s\n', d(i).name)
              end
              %disp('moving up')
              cd('..') %go back up
          end
    end
    end
end
