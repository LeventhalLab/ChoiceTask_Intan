function comparePrimaryEventTwoRegions(allUnits, behaviorField, eventName, treatment, regionA, regionB)
% Compare primary event proportions between two specified regions with permutation test

% Filter units for behavior and treatment
validUnits = allUnits(~strcmp(allUnits.treatment, treatment) & ...
                      strcmp(allUnits.behavior, behaviorField), :);

% Extract units for the two regions
unitsA = validUnits(strcmp(validUnits.region, regionA), :);
unitsB = validUnits(strcmp(validUnits.region, regionB), :);

% Compute primary event proportions
propA = sum(strcmp(unitsA.primaryEvent, eventName)) / height(unitsA);
propB = sum(strcmp(unitsB.primaryEvent, eventName)) / height(unitsB);

% ---- PLOT ----
figure('Color','w','Position',[100 100 600 500]);
hold on;
b = bar([propA, propB], 'FaceColor', [0 0.4470 0.7410]); % blue for primary
set(gca, 'XTick', 1:2, 'XTickLabel', {regionA, regionB}, 'FontSize', 12);
ylabel('Proportion of Units');
ylim([0 1]);
title([eventName ' Primary Event Proportions - ' strrep(behaviorField,'_',' ')]);

% ---- Permutation test ----
nShuffles = 10000;
vecA = strcmp(unitsA.primaryEvent, eventName);
vecB = strcmp(unitsB.primaryEvent, eventName);
p = permutationTestProportion(vecA, vecB, nShuffles);

% ---- Plot significance bracket ----
yMax = max([propA, propB]);
plot([1 1 2 2], [yMax+0.05 yMax+0.1 yMax+0.1 yMax+0.05], 'k', 'LineWidth', 1.2);

% Stars
stars = getStars(p);
text(1.5, yMax+0.12, stars, 'HorizontalAlignment','center', ...
     'FontSize', 14, 'FontWeight','bold', 'Color', [0 0.4470 0.7410]);

hold off;

end

%% --- Helper Functions ---
function p = permutationTestProportion(vec1, vec2, nShuffles)
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
    p = max(p, 1/nShuffles);
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
