function comparePrimaryEventProportionsByBehavior(unitTable, params)
    % Define primary events of interest
    behaviorFields=params.behaviorField;
    treatmentType=params.treatmentToProcess;
    savePath=params.regionSummaryPath;
    region=params.region;
    filteredTable = unitTable(strcmp(unitTable.treatment, treatmentType), :);
    primaryEvents = unique(unitTable.primaryEvent);
    numPrimaryEvents = numel(primaryEvents);
    numBehaviors = numel(behaviorFields);

    % Initialize count matrix
    counts = zeros(numBehaviors, numPrimaryEvents);

    % Count how many units for each primaryEvent x behavior
    for i = 1:numBehaviors
        behavior = behaviorFields{i};
        behaviorTable = filteredTable(strcmp(filteredTable.behavior, behavior), :);
        for j = 1:numPrimaryEvents
            counts(i, j) = sum(strcmp(behaviorTable.primaryEvent, primaryEvents{j}));
        end
    end

    % Normalize to get proportions
    proportions = counts ./ sum(counts, 2);

    % Plot
    figure('Position', [100 100 800 400]);
    b = bar(proportions', 'grouped');
    xticks(1:numPrimaryEvents);
    xticklabels(primaryEvents);
    ylabel('Proportion');
    legend(behaviorFields, 'Location', 'northeastoutside');
    title(sprintf('Primary Event Proportions by Behavior (%s) - %s', treatmentType, region), 'Interpreter', 'none');
    ylim([0 1]);

    % Colors
    cmap = lines(numBehaviors);
    for i = 1:numBehaviors
        b(i).FaceColor = cmap(i,:);
    end

    % Add significance annotations
    hold on;
    for j = 1:numPrimaryEvents
        row = counts(:,j);
        if all(row == 0)
            continue;
        end
        % Chi-squared test across behaviors for this event
        [~, p] = chi2gof(1:numBehaviors, 'Freq', row', ...
            'Expected', mean(row) * ones(size(row)), ...
            'NParams', 0);

        % Determine stars
        if p < 0.001
            stars = '***';
        elseif p < 0.01
            stars = '**';
        elseif p < 0.05
            stars = '*';
        else
            stars = 'n.s.';
        end

        % Plot significance above the highest bar
        maxHeight = max(proportions(:, j));
        text(j, maxHeight + 0.05, stars, ...
            'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
    end
    hold off;

    % Save
    if ~isempty(savePath)
        saveas(gcf, fullfile(savePath, sprintf('primaryEventProportions_byBehavior_%s.png', treatmentType)));
        %close;
    end
end