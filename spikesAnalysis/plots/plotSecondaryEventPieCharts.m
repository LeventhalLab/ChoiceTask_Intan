function plotSecondaryEventPieCharts(unitTable, params, behaviorField)
    % Define the primary events to analyze
    primaryEventsOfInterest = {'cueOn','centerIn','tone','centerOut','sideIn','sideOut','foodRetrieval'};
    treatmentTypes = {'control', 'lesion'};
    
    % Store behavior field in params for consistency
    params.behaviorField = behaviorField;

    % Filter unitTable by specified behavior
    unitTable = unitTable(strcmp(unitTable.behavior, params.behaviorField), :);

    % Replace empty secondary events with 'N.R.'
    secEventLabels = unitTable.secondaryEvent;
    isMissing = cellfun(@isempty, secEventLabels);
    secEventLabels(isMissing) = {'N.R.'};
    unitTable.secondaryEvent = secEventLabels;

    % Determine all secondary events including 'N.R.'
    secondaryEventList = unique(unitTable.secondaryEvent);
    nEvents = length(secondaryEventList);

    % Generate colormap with gray for 'N.R.'
    cmap = lines(nEvents);
    nrIdx = find(strcmp(secondaryEventList, 'N.R.'));
    if ~isempty(nrIdx)
        cmap(nrIdx, :) = [0.5 0.5 0.5]; % Gray for 'N.R.'
    end

    % Create figure once, set visibility based on params.viewplots
    % if params.viewplots
     fig = figure('Position', [100 100 300 * length(primaryEventsOfInterest), 650]);
    % else
    %     fig = figure('Position', [100 100 300 * length(primaryEventsOfInterest), 650], 'Visible', 'off');
    % end

    t = tiledlayout(2, length(primaryEventsOfInterest), 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, sprintf('%% of Secondary Events for Given Primary Events\nBehavior: %s | Region: %s', ...
        params.behaviorField, params.region), ...
        'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'none');

    % Plot pie charts
    for i = 1:length(primaryEventsOfInterest)
        primaryEvent = primaryEventsOfInterest{i};
        for j = 1:length(treatmentTypes)
            treatment = treatmentTypes{j};

            % Filter for condition
            mask = strcmp(unitTable.primaryEvent, primaryEvent) & ...
                   strcmp(unitTable.treatment, treatment);
            filtered = unitTable(mask, :);
            secEvents = filtered.secondaryEvent;

            % Index into master list
            [~, eventIdx] = ismember(secEvents, secondaryEventList);
            counts = accumarray(eventIdx, 1, [nEvents, 1]);

            % Percentages and labels
            total = sum(counts);
            if total == 0
                percentages = zeros(size(counts));
                labels = repmat({''}, size(counts));
            else
                percentages = counts / total * 100;
                labels = arrayfun(@(x) sprintf('%.1f%%', x), percentages, 'UniformOutput', false);
            end

            % Plot
            nexttile((j - 1) * length(primaryEventsOfInterest) + i)
            h = pie(percentages, labels);
            patchHandles = findobj(h, 'Type', 'Patch');
            for k = 1:length(patchHandles)
                set(patchHandles(k), 'FaceColor', cmap(k, :));
            end
            title(sprintf('%s | %s (%d units)', primaryEvent, treatment, total), 'Interpreter', 'none')
        end
    end

    % Add legend
    lgd = legend(secondaryEventList, 'Position', [0.92 0.3 0.07 0.4]);
    lgd.Title.String = 'Secondary Events';

    % Save figure
    saveas(fig, fullfile(params.regionSummaryPath, [params.behaviorField 'secondaryEventPieCharts.png']));

    % Close figure if not visible
    if ~params.viewplots
        close(fig);
    end
end