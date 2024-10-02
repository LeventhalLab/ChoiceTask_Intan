% NNTransparentPlot
%ZHH 7/24/24

% use the 3D scattering like coordinatePlot3D but
% each frequency bin gets a tile and a color
% the power is the transparency
% but its just the 8 NN8x8 probe rats

% uses bigTable created in coordinatePlot3D

%figure saved to X:\Neuro-Leventhal\data\ChoiceTask\voxel power




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

%i want to exclude the rats that dont have coordinate data (bad histo)
% Define rat IDs to exclude
% also throwing in 425 bc its the only one with a negative AP coordinate,
% its all alone
excludeRatIDs = {'R0376', 'R0374', 'R0396', 'R0413', 'R0419', 'R0420', 'R0425', 'R0427', 'R0456', 'R0460', 'R0463', 'R0465'};
% Find rows with ratIDs to exclude
rowsToExclude = ismember(bigTable.RatID, excludeRatIDs);
% Exclude rows from bigTable
filteredTable = bigTable(~rowsToExclude, :);

%% make 3D plot of midpoint coordinates 

% Create figure for the scatter plot
figure;
t=tiledlayout('flow');

nexttile
hold on;
% delta - red
deltaTable = filteredTable(strcmp(filteredTable.FreqBin, 'Delta'), :);
deltaScatter = scatter3(deltaTable.AP_M,deltaTable.ML_M,deltaTable.DV_M,'MarkerFaceColor',"red",'MarkerEdgeColor',"red",'AlphaData',deltaTable.Value,'MarkerFaceAlpha','flat','MarkerEdgeAlpha','flat');
title('Delta');
xlabel('AP (mm)');
ylabel('ML (mm)');
zlabel('DV (mm)');

%{
% if you want to change the color or marer type based on rat ID or region,
% you need to use this type of approach instead:
deltaTable = filteredTable(strcmp(filteredTable.FreqBin, 'Delta'), :);
%can we try to turn VM points into x's?
%for each row in the delta table
for eachrow=1:height(deltaTable)
    deltaScatter = scatter3(deltaTable.AP_M(eachrow),deltaTable.ML_M(eachrow),deltaTable.DV_M(eachrow),50,'MarkerFaceColor',"red",'MarkerEdgeColor',"red",'AlphaData',deltaTable.Value(eachrow),'MarkerFaceAlpha','flat','MarkerEdgeAlpha','flat');
% if the top region at that row is VM,
    %might have to make the cell into a string but wtvr
    EachRegionTop=cell2mat(deltaTable.RegionTop(eachrow));
    if strcmp(EachRegionTop,'VM')
% set the delta scatter . marker to x at that row?
        deltaScatter.Marker="x";
        deltaScatter.MarkerFaceColor="k";
    else
        %dont do anything
    end
    disp(eachrow);
end
hold off;
%}

nexttile
% theta - orange
thetaTable = filteredTable(strcmp(filteredTable.FreqBin, 'Theta'), :);
thetaScatter = scatter3(thetaTable.AP_M,thetaTable.ML_M,thetaTable.DV_M,'MarkerFaceColor',"#D95319",'MarkerEdgeColor',"#D95319",'AlphaData',thetaTable.Value,'MarkerFaceAlpha','flat','MarkerEdgeAlpha','flat');
title('Theta');
xlabel('AP (mm)');
ylabel('ML (mm)');
zlabel('DV (mm)');

nexttile
% alpha - yellow
alphaTable = filteredTable(strcmp(filteredTable.FreqBin, 'Alpha'), :);
alphaScatter = scatter3(alphaTable.AP_M,alphaTable.ML_M,alphaTable.DV_M,'MarkerFaceColor',"#EDB120",'MarkerEdgeColor',"#EDB120",'AlphaData',alphaTable.Value,'MarkerFaceAlpha','flat','MarkerEdgeAlpha','flat');
title('Alpha');
xlabel('AP (mm)');
ylabel('ML (mm)');
zlabel('DV (mm)');

nexttile
% beta - green
betaTable = filteredTable(strcmp(filteredTable.FreqBin, 'Beta'), :);
betaScatter = scatter3(betaTable.AP_M,betaTable.ML_M,betaTable.DV_M,'MarkerFaceColor',	"#77AC30",'MarkerEdgeColor',	"#77AC30",'AlphaData',betaTable.Value,'MarkerFaceAlpha','flat','MarkerEdgeAlpha','flat');
title('Beta');
xlabel('AP (mm)');
ylabel('ML (mm)');
zlabel('DV (mm)');

nexttile
% lgamma - blue
lgammaTable = filteredTable(strcmp(filteredTable.FreqBin, 'L Gamma'), :);
lgammaScatter = scatter3(lgammaTable.AP_M,lgammaTable.ML_M,lgammaTable.DV_M,'MarkerFaceColor',	"#0072BD",'MarkerEdgeColor',	"#0072BD",'AlphaData',lgammaTable.Value,'MarkerFaceAlpha','flat','MarkerEdgeAlpha','flat');
title('Low Gamma');
xlabel('AP (mm)');
ylabel('ML (mm)');
zlabel('DV (mm)');

nexttile
%hgamma - purple
hgammaTable = filteredTable(strcmp(filteredTable.FreqBin, 'H Gamma'), :);
hgammaScatter = scatter3(hgammaTable.AP_M,hgammaTable.ML_M,hgammaTable.DV_M,'MarkerFaceColor',"#7E2F8E",'MarkerEdgeColor',"#7E2F8E",'AlphaData',hgammaTable.Value,'MarkerFaceAlpha','flat','MarkerEdgeAlpha','flat');
title('High Gamma');
xlabel('AP (mm)');
ylabel('ML (mm)');
zlabel('DV (mm)');


%{
this is how i color coded based on rat in coordinatePlot3D for reference
% Get unique RatIDs and assign a color to each one
uniqueRatIDs = unique(filteredTable.RatID);
numRatIDs = numel(uniqueRatIDs);
for i = 1:numRatIDs
    % Filter data for the current RatID
    currentRatID = uniqueRatIDs{i};
    idx = strcmp(filteredTable.RatID, currentRatID);
    
    % Scatter plot for current RatID with unique color from colormap
    scatter3(filteredTable.AP_M(idx), filteredTable.ML_M(idx), filteredTable.DV_M(idx), 36, colorMap(i,:), 'filled');
end
%}







% Customize plot properties
title(t,'3D Scatter Plot of Midpoint Coordinates NN only (transparency = power)');
%outdated legend
% legend(uniqueRatIDs, 'Location', 'eastoutside');  % Legend with RatID labels
grid on;

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

% savefig('X:\Neuro-Leventhal\data\ChoiceTask\voxel power\NNTransparentPlot.fig')


