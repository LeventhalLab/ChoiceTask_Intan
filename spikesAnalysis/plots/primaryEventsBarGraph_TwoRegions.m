function primaryEventsBarGraph_TwoRegions(unitTable, behaviorField, regionA, regionB, regionSummaryPath, params)
% Compare primary event proportions between two regions (e.g., VM vs cbRecipientsBroad)
% Matches style of primaryEventsBarGraph but replaces control vs lesion with regionA vs regionB.

%% Filter valid behavior
isTargetBehavior = strcmp(unitTable.behavior, behaviorField);
hasPrimaryEvent = ~cellfun(@isempty, unitTable.primaryEvent);
filteredTable = unitTable(isTargetBehavior & hasPrimaryEvent, :);

if isempty(filteredTable)
    warning('No valid entries for behavior: %s', behaviorField);
    return;
end

%% Extract only units from regionA and regionB
keep = strcmp(filteredTable.region, regionA) | strcmp(filteredTable.region, regionB);
filteredTable = filteredTable(keep, :);

if isempty(filteredTable)
    warning('No units found for selected regions.');
    return;
end

%% Extract unique primary events that exist in data
allPrimaryEvents = unique(filteredTable.primaryEvent);
[isInOrder, loc] = ismember(allPrimaryEvents, params.potentialeventNames);
existingEvents = allPrimaryEvents(isInOrder);
sortedIdx = loc(isInOrder);
[~, order] = sort(sortedIdx);
uniqueEvents = existingEvents(order);

numEvents = length(uniqueEvents);

%% Count occurrences per region
eventCounts = zeros(numEvents, 2); % [regionA, regionB]

for i = 1:numEvents
    evt = uniqueEvents{i};
    isEvt = strcmp(filteredTable.primaryEvent, evt);

    eventCounts(i,1) = sum(isEvt & strcmp(filteredTable.region, regionA));
    eventCounts(i,2) = sum(isEvt & strcmp(filteredTable.region, regionB));
end

%% Convert counts → proportions
colTotals = sum(eventCounts, 1);
eventProps = eventCounts ./ colTotals;

%% Plot
fig = figure('Position',[100,100,900,500],'Color','w');

b = bar(eventProps,'grouped');
b(1).FaceColor = [0.3 0.3 0.3];   % Black (Region A)
b(2).FaceColor = [210 180 140]/250;   % Orange (Region B)

xticks(1:numEvents);
xticklabels(strrep(uniqueEvents,'_','\_'));
xtickangle(45);
ylabel('Proportion of Units');
title(sprintf('Primary Events — %s (%s vs %s)', ...
    strrep(behaviorField,'_','\_'), regionA, regionB));

legend({regionA, regionB}, 'Location','northeast');
set(gca,'FontSize',12);
ylim([0 max(eventProps(:))*1.3]);
box off;
hold on;

%% Significance stars (Fisher’s exact test)
for i = 1:numEvents
    counts = eventCounts(i,:);

    if sum(counts) > 0
        nonCounts = sum(eventCounts,1) - counts;
        table2x2 = [counts; nonCounts];

        [~, p] = fishertest(table2x2);

        % Assign stars
        if p < 0.001
            stars = '***';
        elseif p < 0.01
            stars = '**';
        elseif p < 0.05
            stars = '*';
        else
            stars = 'n.s.';
        end

        if ~isempty(stars)
            y = max(eventProps(i,:));
            text(i, y + 0.02, stars, ...
                'HorizontalAlignment','center', ...
                'FontSize',14,'FontWeight','bold');
        end
    end
end

hold off;

%% Save
saveName = sprintf('primaryEvents_%s_%s_vs_%s_barplot.png', ...
    behaviorField, regionA, regionB);

saveas(fig, fullfile(regionSummaryPath, saveName));

if ~params.viewplots
    close(fig);
end

end
