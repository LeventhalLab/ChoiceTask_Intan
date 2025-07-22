function results = comparePrimaryEventProportions(unitTable, behaviorField)
% Compare proportions of primary events across treatments using Chi-squared test of independence

% Filter by behaviorField
tbl = unitTable(strcmp(unitTable.behavior, behaviorField), :);

% Get unique primary events
primaryEvents = unique(tbl.primaryEvent);
results = struct();

for i = 1:length(primaryEvents)
    pe = primaryEvents{i};
    
    % Get counts per treatment
    controlCount = sum(strcmp(tbl.primaryEvent, pe) & strcmp(tbl.treatment, 'control'));
    lesionCount  = sum(strcmp(tbl.primaryEvent, pe) & strcmp(tbl.treatment, 'lesion'));
    
    totalControl = sum(strcmp(tbl.treatment, 'control'));
    totalLesion  = sum(strcmp(tbl.treatment, 'lesion'));

    % Create 2x2 contingency table: rows=treatment, cols=presence/absence of this primary event
    contingency = [
        controlCount, totalControl - controlCount;
        lesionCount,  totalLesion  - lesionCount
    ];

    % Perform chi-squared test of independence
    [~, pval, stats] = chi2Test(contingency);

    results.(pe).p = pval;
    results.(pe).chi2 = stats.chi2;
    results.(pe).df = stats.df;
    results.(pe).n = stats.n;
end
end

function [h, p, stats] = chi2Test(contingency)
% Manual chi2 independence test for 2x2 table
n = sum(contingency(:));
rowSums = sum(contingency, 2);
colSums = sum(contingency, 1);
expected = (rowSums * colSums) / n;

chi2 = sum((contingency - expected).^2 ./ expected, 'all');
df = (size(contingency,1)-1)*(size(contingency,2)-1);
p = 1 - chi2cdf(chi2, df);
h = p < 0.05;

stats.chi2 = chi2;
stats.df = df;
stats.n = n;
end