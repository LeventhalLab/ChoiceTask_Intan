% Start with a folder and get a list of all subfolders.
% Finds and prints names of all PNG, JPG, and TIF images in 
% that folder and all of its subfolders.
clc;    % Clear the command window.
workspace;  % Make sure the workspace panel is showing.
% format longg;
% format compact;

% Define a starting folder.
start_path = fullfile(matlabroot, '\toolbox\images\imdemos');
% Ask user to confirm or change starting path.
data_parent_directory = uigetdir(start_path);
if data_parent_directory == 0
	return;
end
% Get list of all subfolders.
rat_directories = genpath(data_parent_directory);
% Parse into a cell array.
remain = rat_directories;
listOfFolderNames = {};
while true
	[singleSubFolder, remain] = strtok(remain, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames);

% Process all image files in those folders.
for k = 1 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
	%fprintf('Processing folder %s\n', thisFolder);
	
	% Get .mat files.
	filePattern = sprintf('%s/*.mat', thisFolder);
	baseFileNames = dir(filePattern);
 	numberOfMatFiles = length(baseFileNames);
    % Creates a list of all files in this folder.

	if numberOfMatFiles >= 1
		% Go through all of the .mat files.
		for f = 1 : numberOfMatFiles
			fullFileName = fullfile(thisFolder, baseFileNames(f).name);
			%fprintf('     Processing mat file %s\n', fullFileName);
            lfp_data = load(fullFileName);
        end
	else
		fprintf('     Folder %s has no mat files in it.\n', thisFolder);
    end
 end

