function plotDualEventTraces(eventHeatMapsControl, eventHeatMapsLesion, params)
%% Plot mean ± SEM z-scored traces for all events, dual-treatment
% eventHeatMapsControl / Lesion: structs with fields like cueOn, centerIn, etc.
% params.timeWindow = [-0.9 0.9] (subset window)
% params.smoothWindow = 3 (moving average points)

if ~isfield(params,'timeWindow'); params.timeWindow = [-0.9 0.9]; end
if ~isfield(params,'smoothWindow'); params.smoothWindow = 3; end

eventNames = fieldnames(eventHeatMapsControl);
nEvents = length(eventNames);

% Original time vector
fullTime = linspace(-1,1,101);

% Indices for cropped window
idx = fullTime >= params.timeWindow(1) & fullTime <= params.timeWindow(2);
timeBins = fullTime(idx);

% Define colors
controlColor = [0 0 0.5];  % navy blue
lesionColor  = [1 0.5 0];  % orange

fig = figure('Name','Dual Treatment Event Traces','Units','inches','Position',[1 1 14 6]);
tiledlayout(1,nEvents,'TileSpacing','Tight','Padding','None');
sgtitle(sprintf('Mean ± SEM Z-score Traces | %s', strrep(params.behaviorField,'_',' ')),'FontSize',12);

for e = 1:nEvents
    evt = eventNames{e};
    ax = nexttile;

    % --- Crop & smooth data ---
    dataC = movmean(eventHeatMapsControl.(evt)(:, idx), params.smoothWindow, 2);
    dataL = movmean(eventHeatMapsLesion.(evt)(:, idx), params.smoothWindow, 2);

    % --- Compute mean & SEM ---
    muC  = nanmean(dataC,1); semC  = nanstd(dataC,[],1)/sqrt(size(dataC,1));
    muL  = nanmean(dataL,1); semL  = nanstd(dataL,[],1)/sqrt(size(dataL,1));

    hold(ax,'on')
    % SEM shading
    fill([timeBins fliplr(timeBins)], [muC-semC fliplr(muC+semC)], controlColor, 'FaceAlpha',0.3,'EdgeColor','none');
    fill([timeBins fliplr(timeBins)], [muL-semL fliplr(muL+semL)], lesionColor, 'FaceAlpha',0.3,'EdgeColor','none');

    % Plot mean traces
    plot(timeBins, muC, 'Color', controlColor, 'LineWidth', 2);
    plot(timeBins, muL, 'Color', lesionColor, 'LineWidth', 2);

    % --- Axis labels and grid logic ---
    if e == 1
        xlabel(ax, 'Time (s)','FontSize',14);
        ylabel(ax, 'Mean Z-Scored (Hz)','FontSize',14);
    else
        % Hide x and y tick labels but keep gridlines
        ax.XTickLabel = [];
        ax.YTickLabel = [];
    end
    ax.FontSize=18;
    title(evt,'Interpreter','none');
    grid(ax,'on'); 
    axis tight;
    ylim([-1 1]);
end

% === Save figure as PNG ===
if ~exist(params.regionSummaryPath, 'dir')
    mkdir(params.regionSummaryPath);
end
saveFile = fullfile(params.regionSummaryPath, 'MeanTrace_ControlVsLesion.png');
saveas(fig, saveFile);

end
