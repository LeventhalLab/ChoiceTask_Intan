% 3D coordinate plot
% ZHH 7/17/24

% makes a 3D plot of LFP coordinates (uses midpoint btwn the 2 subtracted
% channels) and color codes them based on ratID

%first section makes big table
%second section uses that table to make the 3D scatterplot

%uses the heatmapTables for each rat

% combine heatmap tables for each rat --> one big table with heatmap data
% excludes bad channels 


%{
COMMENTING OUT THE PART THAT BUILDS THE BIG TABLE
it takes a long time so only uncomment if you want to change the bigtable


% initialize bigheatmap table
bigTable = table();
%1. load heatmap tables for each rat
% Define rat IDs
ratID_list = {'R0326', 'R0327', 'R0372', 'R0376', 'R0378', 'R0379', 'R0394', 'R0395', ...
    'R0396', 'R0412', 'R0413', 'R0419', 'R0420', 'R0425', 'R0427', 'R0456', ...
    'R0460', 'R0463', 'R0465', 'R0466', 'R0467', 'R0479', 'R0492', 'R0493', 'R0494', 'R0495'};

% theres currently 26 rats in the ratID list
% to go through all rats do 1:length(ratID_list)
% for a particular rat or set of rats adjust accordingly
for rat = 1:26
    ratID = ratID_list{rat};
    fprintf('rat ID: %s\n', ratID);
 
    % Construct the full path to the .mat file
    filePath = fullfile('X:\Neuro-Leventhal\data\ChoiceTask\heatmap tables', ratID, ['heatmapTable_' ratID '.mat']);

    % Load the table from the .mat file
    if exist(filePath, 'file')
        heatmapTable = load(filePath);  % Load the file
        heatmapTable = heatmapTable.heatmapTable;  % Access the table variable inside the .mat file
        %exclude bad rows
        % Filter out rows where GoodBad is not 'good'
        heatmapTable = heatmapTable(strcmp(heatmapTable.GoodBad, 'good'), :);
        %delete the unnecessary columns (goodbad, shanknum, and rownum)
        heatmapTable = removevars(heatmapTable,"GoodBad");
        heatmapTable = removevars(heatmapTable,"ShankNum");
        heatmapTable = removevars(heatmapTable,"RowNum");
        disp('Table loaded successfully.');
    else
        error(['File not found: ' filePath]);
    end

%3. concatenate them to make one big table 
% make sure to append, not replace
bigTable=[bigTable;heatmapTable];

end % rat loop 

%%
% Extract rat IDs from Session column
SessionMat=cell2mat(bigTable.Session(:,1));
NameMat=SessionMat(:,1:5);
bigTable.RatID = cellstr(NameMat);
%% Channel --> intanTop and intanBot --> T and B coordinates
numberofRows = height(bigTable);

for row=1:numberofRows
    % extract intan numbers from the channel column
    channelCell=cell2mat(bigTable.Channel(row));
    %Channel cell is in form 'in:XXX-XXX(1)'
    dash_idx=strfind(channelCell,'-');
    par_idx=strfind(channelCell,'(');
    site_num_top=str2double(channelCell(4:dash_idx-1));
    site_num_bot=str2double(channelCell(dash_idx+1:par_idx-1));
    %convert back to 0 scale
    inTop0=site_num_top-1;
    inBot0=site_num_bot-1;
    % save to new columns intanTop and intanBot
    bigTable.intanTop(row) = inTop0;
    bigTable.intanBot(row) = inBot0;

    message = sprintf('row %d/%d', row, numberofRows);
    disp(message);

% Pull coordinates from the excel file (this part will probably be very slow)
% we need the excel file
ExcelFileName =   'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\ProbeSite_Mapping_MATLAB_RL.xlsx';  

% Get all sheet names from the Excel file
sheets = sheetnames(ExcelFileName);    
% define the ratID
    ratID=bigTable.RatID(row);
    %skip rats with bad histo (dont have regions or locations saved), end
    %at 466 bc no regions saved after that point
    if strcmp(ratID, 'R0376') || strcmp(ratID, 'R0374') || strcmp(ratID, 'R0396') || strcmp(ratID, 'R0413')
        continue;
    elseif strcmp(ratID,'R0466')
        break;
    end

    % Find the sheet that starts with ratID_
    matchedSheet = "";
    for i = 1:length(sheets)
        if startsWith(sheets{i}, [ratID '_'])
            matchedSheet = sheets{i};
            break;
        end
    end

    if isempty(matchedSheet)
        error('No sheet found matching the pattern %s_', ratID);
    end
    % Read the Excel file into a table
    excelTable = readtable(ExcelFileName, 'Sheet', matchedSheet);

    % Find the column name that ends with the specified suffix
    InSiteNumberColumn = "";
    columns = excelTable.Properties.VariableNames;
    columnSuffix = 'Site_Number';
    for i = 1:length(columns)
        if endsWith(columns{i}, ['_' columnSuffix])
            InSiteNumberColumn = columns{i};
            break;
        end
    end

    if isempty(InSiteNumberColumn)
        error('No column found ending with %s', ['_' columnSuffix]);
    end
     
    % example code from getChannelRegionLabel:
    % Find the row index where SiteNumber matches top intan site number
    rowIndexTop = find(excelTable.(InSiteNumberColumn) == inTop0, 1);
    %same for bottom
    rowIndexBot = find(excelTable.(InSiteNumberColumn) == inBot0, 1);
    %error message, can probably delete later
    if isempty(rowIndexTop)
        error('Site number %d not found in the Excel sheet.', inTop0);
    end
    if isempty(rowIndexBot)
        error('Site number %d not found in the Excel sheet.', inBot0);
    end

    % Retrieve the top channel region label from the 'Region' column
    if iscell(excelTable.Region)
        RegionTop = excelTable.Region{rowIndexTop};
    else
        RegionTop = excelTable.Region(rowIndexTop);
    end
        % Retrieve the bottom channel region label from the 'Region' column
    if iscell(excelTable.Region)
        RegionBot = excelTable.Region{rowIndexBot};
    else
        RegionBot = excelTable.Region(rowIndexBot);
    end
    %save to columns
    bigTable.RegionTop{row}=RegionTop;
    bigTable.RegionBot{row}=RegionBot;

        %retrieve the coordinates
    % Retrieve the top coordinates from the appropriate columns
    if iscell(excelTable.AP)
        AP_T = excelTable.AP{rowIndexTop};
    else
        AP_T = excelTable.AP(rowIndexTop);
    end
    bigTable.AP_T(row)=AP_T;
    if iscell(excelTable.ML)
        ML_T = excelTable.ML{rowIndexTop};
    else
        ML_T = excelTable.ML(rowIndexTop);
    end
    bigTable.ML_T(row)=ML_T;
    if iscell(excelTable.DV)
        DV_T = excelTable.DV{rowIndexTop};
    else
        DV_T = excelTable.DV(rowIndexTop);
    end
    bigTable.DV_T(row)=DV_T;
        % Retrieve the bottom coordinates from the appropriate columns
    if iscell(excelTable.AP)
        AP_B = excelTable.AP{rowIndexBot};
    else
        AP_B = excelTable.AP(rowIndexBot);
    end
    bigTable.AP_B(row)=AP_B;
    if iscell(excelTable.ML)
        ML_B = excelTable.ML{rowIndexBot};
    else
        ML_B = excelTable.ML(rowIndexBot);
    end
    bigTable.ML_B(row)=ML_B;
    if iscell(excelTable.DV)
        DV_B = excelTable.DV{rowIndexBot};
    else
        DV_B = excelTable.DV(rowIndexBot);
    end
    bigTable.DV_B(row)=DV_B;

end % end row loop

%% Calculate the midpoints

AP_M=(bigTable.AP_T+bigTable.AP_B)/2;
ML_M=(bigTable.ML_T+bigTable.ML_B)/2;
DV_M=(bigTable.DV_T+bigTable.DV_B)/2;

%save in columns of the table
bigTable.AP_M=AP_M;
bigTable.ML_M=ML_M;
bigTable.DV_M=DV_M;

%% save bigTable
 intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';
    outputFolder = fullfile(intan_choicetask_parent, 'voxel power');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    saveFileName = fullfile(outputFolder, 'bigTable.mat');
    save(saveFileName, 'bigTable');
%}

%% optional starting point: load bigTable


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

%i want to exclude the rats that dont have coordinate data (bad histo)
% Define rat IDs to exclude
% also throwing in 425 bc its the only one with a negative AP coordinate,
% its all alone
excludeRatIDs = {'R0376', 'R0374', 'R0396', 'R0413'};
% Find rows with ratIDs to exclude
rowsToExclude = ismember(bigTable.RatID, excludeRatIDs);
% Exclude rows from bigTable
filteredTable = bigTable(~rowsToExclude, :);

%% make 3D plot of midpoint coordinates (color coded by ratID)

% Get unique RatIDs and assign a color to each one
uniqueRatIDs = unique(filteredTable.RatID);
numRatIDs = numel(uniqueRatIDs);

% Define a colormap with enough colors for all unique RatIDs
colorMap = hsv(numRatIDs);  % Example colormap (you can use any colormap)

% Create figure for the scatter plot
figure;

% Loop through each unique RatID
hold on;
for i = 1:numRatIDs
    % Filter data for the current RatID
    currentRatID = uniqueRatIDs{i};
    idx = strcmp(filteredTable.RatID, currentRatID);
    
    % Scatter plot for current RatID with unique color from colormap
    scatter3(filteredTable.AP_M(idx), filteredTable.ML_M(idx), filteredTable.DV_M(idx), 36, colorMap(i,:), 'filled');
end


% Customize plot properties
xlabel('AP (mm)','FontSize',18);
ylabel('ML (mm)','FontSize',18);
zlabel('DV (mm)','FontSize',18);
title('3D Scatter Plot of Midpoint Coordinates','FontSize',20);
legend(uniqueRatIDs, 'Location', 'eastoutside','FontSize',16);  % Legend with RatID labels
grid on;


%{
%try to add labels with the region?? - just showing the top region for
%simplicity - not ideal tbh
%text(filteredTable.AP_M,filteredTable.ML_M,filteredTable.DV_M,filteredTable.RegionTop)  %<---- play with this 
% Add labels based on unique coordinates
uniqueCoords = unique([filteredTable.AP_M, filteredTable.ML_M, filteredTable.DV_M], 'rows');
for j = 1:size(uniqueCoords, 1)
    coord = uniqueCoords(j, :);
    % Find the corresponding regions at this coordinate
    idx = filteredTable.AP_M == coord(1) & filteredTable.ML_M == coord(2) & filteredTable.DV_M == coord(3);
    regionLabel = filteredTable.RegionTop(idx);
    
    % Plot text label only once for each unique coordinate
    text(filteredTable.AP_M(idx), filteredTable.ML_M(idx), filteredTable.DV_M(idx), regionLabel, 'FontSize', 10, 'FontWeight', 'bold');
end
%}

% Adjust axes limits to fit data range
minAP=min(filteredTable.AP_M);
maxAP=max(filteredTable.AP_M);
minML=min(filteredTable.ML_M);
maxML= max(filteredTable.ML_M);
minDV= min(filteredTable.DV_M);
maxDV=max(filteredTable.DV_M);
xlim([minAP,maxAP]);
ylim([minML,maxML]);
zlim([minDV, maxDV]);

set(gcf, 'WindowState', 'maximized');         
hold off;

savefig('X:\Neuro-Leventhal\data\ChoiceTask\voxel power\coordinatePlot3D.fig')

%}





