function compareSecondaryEventPieCharts2Behaviors(unitTable, params)
    % Define the primary events to analyze
    primaryEventsOfInterest = {'cueOn','centerIn','tone','centerOut','sideIn','sideOut','foodRetrieval' }; % Add more if needed
    treatmentTypes = {'control', 'lesion'};

    % Validate behaviorFieldCell
    if ~iscell(params.behaviorField) || numel(params.behaviorField) ~= 2
        error('params.behaviorField must be a cell array of two behavior field strings.');
    end
    
    behaviorFields = params.behaviorField;

    % Determine unique secondary events and assign consistent colors
    allSecondaryEvents = unitTable.secondaryEvent(~cellfun(@isempty, unitTable.secondaryEvent));
    secondaryEventList = unique(allSecondaryEvents);
    nEvents = length(secondaryEventList);
    cmap = lines(nEvents);  % consistent colormap
    eventColors = containers.Map(secondaryEventList, mat2cell(cmap, ones(1, nEvents), 3));

    % Create figure
    figure('Position', [100 100 300 * length(primaryEventsOfInterest), 650]);
    t = tiledlayout(2 * length(behaviorFields), length(primaryEventsOfInterest), 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, sprintf('%% of Secondary Events for Given Primary Events\nRegion: %s', params.region), ...
        'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'none');

    % Iterate through behavior fields, primary events, and treatment types
    for b = 1:length(behaviorFields)
        behaviorField = behaviorFields{b};
        behaviorTable = unitTable(strcmp(unitTable.behavior, behaviorField), :);

        for i = 1:length(primaryEventsOfInterest)
            primaryEvent = primaryEventsOfInterest{i};
            for j = 1:length(treatmentTypes)
                treatment = treatmentTypes{j};

                % Filter data for this condition
                mask = strcmp(behaviorTable.primaryEvent, primaryEvent) & strcmp(behaviorTable.treatment, treatment);
                filtered = behaviorTable(mask, :);

                % Get secondary event counts
                secEvents = filtered.secondaryEvent;
                secEvents = secEvents(~cellfun(@isempty, secEvents));

                % Index secondary events
                [~, eventIdx] = ismember(secEvents, secondaryEventList);
                eventIdx(eventIdx == 0) = [];  % Remove unmatched
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

                % Pie chart
                rowOffset = (b-1)*2 + (j-1);  % Controls row indexing
                nexttile(rowOffset * length(primaryEventsOfInterest) + i)
                h = pie(percentages, labels);
                % Apply consistent colors
                patchHandles = findobj(h, 'Type', 'Patch');
                for k = 1:length(patchHandles)
                    set(patchHandles(k), 'FaceColor', cmap(k,:));
                end

                title(sprintf('%s | %s | %s (%d units)', primaryEvent, behaviorField, treatment, total), 'Interpreter', 'none')
            end
        end
    end

    % Add legend outside plot
    lgd = legend(secondaryEventList, 'Position', [0.92 0.3 0.07 0.4]);
    lgd.Title.String = 'Secondary Events';

    % Save
    saveas(gcf, fullfile(params.regionSummaryPath, 'compareSecondaryEventPieCharts.png'));
    % close;
end
