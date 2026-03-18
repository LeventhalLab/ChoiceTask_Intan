%% ===== HIGH LEVEL RT/MT SUMMARY PLOTS =====

parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';

allEntries = dir(parentDir);
isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name},{'.','..'});
regionsAvailable = {allEntries(isSubFolder).name};

regionsOfInterest = {'VM','cbRecipientsBroad'};
specifyRegions = 1;
ignoreUndeterminable=1;
ignoreNotDirectionallySelective=0;
ignoreIpsilateral=0;
ignoreContralateral=0;

titleID='exlcudingUndeterminable';

treatments = {'control','lesion'};
corrTypes  = {'RTcorrResults','MTcorrResults'};

for i = 1:length(regionsAvailable)

    region = regionsAvailable{i};

    if specifyRegions && ~any(strcmp(region,regionsOfInterest))
        continue
    end

    fprintf('Loading %s\n',region)

    regionPath = fullfile(parentDir, region);

    plotSaveDir = fullfile(regionPath,'FRvsRTMT_CorrelationPlots');
    if ~exist(plotSaveDir,'dir')
        mkdir(plotSaveDir);
    end

    load(fullfile(regionPath,[region '_unitFRRTMTcorrelations.mat']))
    behaviors = fieldnames(correlations);

    for b = 1:length(behaviors)

        behavior = behaviors{b};
        dataStruct = correlations.(behavior);

        figure('Name',[region ' - ' behavior], ...
               'Units','inches', ...
               'Position',[1 1 11 8.5], ...
               'PaperUnits','inches', ...
               'PaperPosition',[0 0 11 8.5])

        tiledlayout(2,3,'TileSpacing','compact','Padding','compact')

        for c = 1:2  % RT row then MT row

            corrField = corrTypes{c};

            for metricIdx = 1:3

                switch metricIdx
                    case 1
                        metricName = 'beta';
                        yLabelName = 'Slope';
                        yLimitsFixed = [-10 10];   % <<< FIXED
                    case 2
                        metricName = 'r2';
                        yLabelName = 'R^2';
                        yLimitsFixed = [0 0.4];    % <<< FIXED
                    case 3
                        metricName = 'p';
                        yLabelName = 'p';
                        yLimitsFixed = [0 1];      % <<< FIXED
                end

                tileIndex = (c-1)*3 + metricIdx;
                nexttile(tileIndex)
                hold on

                for t = 1:length(treatments)

                    treatment = treatments{t};

                    % ---- Case-insensitive treatment matching ----
                    if ~isfield(dataStruct,treatment)
                        fNames = fieldnames(dataStruct);
                        matchIdx = strcmpi(fNames,treatment);
                        if any(matchIdx)
                            treatmentField = fNames{matchIdx};
                        else
                            continue
                        end
                    else
                        treatmentField = treatment;
                    end

                    all_values = [];
                    binCenters = [];

                    rats = fieldnames(dataStruct.(treatmentField));

                    for rID = 1:length(rats)
                        rat = rats{rID};
                        sessions = fieldnames(dataStruct.(treatmentField).(rat));

                        for s = 1:length(sessions)
                            session = sessions{s};
                            sessionData = dataStruct.(treatmentField).(rat).(session);

                            if isempty(binCenters)
                                binCenters = sessionData.binCenters;
                            end

                            units = fieldnames(sessionData.units);

                            for u = 1:length(units)
                                uid = units{u};
                                if ignoreUndeterminable
                                    if strcmp(sessionData.units.(uid).noseOutResponsiveness, ...
                                            'undeterminable')
                                        fprintf('Ignoring %s\n',uid)
                                        continue
                                    end
                                end
                                if ignoreNotDirectionallySelective
                                    if strcmp(sessionData.units.(uid).noseOutResponsiveness, ...
                                            'NotDirectionallySelective')
                                        continue
                                    else
                                        keyboard
                                    end
                                end
                                if ignoreIpsilateral
                                    if strcmp(sessionData.units.(uid).noseOutResponsiveness, ...
                                            'ipsilateral')
                                        continue
                                    end
                                end
                                if ignoreContralateral
                                    if strcmp(sessionData.units.(uid).noseOutResponsiveness, ...
                                            'contralateral')
                                        continue
                                    end
                                end
                                results = sessionData.units.(uid).(corrField);
                                all_values = [all_values; results.(metricName)];
                            end
                        end
                    end

                    if isempty(all_values)
                        continue
                    end

                    mean_values = nanmean(all_values,1);

                    if strcmpi(treatment,'control')
                        color = [0 0.447 0.741];      % blue
                    else
                        color = [0.850 0.325 0.098];  % orange
                    end

                    plot(binCenters, mean_values, ...
                        'Color',color,'LineWidth',2)
                end

                % ---- Labels ----
                if c == 1
                    rowLabel = 'RT';
                else
                    rowLabel = 'MT';
                end

                title([rowLabel ' - ' yLabelName],'FontWeight','bold')
                xlabel('Time (s)')
                ylabel(yLabelName)

                % ---- FIXED LIMITS ----
                ylim(yLimitsFixed)

                if metricIdx == 1
                    yline(0,'k--')
                end

                xlim([-1 1])
                legend({'Control','Lesion'},'Location','best')
                set(gca,'FontSize',11)

            end
        end

        sgtitle([region ' | ' behavior],'FontSize',14,'FontWeight','bold')

        exportgraphics(gcf, ...
            fullfile(plotSaveDir, ...
            [region '_' behavior '_' titleID '_FRvsRTMT.png']), ...
            'Resolution',300);

        close(gcf)

        fprintf('Saved %s %s\n',region,behavior)

    end
end

fprintf('All regions complete.\n')