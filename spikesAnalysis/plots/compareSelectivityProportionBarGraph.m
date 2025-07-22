function compareSelectivityProportionBarGraph(unitTable, params, behaviorField)
% Compare proportions of primary events between two selectivity types

savePath = params.regionSummaryPath;
safeBehaviorField = regexprep(behaviorField, '[^\w]', '_');

% Filter to the specified treatment and behavior
filteredTable = unitTable( ...
    strcmp(unitTable.behavior, behaviorField) & ...
    strcmp(unitTable.treatment, params.treatmentFilter), :);

% Filter to selectivity types to compare
selTypes = params.compareSelectivity;
selMask = ismember(filteredTable.directionSelectivity, selTypes);
filteredTable = filteredTable(selMask, :);

% Define groups and colors
colors = [0.8500 0.3250 0.0980; 0 0.4470 0.7410]; % Orange vs. Blue
nGroups = 2;

% Get unique primary events
primaryEvents = unique(filteredTable.primaryEvent, 'stable');
nEvents = length(primaryEvents);

% Initialize proportions
proportions = zeros(nEvents, nGroups); % rows = events, cols = selectivity types

for i = 1:nEvents
    for j = 1:nGroups
        thisEvent = strcmp(filteredTable.primaryEvent, primaryEvents{i});
        thisSelectivity = strcmp(filteredTable.directionSelectivity, selTypes{j});
        nType = sum(thisSelectivity);
        if nType > 0
            proportions(i, j) = sum(thisEvent & thisSelectivity) / nType;
        else
            proportions(i, j) = NaN;
        end
    end
end

% Run Fisher's exact test for each event
results = struct();
for i = 1:nEvents
    counts = zeros(2,2); % rows = selectivity types, cols = [event, not event]
    for j = 1:nGroups
        thisSelectivity = strcmp(filteredTable.directionSelectivity, selTypes{j});
        counts(j,1) = sum(strcmp(filteredTable.primaryEvent, primaryEvents{i}) & thisSelectivity);
        counts(j,2) = sum(thisSelectivity) - counts(j,1);
    end

    % Perform Fisher's exact test (better than chi2 for 2x2 and small samples)
    if all(counts(:) > 0)
        [~, p] = fishertest(counts);
    else
        p = NaN;
    end
    results.(primaryEvents{i}) = p;
end

% Create figure
fig = figure('Units', 'inches', 'Position', [1, 1, 11, 8.5]);
set(gcf, 'PaperUnits', 'inches', 'PaperSize', [11 8.5], 'PaperPosition', [0 0 11 8.5]);

hold on;
barHandles = bar(proportions, 'grouped');
for j = 1:nGroups
    barHandles(j).FaceColor = colors(j, :);
end

set(gca, 'XTickLabel', primaryEvents, 'FontSize', 12);
ylabel('Proportion of Units');
title(['Primary Event by Selectivity: ' strrep(behaviorField, '_', ' ') ' in ' params.treatmentFilter 's']);
legend(selTypes, 'Location', 'Best');

% Annotate with p-values
for i = 1:nEvents
    p = results.(primaryEvents{i});
    if isnan(p)
        label = 'n/a';
    elseif p < 0.001
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

ylim([0, min(1, max(proportions(:), [], 'omitnan') + 0.15)]);

% Save figure
outFile = fullfile(savePath, [safeBehaviorField '_SelectivityProportions.png']);
saveas(fig, outFile);

if ~params.viewplots
    close(fig);
end

end