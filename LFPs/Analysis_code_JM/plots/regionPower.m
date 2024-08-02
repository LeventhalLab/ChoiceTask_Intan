% ZHH
% regional power analysis
% pt 1 - make table 
% pt 2 - make heatmap

%{
quick information:
Aggregates data across all rats
Creates a heatmap of LFP power by region and frequency bin
(also reports how many rats contributed to each region)

location:
X:\Neuro-Leventhal\data\ChoiceTask\GitHub\ChoiceTask_Intan\LFPs\Analysis_code_JM\plots
functions called:
getChannelRegionLabel

files used:
heatmapTable.mat
(ProbeSite_Mapping_MATLAB_RL.xlsx indirectly through getChannelRegionLabel)

Outputs (table and heatmap pdf) save to:
output_folder =  fullfile(intan_choicetask_parent, 'regional power');
Where intan choice task parent is
intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';

notes:
takes a million years to run if you run from the beginning
start from the section titled 
%% optional: start from load regionPowerTable to avoid remaking each time
to just load the table I have saved 
currently stops at rat 466 bc the excel file has not been updated past
there
table and heat map save to folder called: 
regional power 
all LFPs that occur over a regional border are currently being saved to the “multiregion” column
can increase the heatmap font size if necessary later
last updated 7/17/24.
%}


%{
THE FIRST SECTION OF THIS SCRIPT IS BLOCK COMMENTED TO PREVENT REMAKING THE
TABLE EVERY TIME. UNCOMMENT IF YOU WANT TO REMAKE THE REGION POWER TABLE.
IT WILL TAKE ABOUT 10 HOURS (JUST AS A HEADS UP)

% initialize bigheatmap table
bigHeatmapTable = table();
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
        heatmapTable.ShankNum=string(heatmapTable.ShankNum);
        heatmapTable.RowNum=string(heatmapTable.RowNum);
        %4. exclude bad rows
        % Filter out rows where GoodBad is not 'good'
        heatmapTable = heatmapTable(strcmp(heatmapTable.GoodBad, 'good'), :);
        %go ahead and delete the goodbad column
        heatmapTable = removevars(heatmapTable,"GoodBad");
        disp('Table loaded successfully.');
    else
        error(['File not found: ' filePath]);
    end

%3. concatenate them to make one big table 
% make sure to append, not replace
bigHeatmapTable=[bigHeatmapTable;heatmapTable];

end % rat loop 

%% create regionPowerTables

% initialize regionPowerTable for heatmaps
regionPowerTable = table();
regionPowerTable.Value = zeros(0);

%% create region power tables cont.
% preallocate number of rows based on bigHeatmapTable
numberofRows = height(bigHeatmapTable);  % Get the number of rows in bigHeatmapTable
regionPowerTable = table('Size',[numberofRows, 3], 'VariableTypes', {'string', 'string', 'double'}, ...
                         'VariableNames', {'Session', 'FreqBin', 'Value'});
%2. grab the freqbin, session, and value column from heatmap -> regionpower
regionPowerTable.Session = bigHeatmapTable.Session;
regionPowerTable.FreqBin = bigHeatmapTable.FreqBin;
regionPowerTable.Value = bigHeatmapTable.Value;


%5. use channel column to get regions (see method used in brainregionmap)

for row=1:numberofRows
    message = sprintf('row %d/%d', row, numberofRows);
    disp(message);
    % for each row in the bigHeatmapTable, 
    channelCell=cell2mat(bigHeatmapTable.Channel(row));
    %Channel cell is in form 'in:XXX-XXX(1)'
    dash_idx=strfind(channelCell,'-');
    par_idx=strfind(channelCell,'(');
    site_num_top=channelCell(4:dash_idx-1);
    site_num_bot=channelCell(dash_idx+1:par_idx-1);
    %pull the correct ratID
    sessionName=cell2mat(bigHeatmapTable.Session(row));
    ratID=sessionName(1:5);
    % region excel is only updated up to 493 so we must stop before then
    if strcmp(ratID,'R0493')
        break;
    end
    [region_top,color_top] = getChannelRegionLabel(ratID, site_num_top);
    [region_bot,color_bot] = getChannelRegionLabel(ratID, site_num_bot);
     % if both channels are in the same region, save the region
    if color_top == color_bot
       region = region_top;
    else % otherwise the bipolar calculation occurs over a border
       region = "multiregion";
    end
    regionPowerTable.Region(row)=region;
end % end row loop

%delete the big heatmaps table to clear some space before making the heatmaps 
bigHeatmapTable = [];

%% save regionPowerTable
 intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';
    outputFolder = fullfile(intan_choicetask_parent, 'regional power');
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    saveFileName = fullfile(outputFolder, 'regionPowerTable.mat');
    save(saveFileName, 'regionPowerTable');

%}

%% optional start from load regionPowerTable to avoid remaking each time

 % Construct the full path to the .mat file
    filePath = fullfile('X:\Neuro-Leventhal\data\ChoiceTask\regional power', 'regionPowerTable.mat');

    % Load the table from the .mat file
    if exist(filePath, 'file')
        regionPowerTable = load(filePath);  % Load the file
        regionPowerTable = regionPowerTable.regionPowerTable;  % Access the table variable inside the .mat file
    end

%%
figure;
t= tiledlayout("vertical");
t.TileSpacing = 'tight';
t.Padding = 'none';
ylabel(t,'Frequency Bin');
xlabel(t,'Region');
title(t, 'Average Bipolar Frequency Power by Brain Region')

% 6. plot heatmap : x-region, y-frequency bin, color -avg power

nexttile
deltaData = regionPowerTable(strcmp(regionPowerTable.FreqBin, 'Delta'), :);
h= heatmap(deltaData,'Region','FreqBin','ColorVariable','Value');
% 8. adjust heatmap details 
h.YLabel='';
h.XLabel='';
h.Title='';
% 7. order appropriately
nexttile
thetaData = regionPowerTable(strcmp(regionPowerTable.FreqBin, 'Theta'), :);
h= heatmap(thetaData,'Region','FreqBin','ColorVariable','Value');
h.YLabel='';
h.XLabel='';
h.Title='';
nexttile
alphaData = regionPowerTable(strcmp(regionPowerTable.FreqBin, 'Alpha'), :);
h= heatmap(alphaData,'Region','FreqBin','ColorVariable','Value');
h.YLabel='';
h.XLabel='';
h.Title='';
nexttile
betaData = regionPowerTable(strcmp(regionPowerTable.FreqBin, 'Beta'), :);
h= heatmap(betaData,'Region','FreqBin','ColorVariable','Value');
h.YLabel='';
h.XLabel='';
h.Title='';
nexttile
lgammaData = regionPowerTable(strcmp(regionPowerTable.FreqBin, 'L Gamma'), :);
h= heatmap(lgammaData,'Region','FreqBin','ColorVariable','Value');
h.YLabel='';
h.XLabel='';
h.Title='';
nexttile
hgammaData = regionPowerTable(strcmp(regionPowerTable.FreqBin, 'H Gamma'), :);
h= heatmap(hgammaData,'Region','FreqBin','ColorVariable','Value');
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
    saveFileName = fullfile(outputFolder, 'regionPowerHeatmap.pdf');
    set(gcf, 'WindowState', 'maximized');         
    exportgraphics(gcf,saveFileName)

% should be able to look at the session name to see how many rats and sessions are in
% each cell

%% how many rats contribute to each region?
% Extract rat IDs from Session column
SessionMat=cell2mat(regionPowerTable.Session(:,1));
NameMat=SessionMat(:,1:5);
regionPowerTable.RatID = cellstr(NameMat);

% Group by Region and count unique Rat IDs
uniqueRatsPerRegion = varfun(@(x) numel(unique(x)), regionPowerTable, 'GroupingVariables', 'Region');
uniqueRatsPerRegion.Properties.VariableNames{6} = 'NumRats';  % Rename the count column

% Display the number of unique rats per region
disp(uniqueRatsPerRegion(:,[1,6]));
