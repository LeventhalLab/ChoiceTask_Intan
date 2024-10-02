% brain region site map
% ZHH 7/10/24

% create a custom color coded map for each rat displaying the channels
% involved in the bipolar LFPs and the region that each of those channels
% resides in 

%{ 
Quick info
location:
X:\Neuro-Leventhal\data\ChoiceTask\GitHub\ChoiceTask_Intan\LFPs\Analysis_code_JM\plots
functions called: getChannelRegionLabel

files used:
heat map tables created by heatmapTableMaker
(indirectly uses ProbeSite_Mapping_MATLAB_RL.xlsx through the
getchannelregionlabel function)

filePath = fullfile('X:\Neuro-Leventhal\data\ChoiceTask\heatmap tables', ratID, ['heatmapTable_' ratID '.mat']);
Outputs save to:
    intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';
    outputFolder = fullfile(intan_choicetask_parent, 'BrainRegionSiteMaps', ratID);

last updated 7/10/24.

reminders:
update ratID list as new rats are added

note: fails at 493 bc 493 hasnt yet been added to the excel sheet for
region mapping
%}


% Define rat IDs
ratID_list = {'R0326', 'R0327', 'R0372', 'R0376', 'R0378', 'R0379', 'R0394', 'R0395', ...
    'R0396', 'R0412', 'R0413', 'R0419', 'R0420', 'R0425', 'R0427', 'R0456', ...
    'R0460', 'R0463', 'R0465', 'R0466', 'R0467', 'R0479', 'R0492', 'R0493', 'R0494', 'R0495'};


% theres currently 26 rats in the ratID list
% to go through all rats do 1:length(ratID_list)
% for a particular rat or set of rats adjust accordingly
for rat = 1:26
    ratID = ratID_list{rat};
    
    fprintf('mapping rat ID: %s\n', ratID);

    % Construct the full path to the .mat file
filePath = fullfile('X:\Neuro-Leventhal\data\ChoiceTask\heatmap tables', ratID, ['heatmapTable_' ratID '.mat']);

% Load the table from the .mat file
if exist(filePath, 'file')
    heatmapTable = load(filePath);  % Load the file
    heatmapTable = heatmapTable.heatmapTable;  % Access the table variable inside the .mat file
    heatmapTable.ShankNum=string(heatmapTable.ShankNum);
    heatmapTable.RowNum=string(heatmapTable.RowNum);
    disp('Table loaded successfully.');
else
    error(['File not found: ' filePath]);
end

%shape of tiled layout depends on probe type
% inner grid depends on probe type
if rat <=11
%for rats 1-11
    figure('Position', [1, 420, 500,588])
    tiles = tiledlayout(7,8);
    numtiles = 56;
    tiles.TileSpacing='tight';
    tiles.Padding='compact';
else
%for rats 12-26
    figure('Position', [1, 50, 350,900])
    tiles = tiledlayout(15,4);
    numtiles=60;
    tiles.TileSpacing='tight';
    tiles.Padding='tight';
end 

titleStr=sprintf('%s Intan(1) to Region Map',ratID);
tiles.Title.String=titleStr;
tiles.Title.FontSize=20;
tiles.XLabel.String='Shank';
tiles.YLabel.String='Channels';
tiles.XLabel.FontSize=16;
tiles.YLabel.FontSize=16;

%%

% only pull the rows from the table that are relevant to this tile
for t=1:numtiles
%make sure we are looking at the right row of the table
if rat <=11 %NN rats
    rowNumber=ceil(t/8);
    shankNumber = t-(8*(rowNumber-1));
else 
    rowNumber=ceil(t/4);
    shankNumber = t-(4*(rowNumber-1));
end
rowstr=sprintf('%d',rowNumber);
rowData = heatmapTable(strcmp(heatmapTable.RowNum, rowstr), :);
shankstr=sprintf('%d',shankNumber);
tileData = rowData(strcmp(rowData.ShankNum,shankstr), :);
 % Check if cellData is empty
 if isempty(tileData)
        continue;  % Exit the loop if cellData is empty
 end
   

% every entry for tileData.Channel should be the same
% so we can just use the first one to get the top and bottom site nums
channelCell=cell2mat(tileData.Channel(1));
%Channel cell is in form 'in:XXX-XXX(1)'
dash_idx=strfind(channelCell,'-');
par_idx=strfind(channelCell,'(');
site_num_top=channelCell(4:dash_idx-1);
site_num_bot=channelCell(dash_idx+1:par_idx-1);
ChannelNums=channelCell(4:par_idx-1);



%%



[region_top,color_top] = getChannelRegionLabel(ratID, site_num_top);
[region_bot,color_bot] = getChannelRegionLabel(ratID, site_num_bot);
 % if both channels are in the same region, save the color
if color_top == color_bot
   color = color_top;
   % otherwise the bipolar calculation occurs over a border : set color to black "k"
else
   color = "k";
end

nexttile;
disp(t);
hold on;
box on;   % Add a box around the axes (not around the tile itself)
set(gca, 'LineWidth', 1, 'XColor', color, 'YColor', color); 
%i want the region labels for the NN rat sto be stacked verticaly in order
%to fit better in the tiles (also thats how the OG channels are anyway)
if rat>=12 %nonNN rats
    text(0.1,0.5, sprintf('%s \n%s-%s',ChannelNums,region_top,region_bot),'Color',color,'FontSize',12)
else
  text(0.1,0.5, sprintf('%s\n%s\n%s',ChannelNums,region_top,region_bot),'Color',color,'FontSize',12)
end  
%Ax = gca;
%Ax.Visible = 0;
% Hide axes ticks and labels
set(gca, 'XTick', [], 'YTick', [], 'XTickLabel', {}, 'YTickLabel', {});



end % tile loop

 % Save results table for this rat
    intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';
    outputFolder = fullfile(intan_choicetask_parent, 'BrainRegionSiteMaps', ratID);
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    saveFileName = fullfile(outputFolder, sprintf('BrainRegionSiteMap_%s.pdf', ratID));
    set(gcf, 'WindowState', 'normal');         
    exportgraphics(gcf,saveFileName)

end % rat loop
