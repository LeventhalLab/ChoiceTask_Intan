%% Parameters
parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
ROIs = {'VM','cbRecipientsBroad'};
plotType = 'violin'; % 'box' or 'violin'
nShuffles = 10000;   % number of shuffles for shuffle test

for roi = 1:length(ROIs)
    region = ROIs{roi};
    regionPath = fullfile(parentDir, region);
    regionFile = strcat(region,'_unitSummary_spikesWbehavioralTS.mat');
    fprintf('loading region')
    load(fullfile(regionPath, regionFile));

    if exist('combinedRegions','var')
        regionUnits = combinedRegions.allUnits;
    end

    fields = fieldnames(regionUnits);

    meanFR_control = [];
    meanFR_lesion = [];

    % -----------------------------
    % Aggregate mean firing rates
    for u = 1:length(fields)
        uid = fields{u};
        if contains(uid,'previouslyCurated')
            continue
        end
        unit = regionUnits.(uid);

        % Check for valid meanFR
        if ~isfield(unit.unitMetrics, 'meanFiringRate') || isempty(unit.unitMetrics.meanFiringRate)
            continue;
        end

        fr = unit.unitMetrics.meanFiringRate;
        trt = unit.unitMetrics.treatement;
        if isnan(fr)
            continue
        end
        % Aggregate by treatment
        switch lower(trt)
            case 'control'
                meanFR_control(end+1) = fr;
            case 'lesion'
                meanFR_lesion(end+1) = fr;
        end
    end

    allFR = [meanFR_control, meanFR_lesion];
    groups = [repmat({'Control'},1,length(meanFR_control)), ...
              repmat({'Lesion'},1,length(meanFR_lesion))];

    % -----------------------------
    % Plot
    figure; hold on;
    switch lower(plotType)
        case 'box'
            boxplot(allFR, groups, 'Colors', [0 0 1; 1 0 0], 'Symbol', '');
            ylabel('Mean Firing Rate (Hz)');
            title(sprintf('ROI: %s | Mean Firing Rate by Treatment', region));
        case 'violin'
            v = violinplot(allFR, groups);
            ylim([0, max(allFR)*1.5]);  % little extra space above
            ylabel('Mean Firing Rate (Hz)');
            title(sprintf('ROI: %s | Mean Firing Rate by Treatment', region));
    end

    % Overlay mean ± std for both groups
    for g = 1:2
        if g == 1
            grpData = meanFR_control;
        else
            grpData = meanFR_lesion;
        end
        m = mean(grpData);
        s = std(grpData);
        errorbar(g, m, s, 'k', 'LineWidth', 1.5);
    end

    % -----------------------------
    % Shuffle test for significance
    [p_shuffle, observedDiff] = shuffleTestFR(meanFR_control, meanFR_lesion, nShuffles);

    % Display significance
    yMax = max(allFR) + 0.1*range(allFR);
    if p_shuffle < 0.001
        stars = '***';
    elseif p_shuffle < 0.01
        stars = '**';
    elseif p_shuffle <= 0.05
        stars = '*';
    else
        stars = 'n.s.';
    end
    text(1.5, yMax, stars, 'HorizontalAlignment', 'center', 'FontSize', 14);
     saveas(gcf, fullfile(regionPath, sprintf('%s_meanFR_%s.png', region, plotType)));

    %fprintf('ROI %s: Observed difference=%.2f, p_shuffle=%.4f\n', region, observedDiff, p_shuffle);
end
