function compareSecondaryEventPieChartsMultiBehavior(unitTable, params)
    % Define the primary events to analyze
    primaryEventsOfInterest = {'centerIn','tone','centerOut','sideIn','sideOut','foodRetrieval'};
    treatmentTypes = {'control', 'lesion'};
    behaviorFields = params.behaviorField;
    savePath = params.regionSummaryPath;
    region = params.region;

    % Add 'N.R.' label to empty secondaryEvent entries
    secEventLabels = unitTable.secondaryEvent;
    isMissing = cellfun(@isempty, secEventLabels);
    secEventLabels(isMissing) = {'N.R.'};
    unitTable.secondaryEvent = secEventLabels;

    % Get complete list of secondary events including 'N.R.'
    allSecondaryEvents = unitTable.secondaryEvent;
    secondaryEventList = unique(allSecondaryEvents);
    nEvents = length(secondaryEventList);

    % Color map: use lines() for events, set 'N.R.' to gray
    cmap = lines(nEvents);
    nrIdx = find(strcmp(secondaryEventList, 'N.R.'));
    if ~isempty(nrIdx)
        cmap(nrIdx, :) = [0.5 0.5 0.5];  % gray for 'N.R.'
    end

    % Create figure
    numBehaviors = length(behaviorFields);
    numRows = 2 * numBehaviors;
    numCols = length(primaryEventsOfInterest);
    figure('Position', [100 100 300 * numCols, 300 * numRows]);
    t = tiledlayout(numRows, numCols, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, sprintf('%% of Secondary Events for Given Primary Events\nRegion: %s', region), ...
        'FontSize', 12, 'FontWeight', 'bold');

    for b = 1:numBehaviors
        behavior = behaviorFields{b};
        for j = 1:length(treatmentTypes)
            treatment = treatmentTypes{j};
            rowIdx = (b - 1) * 2 + j;

            for i = 1:length(primaryEventsOfInterest)
                primaryEvent = primaryEventsOfInterest{i};

                % Filter data
                mask = strcmp(unitTable.behavior, behavior) & ...
                       strcmp(unitTable.primaryEvent, primaryEvent) & ...
                       strcmp(unitTable.treatment, treatment);
                filtered = unitTable(mask, :);

                % Get secondary events (now includes 'N.R.')
                secEvents = filtered.secondaryEvent;

                % Index into secondaryEventList
                [~, eventIdx] = ismember(secEvents, secondaryEventList);
                counts = accumarray(eventIdx, 1, [nEvents, 1]);

                % Compute percentages and labels
                total = sum(counts);
                if total == 0
                    percentages = zeros(size(counts));
                    labels = repmat({''}, size(counts));
                else
                    percentages = counts / total * 100;
                    labels = arrayfun(@(x) sprintf('%.1f%%', x), percentages, 'UniformOutput', false);
                end

                % Plot pie chart
                tileIndex = (rowIdx - 1) * numCols + i;
                nexttile(tileIndex)
                h = pie(percentages, labels);
                patchHandles = findobj(h, 'Type', 'Patch');
                for k = 1:length(patchHandles)
                    set(patchHandles(k), 'FaceColor', cmap(k,:));
                end
                title(sprintf('%s | %s | %s (%d units)', behavior, primaryEvent, treatment, total), ...
                    'Interpreter', 'none', 'FontSize', 8);
            end
        end
    end

    % Add legend outside plot
    lgd = legend(secondaryEventList, 'Position', [0.92 0.3 0.07 0.4]);
    lgd.Title.String = 'Secondary Events';

    % Save figure
    saveas(gcf, fullfile(savePath, 'compareSecondaryEventPieCharts.png'));
    %close;
end