% to show variance between sessions
% sessionScatter
% ZHH 7/09/24

%helps us to see how each session contributes to the heat maps created by
%makeHeatmaps

%{ 
Quick info
location:
X:\Neuro-Leventhal\data\ChoiceTask\GitHub\ChoiceTask_Intan\LFPs\Analysis_code_JM\plots
functions called:none
files used:
heat map tables created by heatmapTableMaker
filePath = fullfile('X:\Neuro-Leventhal\data\ChoiceTask\heatmap tables', ratID, ['heatmapTable_' ratID '.mat']);
Outputs save to:
     intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask\heatmaps';
    outputFolder = fullfile(intan_choicetask_parent, 'sessionScatters', ratID);

last updated 7/10/24.

reminders:
update ratID list as new rats are added
%}

% Define rat IDs
ratID_list = {'R0326', 'R0327', 'R0372', 'R0376', 'R0378', 'R0379', 'R0394', 'R0395', ...
    'R0396', 'R0412', 'R0413', 'R0419', 'R0420', 'R0425', 'R0427', 'R0456', ...
    'R0460', 'R0463', 'R0465', 'R0466', 'R0467', 'R0479', 'R0492', 'R0493', 'R0494', 'R0495'};


% theres currently 26 rats in the ratID list
% to go through all rats do rat=1:length(ratID_list)
% for a particular rat or set of rats adjust accordingly
for rat = 1:length(ratID_list)
    ratID = ratID_list{rat};
    fprintf('Processing rat ID: %s\n', ratID);
 
% Construct the full path to the .mat file
filePath = fullfile('X:\Neuro-Leventhal\data\ChoiceTask\heatmap tables', ratID, ['heatmapTable_' ratID '.mat']);

% Load the table from the .mat file
if exist(filePath, 'file')
    heatmapTable = load(filePath);  % Load the file
    heatmapTable = heatmapTable.heatmapTable;  % Access the table variable inside the .mat file
    heatmapTable.ShankNum=string(heatmapTable.ShankNum);
    heatmapTable.RowNum=string(heatmapTable.RowNum);
    % Filter out rows where GoodBad is not 'good'
    heatmapTable = heatmapTable(strcmp(heatmapTable.GoodBad, 'good'), :);
    disp('Table loaded successfully.');
else
    error(['File not found: ' filePath]);
end

%i want to see if i can do a 2,3 layout for NN rats instead of a 1,6 so
%that the style is the same as the heatmaps and the width fits better
if rat>=12
    %outer layout
    outer = tiledlayout(1,6);
else
    outer = tiledlayout(2,3);
end

outer.TileSpacing = 'compact';
outer.Padding = 'none';
outer.Title.String=sprintf('%s session scatters',ratID);

for bin=1:6
    fprintf('bin %d\n',bin);
    ot=nexttile(outer);
    ot.XColor = [1 1 1];
    ot.YColor = [1 1 1];
    xlabel(ot, 'shank');

   %each outer tile is for 1 frequency bin
% binData is a smaller table that contains only rows for that specific
% frequency bin
switch bin
    case 1
        binData = heatmapTable(strcmp(heatmapTable.FreqBin, 'Delta'), :);
        ot.Title.String='Delta 1-4Hz';
    case 2
        binData = heatmapTable(strcmp(heatmapTable.FreqBin, 'Theta'), :);
        ot.Title.String='Theta 4-8Hz';
    case 3
        ot.Title.String='Alpha 8-13Hz';
        binData = heatmapTable(strcmp(heatmapTable.FreqBin, 'Alpha'), :);
    case 4
        ot.Title.String='Beta 13-30Hz';
        binData = heatmapTable(strcmp(heatmapTable.FreqBin, 'Beta'), :);
    case 5
        ot.Title.String='Low Gamma 30-70Hz';
        binData = heatmapTable(strcmp(heatmapTable.FreqBin, 'L Gamma'), :);
    case 6
        ot.Title.String='High Gamma 70-200Hz';
        binData = heatmapTable(strcmp(heatmapTable.FreqBin, 'H Gamma'), :);
end

% inner grid depends on probe type
if rat <=11
%for rats 1-11
    inner = tiledlayout(outer,7,8);
    cellsPerMap = 56;
else
%for rats 12-26
    inner = tiledlayout(outer,15,4);
    cellsPerMap=60;
end

inner.Layout.Tile = bin;
inner.TileSpacing = 'tight';
inner.Padding = 'none';

for cell=1:cellsPerMap
    fprintf('cell %d\n',cell);
    it=nexttile(inner);
    it.XColor = [1 1 1];
    it.YColor = [1 1 1];
    % each inner tile should contain a scatterplot of session vs value for
    % that shank num and row num
    % first harvest only the relevant rows (both shank num and row num must
    % match)
    if rat <=11 %NN rats
        rowNumber=ceil(cell/8);
        shankNumber = cell-(8*(rowNumber-1));
    else % other rats
        rowNumber=ceil(cell/4);
        shankNumber = cell-(4*(rowNumber-1));
    end    

    % convert numbers to strings to compare with cells
    rowstr=sprintf('%d',rowNumber);
    rowData = binData(strcmp(binData.RowNum, rowstr), :);
    shankstr=sprintf('%d',shankNumber);
    cellData = rowData(strcmp(rowData.ShankNum,shankstr), :);
   
    % Check if cellData is empty
    if isempty(cellData)
        continue;  % Exit the loop if cellData is empty
    end
   
   % Get number of rows in cellData
numRows = size(cellData, 1);

% Plot scatterplot of row indices vs Value
s=scatter(1:numRows, cellData.Value);

s.SizeData = 12;  % Adjust the size as needed
% Get current axis handle
ax = gca;

% Y lims should be consistent within each frequency bin
Ymax = max(binData.Value);
Ymin = min(binData.Value);
% X lims should be number of sessions
numSessions = numel(unique(binData.Session));
Xmin = 1;
Xmax = numSessions;

ax.XLim = [Xmin, Xmax];
ax.YLim = [Ymin, Ymax];

if bin==1 || bin==3 || bin==5
% Change axis colors
ax.XColor = [0 0 0];  
ax.YColor = [0 0 0]; 
else
    % Change axis colors
ax.XColor = [0.2 0.2 0.2]; 
ax.YColor = [0.2 0.2 0.2]; 
end
 % Draw a box around the scatter plot
           
end % cell loop

end % frequency bin loop

    % Save results table for this rat
    intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask\heatmaps';
    outputFolder = fullfile(intan_choicetask_parent, 'sessionScatters', ratID);
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    saveFileName = fullfile(outputFolder, sprintf('sessionScatters_%s.pdf', ratID));
    set(gcf, 'WindowState', 'maximize'); % maximizes the window so that it exports the graphics with appropriate font size        
    exportgraphics(gcf,saveFileName)
    %use to stop at a particular rat (NN rats end at 11)
    %{
    if rat==2
        break;
    end
    %}
end % rat loop 
