function comparePrimaryEventBySelectivity2(unitTable, parentDir, behaviorField, params)
% Compare fraction of units by direction selectivity groups
% for a specific behaviorField and plot bar graph with pairwise significance.

% Filter by behavior field
filteredTable = unitTable(strcmp(unitTable.behavior, behaviorField), :);

% Selectivity groups to compare
if ~isfield(params, 'compareSelectivity') || length(params.compareSelectivity) < 2
    error('You must specify at least two selectivity groups in params.compareSelectivity');
end
selectivityGroups = params.compareSelectivity;
numGroups = numel(selectivityGroups);

% Keep only specified selectivity groups
filteredTable = filteredTable(ismember(filteredTable.directionSelectivity, selectivityGroups), :);

% Get unique primary events
primaryEvents = unique(filteredTable.primaryEvent, 'stable');
numEvents = numel(primaryEvents);

% Initialize
proportions = zeros(numEvents, numGroups);
pMatrix = cell(numEvents, numGroups, numGroups);
colors = lines(numGroups);

% Compute proportions and chi-square tests
for i = 1:numEvents
    event = primaryEvents{i};
    isEvent = strcmp(filteredTable.primaryEvent, event);

    for g = 1:numGroups
        groupUnits = strcmp(filteredTable.directionSelectivity, selectivityGroups{g});
        nTotal = sum(groupUnits);
        proportions(i, g) = sum(isEvent & groupUnits) / max(nTotal, 1);
    end

    for g1 = 1:numGroups-1
        for g2 = g1+1:numGroups
            grp1 = strcmp(filteredTable.directionSelectivity, selectivityGroups{g1});
            grp2 = strcmp(filteredTable.directionSelectivity, selectivityGroups{g2});

            count = [sum(isEvent & grp1), sum(~isEvent & grp1);
                     sum(isEvent & grp2), sum(~isEvent & grp2)];
            [~, p] = chi2test(count);
            pMatrix{i, g1, g2} = p;
        end
    end
end

% Plot
figure('Color', 'w', 'Position', [100 100 1100 500]);
hold on;
b = bar(proportions, 'grouped');

for g = 1:numGroups
    b(g).FaceColor = colors(g, :);
    b(g).DisplayName = selectivityGroups{g};
end

% Avoid clutter in legend
legend(b, 'Location', 'Best');

set(gca, 'XTickLabel', primaryEvents, 'XTickLabelRotation', 45, 'FontSize', 12);
ylabel('Proportion of Units');
title(['Primary Event Proportion by Directional Selectivity - ' strrep(behaviorField, '_', ' ')]);

% Significance brackets
groupWidth = min(0.8, numGroups/(numGroups + 1.5));
for i = 1:numEvents
    yBase = max(proportions(i, :), [], 'omitnan') + 0.02;
    heightStep = 0.05;
    sigCount = 0;

    for g1 = 1:numGroups-1
        for g2 = g1+1:numGroups
            p = pMatrix{i, g1, g2};
            if isempty(p), continue; end

            y = yBase + sigCount * heightStep;
            x1 = i - groupWidth/2 + (2*(g1)-1)*groupWidth/(2*numGroups);
            x2 = i - groupWidth/2 + (2*(g2)-1)*groupWidth/(2*numGroups);

            % Plot significance bracket (do not include in legend)
            plot([x1 x1 x2 x2], [y y+0.01 y+0.01 y], 'k', 'LineWidth', 1.5, 'HandleVisibility', 'off');

            % Add stars
            if p < 0.001
                sig = '***';
            elseif p < 0.01
                sig = '**';
            elseif p < 0.05
                sig = '*';
            else
                sig = 'n.s.';
            end
            text(mean([x1 x2]), y + 0.012, sig, 'HorizontalAlignment', 'center', ...
                'FontSize', 14, 'FontWeight', 'bold', 'HandleVisibility', 'off');
            sigCount = sigCount + 1;
        end
    end
end

yMax = max(proportions(:), [], 'omitnan');
if isempty(yMax) || isnan(yMax)
    ylim([0, 1]);
else
    ylim([0, min(1, yMax + 0.2)]);
end
% Save figure
safeBehaviorField = regexprep(behaviorField, '[^\w]', '_');
outFile = fullfile(parentDir, ['PrimaryEventBySelectivity_' safeBehaviorField '.png']);
saveas(gcf, outFile);
close;
end

% Chi-square helper
function [h, p, stats] = chi2test(tbl)
    rowSums = sum(tbl, 2);
    colSums = sum(tbl, 1);
    total = sum(tbl(:));
    expected = (rowSums * colSums) / total;
    chi2stat = sum((tbl - expected).^2 ./ expected, 'all');
    df = (size(tbl,1)-1)*(size(tbl,2)-1);
    p = 1 - chi2cdf(chi2stat, df);
    h = p < 0.05;
    stats.chi2stat = chi2stat;
    stats.df = df;
    stats.expected = expected;
end