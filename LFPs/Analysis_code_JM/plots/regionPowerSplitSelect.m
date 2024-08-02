% regionPowerSplitSelect
% ZHH 7/24/24

% same as region power split but i only want to include regions over a
% certain threshold for number of sessions and number of rats included
%also each frequency band gets a distinct color

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

% I only want to unclude particular regions based on my personal thresholds
% currently only want regions with at least 18 sessions across at least 2
% rats (VM has 79 sessions across 8 rats)
includeRegions = {'VM','ZI','VL','VM/VL','ZI/VM','VPL','VPM','ZID','LH','PC','SubI','PF','VA','VA/VL'};
rowsToInclude = ismember(modifiedTable.RegionSingle,includeRegions);
modifiedTable = modifiedTable(rowsToInclude,:);

%%
figure;
t= tiledlayout("vertical");
t.TileSpacing = 'none';
t.Padding = 'none';
ylabel(t,'Frequency Bin','FontSize',22);
xlabel(t,'Subregion','FontSize',22);
title(t, 'Average Bipolar Frequency Power by Brain Region','FontSize',32)

%custom colors
% Define hex colors and convert them to RGB
hexColors = [
    '#FF3AC7'; % Color 4 pink
    '#B30606'; % Color 5 red
    '#E4760B'  % Color 6 orange
    '#036B61'; % Color 1 teal
    '#072794'; % Color 2 blue
    '#893AF5'; % Color 3 purple
];

% Convert hex colors to RGB
numColors = size(hexColors, 1); % Get the number of colors
colorsRGB = zeros(numColors, 3);
for i = 1:numColors
    hex = hexColors(i, :); % Get hex color code (as a row)
    rgb = sscanf(hex(2:end), '%2x')'/255; % Convert hex to RGB
    colorsRGB(i, :) = rgb; % Store RGB values
end

% 6. plot heatmap : x-region, y-frequency bin, color -avg power

nexttile
deltaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'Delta'), :);
h= heatmap(deltaData,'RegionSingle','FreqBin','ColorVariable','Value');
cmap = [linspace(1,colorsRGB(1,1),256)', linspace(1,colorsRGB(1,2),256)', linspace(1,colorsRGB(1,3),256)'];
    % Apply the custom color map
    colormap(h,cmap);
h.XDisplayData = {'LH','VA','VA/VL','VL','VM/VL','VM','ZI/VM','ZI','ZID','VPL','VPM','PC','PF','SubI'};
% 8. adjust heatmap details 
h.FontSize = 20;
h.YLabel='';
h.XLabel='';
h.Title='';
cdl = h.XDisplayLabels;                                    % Current Display Labels
h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));   % Blank Display Labels

% 7. order appropriately
nexttile
thetaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'Theta'), :);
h= heatmap(thetaData,'RegionSingle','FreqBin','ColorVariable','Value');
cmap = [linspace(1,colorsRGB(2,1),256)', linspace(1,colorsRGB(2,2),256)', linspace(1,colorsRGB(2,3),256)'];
    % Apply the custom color map
 colormap(h,cmap);
h.XDisplayData = {'LH','VA','VA/VL','VL','VM/VL','VM','ZI/VM','ZI','ZID','VPL','VPM','PC','PF','SubI'};
h.FontSize = 20;
h.YLabel='';
h.XLabel='';
h.Title='';
h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));

nexttile
alphaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'Alpha'), :);
h= heatmap(alphaData,'RegionSingle','FreqBin','ColorVariable','Value');
cmap = [linspace(1,colorsRGB(3,1),256)', linspace(1,colorsRGB(3,2),256)', linspace(1,colorsRGB(3,3),256)'];
 colormap(h,cmap);
h.XDisplayData = {'LH','VA','VA/VL','VL','VM/VL','VM','ZI/VM','ZI','ZID','VPL','VPM','PC','PF','SubI'};
h.FontSize = 19;
h.YLabel='';
h.XLabel='';
h.Title='';
h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));

nexttile
betaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'Beta'), :);
h= heatmap(betaData,'RegionSingle','FreqBin','ColorVariable','Value');
cmap = [linspace(1,colorsRGB(4,1),256)', linspace(1,colorsRGB(4,2),256)', linspace(1,colorsRGB(4,3),256)'];
 colormap(h,cmap);
h.XDisplayData = {'LH','VA','VA/VL','VL','VM/VL','VM','ZI/VM','ZI','ZID','VPL','VPM','PC','PF','SubI'};
h.FontSize = 20;
h.YLabel='';
h.XLabel='';
h.Title='';
h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));

nexttile
lgammaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'L Gamma'), :);
h= heatmap(lgammaData,'RegionSingle','FreqBin','ColorVariable','Value');
cmap = [linspace(1,colorsRGB(5,1),256)', linspace(1,colorsRGB(5,2),256)', linspace(1,colorsRGB(5,3),256)'];
colormap(h,cmap);
h.XDisplayData = {'LH','VA','VA/VL','VL','VM/VL','VM','ZI/VM','ZI','ZID','VPL','VPM','PC','PF','SubI'};
h.FontSize = 20;
h.YLabel='';
h.XLabel='';
h.Title='';
h.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));

nexttile
hgammaData = modifiedTable(strcmp(modifiedTable.FreqBin, 'H Gamma'), :);
h= heatmap(hgammaData,'RegionSingle','FreqBin','ColorVariable','Value');
cmap = [linspace(1,colorsRGB(6,1),256)', linspace(1,colorsRGB(6,2),256)', linspace(1,colorsRGB(6,3),256)'];
 colormap(h,cmap);
h.XDisplayData = {'LH','VA','VA/VL','VL','VM/VL','VM','ZI/VM','ZI','ZID','VPL','VPM','PC','PF','SubI'};
h.FontSize = 21;
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
    saveFileName = fullfile(outputFolder, 'SplitRegionPowerHeatmapSELECT.pdf');
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

