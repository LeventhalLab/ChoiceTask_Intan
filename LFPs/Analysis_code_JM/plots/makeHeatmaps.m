% heat map script 2
% makeHeatmaps
% ZHH 7/8/24

%uses the heatmap tables created in heatmapTableMaker to create heatmaps
%for each rat
% each frequency bin gets its own color

%{ 
Quick info
location:
X:\Neuro-Leventhal\data\ChoiceTask\GitHub\ChoiceTask_Intan\LFPs\Analysis_code_JM\plots
functions called:none
files used:
heat map tables created by heatmapTableMaker
filePath = fullfile('X:\Neuro-Leventhal\data\ChoiceTask\heatmap tables', ratID, ['heatmapTable_' ratID '.mat']);
Outputs save to:
    intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';
    outputFolder = fullfile(intan_choicetask_parent, 'heatmaps', ratID);

last updated 7/09/24.

reminders:
update ratID list as new rats are added

sometimes the heatmaps open weird in adobe acrobat, if so, completely close
out adobe acrobat reader and try again
%}

ratID_list = ['R0326', 'R0327', 'R0372', 'R0376', 'R0378', 'R0379', 'R0394','R0395','R0396','R0412','R0413','R0419','R0420','R0425','R0427','R0456','R0460','R0463','R0465','R0466','R0467','R0479','R0492','R0493','R0494','R0495' ];


% theres currently 26 rats in the ratID list
for rat=10%1:26
ratID = ratID_list(rat*5-4:rat*5); %pulls the ratID from the ratID list

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

figure('Position', [500, 50, 1400,950])

% i want to see what a 2,3 arrangement would look like for the NN probes
% becuase right now the labels dont fit in the cells 
if rat >=12 
    % normal create tiled display (nonNN)
    t=tiledlayout("horizontal");
else %NN rats
    t=tiledlayout(2,3);
end
t.TileSpacing = 'tight';
t.Padding = 'none';
title(t,sprintf('%s heatmaps',ratID),'FontSize',24)
%ylabel(t,'channels','FontSize',14)



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
% ________________________
nexttile
deltaData = heatmapTable(strcmp(heatmapTable.FreqBin, 'Delta'), :);
h1= heatmap(deltaData,'ShankNum','RowNum','ColorVariable','Value');
cmap = [linspace(1, colorsRGB(1,1),256)', linspace(1, colorsRGB(1,2),256)', linspace(1,colorsRGB(1,3),256)'];
    % Apply the custom color map
    colormap(h1,cmap);
h1.CellLabelFormat = '%0.3g';
% for rats 1-11, go to 7 instead of 15
if rat >= 12
    %for rats 12.....
    h1.YDisplayData = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'};
else %rats 1-11 (NN rats)
    h1.XDisplayData = {'1','2','3','4','5','6','7','8'};
  
    h1.FontSize = 18;
end
xlabel(h1, 'Shank');
ylabel(h1, 'Row');
title(h1, 'Freq Bin: delta 1-4Hz');

%repeat for each frequency bin

nexttile
thetaData = heatmapTable(strcmp(heatmapTable.FreqBin, 'Theta'), :);
h2= heatmap(thetaData,'ShankNum','RowNum','ColorVariable','Value');
cmap = [linspace(1,colorsRGB(2,1),256)', linspace(1,colorsRGB(2,2),256)', linspace(1, colorsRGB(2,3),256)'];
    % Apply the custom color map
    colormap(h2,cmap);
h2.CellLabelFormat = '%0.3g';
% for rats 1-11, go to 7 instead of 15
if rat >=12
    %for rats 12.....
    h2.YDisplayData = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'};
else %rats 1-11 (NN rats)
    h2.XDisplayData = {'1','2','3','4','5','6','7','8'};
    h2.FontSize = 18;
end
xlabel(h2, 'Shank');
ylabel(h2, 'Row');
title(h2, 'Freq Bin: theta 4-8Hz');

%not displaying numbers for rat 1, try rounding
nexttile
alphaData = heatmapTable(strcmp(heatmapTable.FreqBin, 'Alpha'), :);
h3= heatmap(alphaData,'ShankNum','RowNum','ColorVariable','Value');
cmap = [linspace(1,colorsRGB(3,1),256)', linspace(1,colorsRGB(3,2),256)', linspace(1,colorsRGB(3,3),256)'];
    % Apply the custom color map
    colormap(h3,cmap);
h3.CellLabelFormat = '%0.3g';
% for rats 1-11, go to 7 instead of 15
if rat >=12
    %for rats 12.....
    h3.YDisplayData = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'};
else %rats 1-11 (NN rats)
    h3.XDisplayData = {'1','2','3','4','5','6','7','8'};
    h3.FontSize = 18;
end
xlabel(h3, 'Shank');
ylabel(h3, 'Row');
title(h3, 'Freq Bin: alpha 8-13Hz');

nexttile
betaData = heatmapTable(strcmp(heatmapTable.FreqBin, 'Beta'), :);
h4= heatmap(betaData,'ShankNum','RowNum','ColorVariable','Value');
cmap = [linspace(1,colorsRGB(4,1),256)', linspace(1,colorsRGB(4,2),256)', linspace(1,colorsRGB(4,3),256)'];
    % Apply the custom color map
    colormap(h4,cmap);
h4.CellLabelFormat = '%0.3g';
% for rats 1-11, go to 7 instead of 15
if rat >=12
    %for rats 12.....
    h4.YDisplayData = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'};
else %rats 1-11 (NN rats)
    h4.XDisplayData = {'1','2','3','4','5','6','7','8'};
    h4.FontSize = 18;
end
xlabel(h4, 'Shank');
ylabel(h4, 'Row');
title(h4, 'Freq Bin: beta 13-30Hz');

nexttile
l_gammaData = heatmapTable(strcmp(heatmapTable.FreqBin, 'L Gamma'), :);
h5= heatmap(l_gammaData,'ShankNum','RowNum','ColorVariable','Value');
cmap = [linspace(1, colorsRGB(5,1),256)', linspace(1,colorsRGB(5,2),256)', linspace(1,colorsRGB(5,3),256)'];
    % Apply the custom color map
    colormap(h5,cmap);
h5.CellLabelFormat = '%0.3g';
% for rats 1-11, go to 7 instead of 15
if rat >=12
    %for rats 12.....
    h5.YDisplayData = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'};
else %rats 1-11 (NN rats)
    h5.XDisplayData = {'1','2','3','4','5','6','7','8'};
    h5.FontSize = 18;
end
xlabel(h5, 'Shank');
ylabel(h5, 'Row');
title(h5, 'Freq Bin: low gamma 30-70Hz');

nexttile
h_gammaData = heatmapTable(strcmp(heatmapTable.FreqBin, 'H Gamma'), :);
h6= heatmap(h_gammaData,'ShankNum','RowNum','ColorVariable','Value');
cmap = [linspace(1, colorsRGB(6,1),256)', linspace(1,colorsRGB(6,2),256)', linspace(1,colorsRGB(6,3),256)'];
    % Apply the custom color map
    colormap(h6,cmap);
%h.CellLabelFormat = '%0.3g';
% for rats 1-11, go to 7 instead of 15
if rat >=12
    %for rats 12.....
    h6.YDisplayData = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'};
else %rats 1-11 (NN rats)
    h6.XDisplayData = {'1','2','3','4','5','6','7','8'};
    h6.FontSize = 18;
end
xlabel(h6, 'Shank');
ylabel(h6, 'Row');
title(h6, 'Freq Bin: high gamma 70-200Hz');


disp(ratID);
%disp(t);

    % Save results table for this rat
    intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';
    outputFolder = fullfile(intan_choicetask_parent, 'heatmaps', ratID);
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    saveFileName = fullfile(outputFolder, sprintf('heatmaps_%s.pdf', ratID));
    %this is not what i want (saves variable info, not the figure itself)
    %save(saveFileName,'t');
    %set(gcf, 'WindowState', 'maximize'); % maximizes the window so that it exports the graphics with appropriate font size        
    exportgraphics(gcf,saveFileName)
    %use to stop at a particular rat (NN rats end at 11)
    %{
    if rat==5
        break;
    end
    %}
end
