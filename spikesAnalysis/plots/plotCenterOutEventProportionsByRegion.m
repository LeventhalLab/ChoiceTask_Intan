function plotCenterOutEventProportionsByRegion(allUnits, behaviorField)
% Plots proportions of 'centerOut' events by region and adds significance brackets
% Uses permutation (shuffle) test for pairwise comparisons

% Filter units
validUnits = allUnits(~strcmp(allUnits.treatment, 'lesion')  & ...
                      strcmp(allUnits.behavior, behaviorField), :);
validUnits= validUnits(~strcmp(validUnits.region,'OtherRegions'), :);

regions = unique(validUnits.region, 'stable');
nRegions = numel(regions);

% Initialize arrays
primaryCenterOutProportions = nan(nRegions, 1);
secondaryCenterOutProportions = nan(nRegions, 1);

for i = 1:nRegions
    region = regions{i};
    regionUnits = validUnits(strcmp(validUnits.region, region), :);
    nUnits = height(regionUnits);
    if nUnits > 0
        primaryCenterOutProportions(i)   = sum(strcmp(regionUnits.primaryEvent, 'centerOut')) / nUnits;
        secondaryCenterOutProportions(i) = sum(strcmp(regionUnits.secondaryEvent, 'centerOut')) / nUnits;
    end
end

% ---- PLOT ----
figure('Color', 'w', 'Position', [100 100 1100 600]);
hold on;

barData = [primaryCenterOutProportions, secondaryCenterOutProportions];
b = bar(barData, 'grouped');
b(1).FaceColor = [0 0.4470 0.7410];    % Blue (Primary)
b(2).FaceColor = [0.8500 0.3250 0.0980]; % Orange (Secondary)

set(gca, 'XTick', 1:nRegions, 'XTickLabel', regions, ...
    'XTickLabelRotation', 45, 'FontSize', 12);
ylabel('Proportion of Units');
ylim([0 0.5]); % fixed y-axis
title(['CenterOut Event Proportions by Region - ' strrep(behaviorField, '_', ' ')]); 
legend({'Primary', 'Secondary'}, 'Location', 'bestoutside');

% ---- SIGNIFICANCE TESTING (Permutation) ----
yOffset = 0.05; % vertical spacing for brackets
nShuffles = 10000; % number of permutations

% Define comparisons (pairwise across regions)
combos = nchoosek(1:nRegions, 2);

for iComp = 1:size(combos,1)
    iA = combos(iComp,1);
    iB = combos(iComp,2);

    % Extract 0/1 vectors for 'centerOut'
    primA = strcmp(validUnits.primaryEvent(strcmp(validUnits.region, regions{iA})), 'centerOut');
    primB = strcmp(validUnits.primaryEvent(strcmp(validUnits.region, regions{iB})), 'centerOut');
    secA  = strcmp(validUnits.secondaryEvent(strcmp(validUnits.region, regions{iA})), 'centerOut');
    secB  = strcmp(validUnits.secondaryEvent(strcmp(validUnits.region, regions{iB})), 'centerOut');

    % --- Permutation test function ---
    p_primary = permutationTestProportion(primA, primB, nShuffles);
    p_secondary = permutationTestProportion(secA, secB, nShuffles);

    % --- Plot Primary Event significance ---
    xA = iA - 0.15; % offset for blue bar
    xB = iB - 0.15;
    y = max([barData(iA,1), barData(iB,1)]) + iComp*yOffset;
    plot([xA xA xB xB], [y-yOffset/2 y y y-yOffset/2], 'k', 'LineWidth', 1.2);

    stars = getStars(p_primary);
    text(mean([xA xB]), y + 0.01, stars, 'HorizontalAlignment','center', ...
         'FontSize', 12, 'FontWeight','bold', 'Color', [0 0.447 0.741]);

    % --- Plot Secondary Event significance ---
    xA2 = iA + 0.15; % offset for orange bar
    xB2 = iB + 0.15;
    y2 = max([barData(iA,2), barData(iB,2)]) + iComp*yOffset;
    plot([xA2 xA2 xB2 xB2], [y2-yOffset/2 y2 y2 y2-yOffset/2], 'k', 'LineWidth', 1.2);

    stars = getStars(p_secondary);
    text(mean([xA2 xB2]), y2 + 0.01, stars, 'HorizontalAlignment','center', ...
         'FontSize', 12, 'FontWeight','bold', 'Color', [0.850 0.325 0.098]);
end

hold off;
end

%% --- Helper Functions ---

function p = permutationTestProportion(vec1, vec2, nShuffles)
% vec1, vec2: logical vectors 0/1 for event occurrence
% Returns p-value from permutation test
    allData = [vec1; vec2];
    n1 = numel(vec1);
    obsDiff = mean(vec1) - mean(vec2);
    shuffleDiffs = zeros(nShuffles,1);
    for i = 1:nShuffles
        permIdx = randperm(numel(allData));
        shuffled = allData(permIdx);
        shuffleDiffs(i) = mean(shuffled(1:n1)) - mean(shuffled(n1+1:end));
    end
    p = mean(abs(shuffleDiffs) >= abs(obsDiff));
    p = max(p, 1/nShuffles); % avoid p=0
end

function stars = getStars(p)
    if p < 0.001
        stars = '***';
    elseif p < 0.01
        stars = '**';
    elseif p < 0.05
        stars = '*';
    else
        stars = 'n.s.';
    end
end
