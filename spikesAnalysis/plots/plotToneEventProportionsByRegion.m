function plotToneEventProportionsByRegion(allUnits, behaviorField)

% Filter to exclude lesion units and include only desired behavior
validUnits = allUnits(~strcmp(allUnits.treatment, 'lesion') & ...
                      strcmp(allUnits.behavior, behaviorField), :);

% Get list of regions
regions = unique(validUnits.region, 'stable');

% Initialize proportion arrays
primaryToneProportions = zeros(length(regions), 1);
secondaryToneProportions = zeros(length(regions), 1);

for i = 1:length(regions)
    region = regions{i};
    regionUnits = validUnits(strcmp(validUnits.region, region), :);
    
    nUnits = height(regionUnits);
    
    if nUnits > 0
        % Compute proportions
        primaryToneProportions(i) = sum(strcmp(regionUnits.primaryEvent, 'tone')) / nUnits;
        secondaryToneProportions(i) = sum(strcmp(regionUnits.secondaryEvent, 'tone')) / nUnits;
    else
        primaryToneProportions(i) = NaN;
        secondaryToneProportions(i) = NaN;
    end
end

% Plotting
figure('Color', 'w', 'Position', [100 100 1000 500]);
hold on;
barData = [primaryToneProportions, secondaryToneProportions];
b = bar(barData, 'grouped');
b(1).FaceColor = [0 0.4470 0.7410];  % Blue for primary
b(2).FaceColor = [0.8500 0.3250 0.0980];  % Orange for secondary

set(gca, 'XTick', 1:length(regions), 'XTickLabel', regions, 'XTickLabelRotation', 45, 'FontSize', 12);
ylabel('Proportion of Units');
title(['Tone Event Proportions by Region for Behavior: ' strrep(behaviorField, '_', ' ')]);
legend({'Primary Event = Tone', 'Secondary Event = Tone'}, 'Location', 'Best');
ylim([0, 1]);

end