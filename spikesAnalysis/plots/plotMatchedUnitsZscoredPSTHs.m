function plotMatchedUnitsZscoredPSTHs(regionUnits, matchingUnitIDs, ratID, matchID, matchBehavior, params, region)
    % ----------------------------
    % Define colors
    lineColors = [
        0, 0.4470, 0.7410;      % Blue
        0.8500, 0.3250, 0.0980; % Orange
        0.6350, 0.0780, 0.1840; % Red
        0.4940, 0.1840, 0.5560; % Purple
        0, 0, 0;                % Black
    ];

    % ----------------------------
    % Get event names for the given behavior
    maxEvents = 0;
    bestUnit = '';
    for m = 1:numel(matchingUnitIDs)
        uid = matchingUnitIDs{m};
        if isfield(regionUnits.(uid).behavioralFeatures, matchBehavior)
            thisEvents = fieldnames(regionUnits.(uid).behavioralFeatures.(matchBehavior));
            if numel(thisEvents) > maxEvents
                maxEvents = numel(thisEvents);
                bestUnit = uid;
            end
        end
    end
    
    if isempty(bestUnit)
        warning('None of the matched units have the behavior "%s". Skipping...', matchBehavior);
        return;
    end

    eventNames = fieldnames(regionUnits.(bestUnit).behavioralFeatures.(matchBehavior));

    % Filter event names to only valid ones
    validEventNames = params.potentialeventNames;
    eventNames = eventNames(ismember(eventNames, validEventNames));
    if isempty(eventNames)
        warning('No valid event names found for %s. Skipping...', matchBehavior);
        return
    end

    % ----------------------------
    % Tiled layout: 1 row, compact spacing
    nEvents = numel(eventNames);
    t = tiledlayout(1, nEvents, 'TileSpacing', 'compact', 'Padding', 'compact');
    title(t, sprintf('Rat %s | MatchedUnitID %s | Behavior: %s', ...
        ratID, num2str(matchID), matchBehavior), ...
        'FontSize', 14, 'FontWeight', 'bold');

    % ----------------------------
    % Precompute short labels for legend (date_Unit_number + trial count)
    shortLabels = cell(size(matchingUnitIDs));
    subtitles = cell(size(matchingUnitIDs));
    for m = 1:numel(matchingUnitIDs)
        parts = strsplit(matchingUnitIDs{m}, '_');
        % Date_Unit_number for legend
        shortLabels{m} = sprintf('%s_%s_%s', parts{2}, parts{3}, parts{4});

        % Number of valid trials based on cueOn timestamps
        if isfield(regionUnits.(matchingUnitIDs{m}).behavioralFeatures.(matchBehavior), 'allEventTimestamps') && ...
           isfield(regionUnits.(matchingUnitIDs{m}).behavioralFeatures.(matchBehavior).allEventTimestamps, 'cueOn') && ...
           ~isempty(regionUnits.(matchingUnitIDs{m}).behavioralFeatures.(matchBehavior).allEventTimestamps.cueOn)
            nTrials = length(regionUnits.(matchingUnitIDs{m}).behavioralFeatures.(matchBehavior).allEventTimestamps.cueOn);
        else
            nTrials = 0;
        end
        shortLabels{m} = sprintf('%s (n=%d)', shortLabels{m}, nTrials);        shortLabels{m} = sprintf('%s (n=%d)', shortLabels{m}, nTrials);
        
        % Subtitle: just Unit number with primary/secondary events
        unitNumber = parts{4};
        if ~isfield(regionUnits.(matchingUnitIDs{m}).unitMetrics.unitClass, matchBehavior)
            primaryEv='NonResponsive';
            secondaryEv='NA';
            subtitles{m} = sprintf('Unit%s: 1=%s 2=%s', unitNumber, primaryEv, secondaryEv);
            continue
        end
        if isfield(regionUnits.(matchingUnitIDs{m}).unitMetrics.unitClass.(matchBehavior),'primaryEvent')
            primaryEv = regionUnits.(matchingUnitIDs{m}).unitMetrics.unitClass.(matchBehavior).primaryEvent;
        else
            primaryEv='NonResponsive';
        end
        if isfield(regionUnits.(matchingUnitIDs{m}).unitMetrics.unitClass.(matchBehavior),'secondaryEvent')
            secondaryEv = regionUnits.(matchingUnitIDs{m}).unitMetrics.unitClass.(matchBehavior).secondaryEvent;
        else
            secondaryEv='NA';
        end
        subtitles{m} = sprintf('Unit%s: 1=%s 2=%s', unitNumber, primaryEv, secondaryEv);
    end
    fullSubtitle = strjoin(subtitles, ' | ');
    if length(matchingUnitIDs)<=2
        fsize=12;
    elseif length(matchingUnitIDs)==3
        fsize=10;
    else
        fsize=8;
    end
    subtitle(t, fullSubtitle, 'Interpreter','None','FontSize',fsize);

    % ----------------------------
    % Loop over each event
    for e = 1:nEvents
        eventName = eventNames{e};
        nexttile;
        hold on;

        for m = 1:numel(matchingUnitIDs)
            uid = matchingUnitIDs{m};
            if ~isfield(regionUnits.(uid).behavioralFeatures.(matchBehavior), eventName)
                % Missing event — debug later if important for now continue 
                continue
            end

            zscoredHz = regionUnits.(uid).behavioralFeatures.(matchBehavior).(eventName).zscoredHz;
            bins = regionUnits.(uid).behavioralFeatures.(matchBehavior).(eventName).bins;

            % 3-point moving average smoothing
            %smoothedHz = movmean(zscoredHz, 3);

            % Choose color (cycle through if more than 5)
            colorIdx = mod(m-1, size(lineColors,1)) + 1;
            plot(bins, zscoredHz, 'Color', lineColors(colorIdx,:), 'LineWidth', 1.2);
        end

        % Axis formatting
        ylim([-5 5]);
        xlim([-1 1]);
        xline(0, 'r--', 'LineWidth', 0.5);

        % Only first subplot shows labels and ticks
        if e == 1
            xlabel('Time (s)');
            ylabel('z-scored firing rate (Hz)');
        else
            set(gca, 'XTickLabel', [], 'YTickLabel', []);
        end

        title(eventName, 'Interpreter', 'none');
        hold off;
    end

    % ----------------------------
    % Add legend above northeast
    legend(shortLabels, 'Interpreter', 'none', 'Location', 'northeastoutside');

    % ----------------------------
    % Save figure
    saveDir = fullfile('X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary', region, ratID, 'MatchedUnits',matchBehavior);
    if ~exist(saveDir, 'dir')
        mkdir(saveDir);
    end
    fileBaseName = sprintf('uid_%s_%s_zscoredPSTHs_overlay', num2str(matchID), matchBehavior);

    % Save as PNG (11x8.5 inches)
    set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 11 2.5]);
    print(gcf, fullfile(saveDir, [fileBaseName '.png']), '-dpng', '-r300');

    % Save as MATLAB figure
    savefig(gcf, fullfile(saveDir, [fileBaseName '.fig']));
end
