function eventTracePlotting(regionUnits, params)

behaviorField = params.behaviorField;
eventNames = params.potentialeventNames;
region = params.region;

treatments = {'control','lesion'};

timeBins = linspace(-1,1,101);

% Collect unitIDs belonging to each treatment
allIDs = fields(regionUnits);

controlIDs = {};
lesionIDs  = {};

for i = 1:length(allIDs)
    uid = allIDs{i};
    if ~startsWith(uid,'R'), continue; end
    if ~isfield(regionUnits.(uid),'unitMetrics'), continue; end

    unit = regionUnits.(uid).unitMetrics;

    % treatment field might be spelled differently
    if isfield(unit,'treatment')
        tr = unit.treatment;
    elseif isfield(unit,'treatement')
        tr = unit.treatement;
    else
        continue
    end

    switch tr
        case 'control'
            controlIDs{end+1} = uid;
        case 'lesion'
            lesionIDs{end+1}  = uid;
    end
end

% Prepare figure
figure('Name',['Event Mean Traces | Region: ' region], ...
       'Color','w','Position',[200 200 1200 300]);

t = tiledlayout(1,length(eventNames));
sgtitle(t, sprintf('Mean ± SEM | Behavior = %s | Region = %s', ...
    behaviorField, region), 'FontSize', 14);

colors.control = [0 0.447 0.741];
colors.lesion  = [0.85 0.325 0.098];


for e = 1:length(eventNames)
    ev = eventNames{e};

    % Collect data for each group
    controlMat = collectEventTraces(regionUnits, controlIDs, behaviorField, ev);
    lesionMat  = collectEventTraces(regionUnits, lesionIDs,  behaviorField, ev);

    % Smooth like Python example (optional)
    controlMatSmooth = smoothTraces(controlMat);
    lesionMatSmooth  = smoothTraces(lesionMat);

    % Compute mean + SEM
    [meanC, semC] = meanSEM(controlMatSmooth);
    [meanL, semL] = meanSEM(lesionMatSmooth);

    nexttile
    hold on

    % --- Control Plot ---
    shadedErrorBar(timeBins, meanC, semC, ...
    'lineprops', {'Color', colors.control, 'LineWidth', 2});

    % --- Lesion Plot ---
    shadedErrorBar(timeBins, meanL, semL, ...
    'lineprops', {'Color', colors.lesion, 'LineWidth', 2});

    title(ev,'Interpreter','none')
    xlabel('Time (s)')
    ylabel('Z-scored firing')

    legend({'Control','Lesion'})
    grid on
end

end

%% ----------------------------------------------------------
% Helper: Extract all zscoredHz rows for a group of unitIDs
%% ----------------------------------------------------------
function mat = collectEventTraces(regionUnits, unitIDs, behaviorField, ev)
mat = [];
for i = 1:length(unitIDs)
    uid = unitIDs{i};

    beh = regionUnits.(uid).behavioralFeatures;
    if ~isfield(beh, behaviorField), continue; end

    behStruct = beh.(behaviorField);

    if isfield(behStruct, ev) && isfield(behStruct.(ev),'zscoredHz')
        z = behStruct.(ev).zscoredHz;
        if isequal(size(z), [1 101])
            mat = [mat; z];
        end
    end
end
end

%% ----------------------------------------------------------
% Helper: Smooth every row (Gaussian or MATLAB smooth)
%% ----------------------------------------------------------
function matOut = smoothTraces(matIn)
if isempty(matIn)
    matOut = matIn;
    return
end

matOut = zeros(size(matIn));
for i = 1:size(matIn,1)
    matOut(i,:) = smooth(matIn(i,:), 5, 'loess'); % Adjust window if desired
end
end

%% ----------------------------------------------------------
% Helper: compute mean ± SEM
%% ----------------------------------------------------------
function [m,s] = meanSEM(mat)
if isempty(mat)
    m = nan(1,101);
    s = nan(1,101);
else
    m = mean(mat,1);
    s = std(mat,[],1) ./ sqrt(size(mat,1));
end
end
