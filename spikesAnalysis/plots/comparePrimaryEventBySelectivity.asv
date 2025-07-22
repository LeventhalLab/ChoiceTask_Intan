function comparePrimaryEventBySelectivity(unitTable, parentDir, behaviorField,params)
% Compare fraction of units by direction selectivity (ipsilateral vs contralateral)
% for a specific behaviorField and plot bar graph with significance.

% Filter table by behavior
filteredTable = unitTable(strcmp(unitTable.behavior, behaviorField), :);
if isfield(params,'compareSelectivity')
    direction1=params.compareSelectivity{1}
    direction2=params.compareSelectivity{2}
% Only keep directionally selective units
isDirectional = strcmp(filteredTable.directionSelectivity, 'ipsilateral') | ...
                strcmp(filteredTable.directionSelectivity, 'contralateral');
filteredTable = filteredTable(isDirectional, :);

% Unique primary events for filtered units
primaryEvents = unique(filteredTable.primaryEvent, 'stable');

% Initialize results
contralateralColor = [0 0.4470 0.7410];
ipsilateralColor = [0.8500 0.3250 0.0980];

proportions = zeros(length(primaryEvents), 2); % col 1: contralateral, col 2: ipsilateral
pValues = nan(length(primaryEvents), 1);

for i = 1:length(primaryEvents)
    event = primaryEvents{i};
    
    % Filter for event presence
    isEvent = strcmp(filteredTable.primaryEvent, event);
    
    % Counts for contralateral and ipsilateral units that have this event
    contralateralUnits = strcmp(filteredTable.directionSelectivity, 'contralateral');
    ipsilateralUnits = strcmp(filteredTable.directionSelectivity, 'ipsilateral');
    
    nContralateral = sum(contralateralUnits);
    nIpsilateral = sum(ipsilateralUnits);
    
    % Fraction with event for each group
    fracContralateral = sum(isEvent & contralateralUnits) / nContralateral;
    fracIpsilateral = sum(isEvent & ipsilateralUnits) / nIpsilateral;
    
    proportions(i, :) = [fracContralateral, fracIpsilateral];
    
    % Build contingency table for chi-square test:
    % Rows: contralateral / ipsilateral
    % Cols: has event / does not have event
    counts = [
        sum(isEvent & contralateralUnits), nContralateral - sum(isEvent & contralateralUnits);
        sum(isEvent & ipsilateralUnits), nIpsilateral - sum(isEvent & ipsilateralUnits);
    ];
    
    % Run chi-square test of independence
    [~, p] = chi2test(counts);
    pValues(i) = p;
end

% Plot
figure('Color', 'w', 'Position', [100 100 900 500]);
hold on;
b = bar(proportions, 'grouped');
b(1).FaceColor = contralateralColor;
b(2).FaceColor = ipsilateralColor;

set(gca, 'XTickLabel', primaryEvents, 'XTickLabelRotation', 45, 'FontSize', 12);
ylabel('Proportion of Units');
title(['Primary Event Proportion by Directional Selectivity - Behavior: ' strrep(behaviorField, '_', ' ')]);
legend({'Contralateral', 'Ipsilateral'}, 'Location', 'Best');

% Add significance stars
for i = 1:length(primaryEvents)
    y = max(proportions(i, :)) + 0.05;
    if pValues(i) < 0.001
        sig = '***';
    elseif pValues(i) < 0.01
        sig = '**';
    elseif pValues(i) < 0.05
        sig = '*';
    else
        sig = 'n.s.';
    end
    text(i, y, sig, 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold');
end
ylim([0, min(1, max(proportions(:)) + 0.15)]);

% Save figure
safeBehaviorField = regexprep(behaviorField, '[^\w]', '_');
outFile = fullfile(parentDir, ['PrimaryEventBySelectivity_' safeBehaviorField '.png']);
saveas(gcf, outFile);

end

% Include chi2test function below or as separate file

function [h, p, stats] = chi2test(tbl)
    % Simple chi-square test of independence for 2x2 contingency table
    rowSums = sum(tbl,2);
    colSums = sum(tbl,1);
    total = sum(tbl(:));
    expected = (rowSums * colSums) / total;
    chi2stat = sum(sum((tbl - expected).^2 ./ expected));
    df = 1; % (2-1)*(2-1)
    p = 1 - chi2cdf(chi2stat, df);
    h = p < 0.05;
    stats.chi2stat = chi2stat;
    stats.df = df;
    stats.expected = expected;
end