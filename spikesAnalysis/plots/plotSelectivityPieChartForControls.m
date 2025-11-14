function plotSelectivityPieChartForControls(unitTable, params)

    savePath = params.regionSummaryPath;
    region = params.region;

    % Filter for control units only
    controlTable = unitTable(strcmp(unitTable.treatment, 'control'), :);

    % Get unique units based on unitID
    [~, uniqueIdx] = unique(controlTable.unitID);
    uniqueUnits = controlTable(uniqueIdx, :);

    % Extract directionSelectivity labels
    selectivityLabels = uniqueUnits.directionSelectivity;

    % Clean up labels
    if iscell(selectivityLabels)
        selectivityLabels = selectivityLabels(~cellfun(@isempty, selectivityLabels));
    elseif iscategorical(selectivityLabels)
        selectivityLabels = selectivityLabels(~ismissing(selectivityLabels));
    else
        selectivityLabels = selectivityLabels(~isnan(selectivityLabels));
    end

    % Prepare counts based on fixed global label set
    counts = zeros(1, length(params.selectivityLabels));
    for i = 1:length(params.selectivityLabels)
        counts(i) = sum(strcmp(selectivityLabels, params.selectivityLabels{i}));
    end

    % Only keep non-zero slices for plotting
    nonZeroIdx = counts > 0;
    pieCounts = counts(nonZeroIdx);
    pieLabels = arrayfun(@(x) sprintf('%.1f%%', x), pieCounts / sum(pieCounts) * 100, 'UniformOutput', false);
    pieColors = params.selectivityColors(nonZeroIdx, :);
    legendLabels = params.selectivityLabels(nonZeroIdx);

    % Setup axes
    if isfield(params, 'parentAxes')
        ax = params.parentAxes;
        axes(ax);
    else
        figure('Position', [500 400 500 400]);
        ax = gca;
    end

    % Plot pie chart
    h = pie(ax, pieCounts, pieLabels);
    patchHandles = findobj(h, 'Type', 'Patch');
    for i = 1:length(patchHandles)
        set(patchHandles(i), 'FaceColor', pieColors(i, :));
    end

    legend(ax, legendLabels, 'Location', 'eastoutside', 'Interpreter', 'none');
    title(ax, sprintf('%s (n = %d)', 'CB-Recipient', height(uniqueUnits)), 'Interpreter', 'none');

    % Optional save
    if nargin >= 2 && ~isempty(savePath) && ~isfield(params, 'parentAxes')
        saveas(gcf, fullfile(savePath, 'ControlDirectionSelectivityPie.png'));
    end
end