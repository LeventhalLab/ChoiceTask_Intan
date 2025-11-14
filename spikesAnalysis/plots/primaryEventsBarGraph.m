function primaryEventsBarGraph(unitTable, behaviorField, regionSummaryPath, params)
% Plot proportions of primary events by treatment group (control vs lesion)
% Events are sorted according to params.potentialEventNames
% Adds significance stars comparing control vs lesion (Fisher's exact test)

%% Filter valid entries
isTargetBehavior = strcmp(unitTable.behavior, behaviorField);
hasPrimaryEvent = ~cellfun(@isempty, unitTable.primaryEvent);
filteredTable = unitTable(isTargetBehavior & hasPrimaryEvent, :);

if isempty(filteredTable)
    warning('No valid entries for behavior: %s', behaviorField);
    return;
end

%% Extract unique primary events that exist in data
allPrimaryEvents = unique(filteredTable.primaryEvent);
[isInOrder, loc] = ismember(allPrimaryEvents, params.potentialeventNames);
existingEvents = allPrimaryEvents(isInOrder);
sortedIdx = loc(isInOrder);
[~, order] = sort(sortedIdx);  % sort according to potentialEventNames
uniqueEvents = existingEvents(order);

%% Count occurrences per treatment
numEvents = length(uniqueEvents);
eventCounts = zeros(numEvents, 2); % [control, lesion]

for i = 1:numEvents
    event = uniqueEvents{i};
    isEvent = strcmp(filteredTable.primaryEvent, event);
    eventCounts(i,1) = sum(isEvent & strcmp(filteredTable.treatment, 'control'));
    eventCounts(i,2) = sum(isEvent & strcmp(filteredTable.treatment, 'lesion'));
end

%% Convert counts to proportions
colTotals = sum(eventCounts,1);
eventProps = eventCounts ./ colTotals;

%% Plot
fig = figure('Position', [100, 100, 900, 500], 'Visible', 'on');
b = bar(eventProps, 'grouped');

b(1).FaceColor = [0 0 0.5];   % Control
b(2).FaceColor = [1 0.5 0];   % Lesion

xticks(1:numEvents);
xticklabels(strrep(uniqueEvents, '_', '\_'));
xtickangle(45);
ylabel('Proportion of Responsive Units');
title(['Primary Events (Proportion) — ' strrep(behaviorField, '_', '\_')]);
legend({'Control', 'Lesion'}, 'Location', 'northeast');
set(gca, 'FontSize', 12);
ylim([0 max(eventProps(:)) * 1.3]);
box off;
hold on;

%% Add significance stars per event (Fisher's exact test)
for i = 1:numEvents
    counts = eventCounts(i,:); % raw counts
    % Only test if at least one event occurred
    if sum(counts) > 0
        % Construct 2x2 contingency table
        % [event_control, event_lesion; non_event_control, non_event_lesion]
        nonEventCounts = sum(eventCounts,1) - counts;
        table2x2 = [counts; nonEventCounts];
        % Fisher's exact test
        [~, p] = fishertest(table2x2);
        
        % Determine stars
        if p < 0.001
            stars = '***';
        elseif p < 0.01
            stars = '**';
        elseif p < 0.05
            stars = '*';
        else
            stars = '';
        end
        
        % Plot star above the higher bar
        if ~isempty(stars)
            y = max(eventProps(i,:));
            text(i, y + 0.02, stars, 'HorizontalAlignment','center','FontSize',14,'FontWeight','bold');
        end
    end
end
hold off;

%% Save figure
saveas(fig, fullfile(regionSummaryPath, ['primaryEvents_' behaviorField '_proportion_barplot.png']));

if ~params.viewplots
    close(fig);
end

end
