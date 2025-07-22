function primaryEventsProportionBarGraph(unitTable, params, behaviorField)
% Plot proportion of primary events per treatment and annotate with significance

savePath = params.regionSummaryPath;

% Sanitize for filename
safeBehaviorField = regexprep(behaviorField, '[^\w]', '_');

% Filter only relevant behavior
filteredTable = unitTable(strcmp(unitTable.behavior, behaviorField), :);
if isfield(params, 'controlSelectivityFilter')
    isControl = strcmp(filteredTable.treatment, 'control');
    filter=params.controlSelectivityFilter;
    isSelectivityMatch = strcmp(filteredTable.directionSelectivity, params.controlSelectivityFilter);
    keepControl = isControl & isSelectivityMatch;

    isLesion = strcmp(filteredTable.treatment, 'lesion');

    filteredTable = filteredTable(keepControl | isLesion, :);
end
% Define treatment groups and colors
treatments = {'control', 'lesion'};
colors = [0 0 0.5; 1 0.5 0]; % navy blue & orange

% Get unique primary events
primaryEvents = unique(filteredTable.primaryEvent, 'stable');
nEvents = length(primaryEvents);

% Initialize proportions
proportions = zeros(nEvents, 2);  % rows = events, cols = treatments

for i = 1:nEvents
    for j = 1:2
        thisEvent = strcmp(filteredTable.primaryEvent, primaryEvents{i});
        thisTreatment = strcmp(filteredTable.treatment, treatments{j});
        nTreatment = sum(thisTreatment);
        if nTreatment > 0
            proportions(i, j) = sum(thisEvent & thisTreatment) / nTreatment;
        else
            proportions(i, j) = NaN;
        end
    end
end

% Run significance test
results = comparePrimaryEventProportions(filteredTable, behaviorField);

% Create figure once, set visibility based on params.viewplots
% if params.viewplots
    fig = figure('Units', 'inches', 'Position', [1, 1, 11, 8.5]);
% else
%     fig = figure('Units', 'inches', 'Position', [1, 1, 11, 8.5], 'Visible', 'off');
% end

set(gcf, 'PaperUnits', 'inches', 'PaperSize', [11 8.5], 'PaperPosition', [0 0 11 8.5]);

hold on;
barHandles = bar(proportions, 'grouped');
for j = 1:2
    barHandles(j).FaceColor = colors(j, :);
end

set(gca, 'XTickLabel', primaryEvents, 'FontSize', 12);
ylabel('Proportion of Units');
title(['Primary Event Distribution: ' strrep(behaviorField, '_', ' ') ' region: ' params.region]);
legend(treatments, 'Location', 'Best');

% Add significance labels
for i = 1:nEvents
    thisEvent = primaryEvents{i};
    if isfield(results, thisEvent)
        p = results.(thisEvent).p;
        if p < 0.001
            label = '***';
        elseif p < 0.01
            label = '**';
        elseif p < 0.05
            label = '*';
        else
            label = 'n.s.';
        end
        y = max(proportions(i, :), [], 'omitnan') + 0.05;
        text(i, y, label, 'HorizontalAlignment', 'center', ...
            'FontSize', 14, 'FontWeight', 'bold');
    end
end

ylim([0, min(1, max(proportions(:), [], 'omitnan') + 0.15)]);

% Save figure
if isfield(params,'controlSelectivityFilter')
    outFile = fullfile(savePath, [safeBehaviorField '_' filter '_controlsOnlyVsLesion' '_PrimaryEventProportionsIpsilateral.png']);
else
    outFile = fullfile(savePath, [safeBehaviorField  '_allControlsVsLesionPrimaryEventProportions.png']);
end
saveas(fig, outFile);

% Close figure if not visible
if ~params.viewplots
    close(fig);
end

end