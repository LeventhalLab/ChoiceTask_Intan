% regionPowerSplit
% ZHH 7/24/24

%makes heatmaps displaying power within each frequency band and region

% but modified in response to dan's suggestion: "You could also do the regions analysis
% and include any recording that has at least one site in the region 
% to see if that helps your n and shows anything."

% so in this script, an LFP contributes to a region if either one of its recording
% channels were in that region

% also creates a table at the end to show how many sessions and rats
% contributed to each region

%% load bigTable

 % Construct the full path to the .mat file
    filePath = fullfile('X:\Neuro-Leventhal\data\ChoiceTask\voxel power', 'bigTable.mat');

% Load only the first 51996 rows from the .mat file
if exist(filePath, 'file')
    load(filePath, 'bigTable');  % Load only the variable 'bigTable'
    % just up to R0466 bc there is no region or coordinates in the table
    % from 466 onwards
    bigTable = bigTable(1:min(51996, height(bigTable)), :);
else
    error(['File not found: ' filePath]);
end

excludeRatIDs = {'R0376', 'R0374', 'R0396', 'R0413'};
% Find rows with ratIDs to exclude
rowsToExclude = ismember(bigTable.RatID, excludeRatIDs);
% Exclude rows from bigTable
filteredTable = bigTable(~rowsToExclude, :);

% Initialize the modified table with the original table
modifiedTable = filteredTable;

% Convert cell arrays to strings for comparison
regionTop_str = string(filteredTable.RegionTop);
regionBot_str = string(filteredTable.RegionBot);

% Find rows where regionTop is not equal to regionBot
idx_different = regionTop_str ~= regionBot_str;

% Duplicate rows where regionTop is not equal to regionBot
duplicatedRows = modifiedTable(idx_different, :);

% Update the RegionSingle column in duplicated rows
duplicatedRows.RegionSingle = regionBot_str(idx_different);

modifiedTable.RegionSingle(:) = "";

% Concatenate modifiedTable and duplicatedRows
modifiedTable = [modifiedTable; duplicatedRows];

% Update RegionSingle for original rows where regionTop equals regionBot
modifiedTable.RegionSingle(~idx_different) = modifiedTable.RegionBot(~idx_different);
modifiedTable.RegionSingle(idx_different) = regionTop_str(idx_different);

%%

%%
figure;
t= tiledlayout("vertical");
t.TileSpacing = 'none';
t.Padding = 'none';
ylabel(t,'Frequency Bin');
xlabel(t,'Region');
title(t, 'Average Bipolar Frequency Power by Brain Region')

% 6. plot heatmap : x-region, y-frequency bin, color -avg power

nexttile
deltaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'Delta'), :);
h= heatmap(deltaData,'RegionSingle','FreqBin','ColorVariable','Value');
% 8. adjust heatmap details 
h.YLabel='';
h.XLabel='';
h.Title='';
cdl = h.XDisplayLabels;                                    % Current Display Labels
h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));   % Blank Display Labels

% 7. order appropriately
nexttile
thetaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'Theta'), :);
h= heatmap(thetaData,'RegionSingle','FreqBin','ColorVariable','Value');
h.YLabel='';
h.XLabel='';
h.Title='';
h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));

nexttile
alphaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'Alpha'), :);
h= heatmap(alphaData,'RegionSingle','FreqBin','ColorVariable','Value');
h.YLabel='';
h.XLabel='';
h.Title='';
h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));

nexttile
betaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'Beta'), :);
h= heatmap(betaData,'RegionSingle','FreqBin','ColorVariable','Value');
h.YLabel='';
h.XLabel='';
h.Title='';
h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));

nexttile
lgammaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'L Gamma'), :);
h= heatmap(lgammaData,'RegionSingle','FreqBin','ColorVariable','Value');
h.YLabel='';
h.XLabel='';
h.Title='';
h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));

nexttile
hgammaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'H Gamma'), :);
h= heatmap(hgammaData,'RegionSingle','FreqBin','ColorVariable','Value');
h.YLabel='';
h.XLabel='';
h.Title='';


%%
% 9. save somwhere?
 intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';
    outputFolder = fullfile(intan_choicetask_parent, 'regional power');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    saveFileName = fullfile(outputFolder, 'SplitRegionPowerHeatmap.pdf');
    set(gcf, 'WindowState', 'maximized');         
    exportgraphics(gcf,saveFileName)

% should be able to look at the session name to see how many rats and sessions are in
% each cell

%% how many rats contribute to each region?

% Group by Region and count unique Rat IDs
uniqueRatsPerRegion = varfun(@(x) numel(unique(x)), modifiedTable, 'GroupingVariables', 'RegionSingle');
uniqueRatsPerRegion.Properties.VariableNames{3} = 'NumSessions';  % Rename the count column
uniqueRatsPerRegion.Properties.VariableNames{7} = 'NumRats';  % Rename the count column
RatsNSessionsPerRegion = uniqueRatsPerRegion(:,[1,3,7]);
% Display the number of unique rats per region
disp(RatsNSessionsPerRegion);

% sort regions based on number of sessions included for that region
sorted = sortrows(RatsNSessionsPerRegion,'NumSessions','descend');
disp(sorted);

