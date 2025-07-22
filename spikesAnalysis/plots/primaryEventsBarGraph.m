function primaryEventsBarGraph(unitTable, behaviorField, regionSummaryPath, params)
% Plot bar graph of primary events by treatment group and save the figure

% Filter by behavior and valid primaryEvent
isTargetBehavior = strcmp(unitTable.behavior, behaviorField);
hasPrimaryEvent = ~cellfun(@isempty, unitTable.primaryEvent);
filteredTable = unitTable(isTargetBehavior & hasPrimaryEvent, :);

% Extract unique primary events
allPrimaryEvents = filteredTable.primaryEvent;
uniqueEvents = unique(allPrimaryEvents);

% Count for each event split by treatment
eventCounts = zeros(length(uniqueEvents), 2); % [control, lesion]
for i = 1:length(uniqueEvents)
    event = uniqueEvents{i};
    isEvent = strcmp(filteredTable.primaryEvent, event);
    eventCounts(i,1) = sum(isEvent & strcmp(filteredTable.treatment, 'control'));
    eventCounts(i,2) = sum(isEvent & strcmp(filteredTable.treatment, 'lesion'));
end

% Create figure once
% if params.viewplots
fig = figure('Position', [100, 100, 900, 500]);
% else
%     fig = figure('Position', [100, 100, 900, 500], 'Visible', 'off');
% end

% Plot bar graph
b = bar(eventCounts, 'grouped');

% Set colors for each group
b(1).FaceColor = [0 0 0.5];     % blue for control
b(2).FaceColor = [1 0.5 0];     % orange for lesion

xticks(1:length(uniqueEvents));
xticklabels(strrep(uniqueEvents, '_', '\_'));
xtickangle(45);
ylabel('Number of Responsive Units');
title(['Primary Events for Behavior: ' strrep(behaviorField, '_', '\_')]);
legend({'Control', 'Lesion'}, 'Location', 'northeast');
set(gca, 'FontSize', 12);
ylim([0 max(eventCounts(:)) * 1.2]);
box off;

% Save figure
saveas(fig, fullfile(regionSummaryPath, ['primaryEvents_' behaviorField '_barplot.png']));

% Close figure if not visible
if ~params.viewplots
    close(fig);
end

end