function comparePrimaryEventProportionsByBehavior(unitTable, params, treatmentType)
% Compare primary event proportions across behaviors for a given treatment type.
% Events are plotted in the order defined by params.potentialeventNames.

    % Parameters
    behaviorFields = params.behaviorField;
    savePath = params.regionSummaryPath;
    region = params.region;

    % Filter by treatment
    filteredTable = unitTable(strcmp(unitTable.treatment, treatmentType), :);

    % Get all primary events in the data
    primaryEventsInData = unique(filteredTable.primaryEvent);

    numBehaviors = numel(behaviorFields);

    % Initialize count matrix
    counts = zeros(numBehaviors, numel(primaryEventsInData));

    % Count units for each primaryEvent × behavior
    for i = 1:numBehaviors
        behavior = behaviorFields{i};
        behaviorTable = filteredTable(strcmp(filteredTable.behavior, behavior), :);
        for j = 1:numel(primaryEventsInData)
            counts(i, j) = sum(strcmp(behaviorTable.primaryEvent, primaryEventsInData{j}));
        end
    end

    % Normalize counts to get proportions
    proportions = counts ./ sum(counts, 2);

    % --- Reorder according to params.potentialeventNames ---
    desiredOrder = params.potentialeventNames;
    [found, orderIdx] = ismember(desiredOrder, primaryEventsInData);

    % Keep only events that exist in the data
    validOrderIdx = orderIdx(found);
    proportions = proportions(:, validOrderIdx);
    counts = counts(:, validOrderIdx);
    primaryEvents = desiredOrder(found);
    numEvents = numel(primaryEvents);

    % --- Plot ---
    figure('Position', [100 100 900 400]);
    b = bar(proportions', 'grouped');
    xticks(1:numEvents);
    xticklabels(primaryEvents);
    ylabel('Proportion');
    legend(behaviorFields, 'Location', 'northeastoutside');
    title(sprintf('Primary Event Proportions by Behavior (%s) - %s', treatmentType, region), ...
        'Interpreter', 'none');
    ylim([0 1]);

    % Bar colors
    cmap = lines(numBehaviors);
    for i = 1:numBehaviors
        b(i).FaceColor = cmap(i,:);
    end

    % --- Add significance annotations (Chi-squared on raw counts) ---
    hold on;
    for j = 1:numEvents
        rawRow = counts(:, j);

        % Skip if all zero
        if all(rawRow == 0)
            continue;
        end

        % Expected counts (uniform across behaviors)
        expected = mean(rawRow) * ones(size(rawRow));

        % Only test if ≥2 groups have data
        if sum(rawRow > 0) > 1
            [~, p] = chi2gof(1:numBehaviors, 'Freq', rawRow', ...
                'Expected', expected, 'NParams', 0);
        else
            p = 1;
        end

        % Significance stars
        if p < 0.001
            stars = '***';
        elseif p < 0.01
            stars = '**';
        elseif p < 0.05
            stars = '*';
        else
            continue; % no mark for non-significant
        end

        % Plot stars above bar group
        maxHeight = max(proportions(:, j));
        text(j, maxHeight + 0.05, stars, ...
            'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
    end
    hold off;

    % --- Save Figure ---
    if ~isempty(savePath)
        saveas(gcf, fullfile(savePath, ...
            sprintf('primaryEventProportions_byBehavior_%s.png', treatmentType)));
        %close;
    end
end
