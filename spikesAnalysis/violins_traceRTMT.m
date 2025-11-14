%% Script to compile all of the rat reaction and movement time data 

parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls_dir = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);
sessions_to_ignore = {'R0378_20210507a','R0326_20191107a','R0425_20220728a','R0425_20220816b','R0427_20220920a', ...
                      'R0427_20220919a','R0479_20230601a'};

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);

ratIDs = probe_types.ratID;
ignoreRats = {'R0326','R0327','R0372','R0374','R0379','R0376','R0378','R0394','R0395','R0396', ...
              'R0411','R0412','R0413','R0419','R0425','R0427','R0456','R0459'};

num_rats = length(ratIDs);

behaviorData = {};
behaviorData.lesionRats = [];
behaviorData.controlRats = [];

ratRTMTdata = [];
compileData = 0;
plotData = 1;
probabilityNormalization = 1;
n_shuffles = 10000;

if compileData
    for i_rat = 1:num_rats
        
        ratID = ratIDs{i_rat};
        rat_folder = fullfile(parent_directory, ratID);

        if any(strcmp(ratID, ignoreRats)) || ~isfolder(rat_folder)
            continue
        end
        
        ratTreatment = probe_types.Treatment{i_rat};
        rawdata_folder = find_data_folder(ratID, 'rawdata', parent_directory);
        session_dirs = dir(fullfile(rawdata_folder, strcat(ratID, '*')));

        saveFolder = strcat(ratID,'-behaviorData');
        savePath = fullfile(rat_folder,saveFolder);
        if ~exist(savePath,'dir')
            mkdir(savePath)
        end
        
        saveFile = fullfile(savePath,[ratID '_behaviorDataSummary.mat']);
        
        ratRTMTdata = [];
        num_sessions = length(session_dirs);

        for i_session = 1:num_sessions

            sessionName = session_dirs(i_session).name;
            cur_dir = fullfile(session_dirs(i_session).folder, sessionName);

            if any(strcmp(sessionName, sessions_to_ignore))
                continue
            end

            phys_folder = find_physiology_data(cur_dir);
            if isempty(phys_folder) || ...
               ~isfolder(fullfile(phys_folder,'kilosort4')) || ...
               ~exist(fullfile(phys_folder,'kilosort4','params.py'))
                continue
            end

            sessionSummary = Compile_choiceRTlogDataDaily(ratID,sessionName,cur_dir);
            ratRTMTdata.sessions.(sessionName).sessionSummary = sessionSummary;
        end

        allRatRT = [];
        allRatMT = [];
        allIpsiRT = [];
        allIpsiMT = [];
        allContraRT = [];
        allContraMT = [];
        allRatRTMT = [];
        allIpsiRTMT = [];
        allContraRTMT = [];
        accuracyIpsi = [];
        accuracyContra = [];
        allAccuracy = [];

        seshs = fieldnames(ratRTMTdata.sessions);
        for s = 1:length(seshs)
            session = seshs{s};

            allRatRT     = [allRatRT;     ratRTMTdata.sessions.(session).sessionSummary.allRT];
            allRatMT     = [allRatMT;     ratRTMTdata.sessions.(session).sessionSummary.allMT];
            allIpsiRT    = [allIpsiRT;    ratRTMTdata.sessions.(session).sessionSummary.ipsiRT];
            allIpsiMT    = [allIpsiMT;    ratRTMTdata.sessions.(session).sessionSummary.ipsiMT];
            allContraRT  = [allContraRT;  ratRTMTdata.sessions.(session).sessionSummary.contraRT];
            allContraMT  = [allContraMT;  ratRTMTdata.sessions.(session).sessionSummary.contraMT];
            allRatRTMT   = [allRatRTMT;   ratRTMTdata.sessions.(session).sessionSummary.allRTMT];
            allIpsiRTMT  = [allIpsiRTMT;  ratRTMTdata.sessions.(session).sessionSummary.ipsiRTMT];
            allContraRTMT= [allContraRTMT;ratRTMTdata.sessions.(session).sessionSummary.contraRTMT];

            accuracyIpsi   = [accuracyIpsi;   ratRTMTdata.sessions.(session).sessionSummary.acc(1)];
            accuracyContra = [accuracyContra; ratRTMTdata.sessions.(session).sessionSummary.acc(2)];
            allAccuracy    = [allAccuracy;    ratRTMTdata.sessions.(session).sessionSummary.acc(3)];
        end

        ratRTMTdata.allRatRT = allRatRT;
        ratRTMTdata.allRatMT = allRatMT;
        ratRTMTdata.allIpsiRT = allIpsiRT;
        ratRTMTdata.allIpsiMT = allIpsiMT;
        ratRTMTdata.allContraRT = allContraRT;
        ratRTMTdata.allContraMT = allContraMT;
        ratRTMTdata.allRatRTMT = allRatRTMT;
        ratRTMTdata.allIpsiRTMT = allIpsiRTMT;
        ratRTMTdata.allContraRTMT = allContraRTMT;
        ratRTMTdata.accuracyIpsi = accuracyIpsi;
        ratRTMTdata.accuracyContra = accuracyContra;
        ratRTMTdata.allAccuracy = allAccuracy;
        ratRTMTdata.treatement = ratTreatment;

        fprintf('Saving summary mat file for %s\n', ratID)
        save(saveFile,'ratRTMTdata','-v7.3','-mat')

        if strcmp(ratTreatment,'control')
            behaviorData.controlRats.(ratID) = ratRTMTdata;
            fields = {'allRatRT','allRatMT','allIpsiRT','allIpsiMT','allContraRT','allContraMT','allRatRTMT', ...
                      'allIpsiRTMT','allContraRTMT','accuracyIpsi','accuracyContra','allAccuracy'};
            
            if ~isfield(behaviorData.controlRats,'allRatRT')
                for f = fields
                    behaviorData.controlRats.(f{1}) = [];
                end
            end
            
            for f = fields
                behaviorData.controlRats.(f{1}) = ...
                    [behaviorData.controlRats.(f{1}); ratRTMTdata.(f{1})];
            end

        else
            behaviorData.lesionRats.(ratID) = ratRTMTdata;
            fields = {'allRatRT','allRatMT','allIpsiRT','allIpsiMT','allContraRT','allContraMT','allRatRTMT', ...
                      'allIpsiRTMT','allContraRTMT','accuracyIpsi','accuracyContra','allAccuracy'};
            
            if ~isfield(behaviorData.lesionRats,'allRatRT')
                for f = fields
                    behaviorData.lesionRats.(f{1}) = [];
                end
            end
            
            for f = fields
                behaviorData.lesionRats.(f{1}) = ...
                    [behaviorData.lesionRats.(f{1}); ratRTMTdata.(f{1})];
            end
        end
        
        clearvars ratRTMTdata saveFile
    end

    saveBehaviorData = fullfile(parent_directory,'Behavior_RtMtData');
    saveBeahvioralFile = fullfile(saveBehaviorData,'behaviorDataSummary.mat');
    save(saveBeahvioralFile,'behaviorData','-v7.3','-mat');

else
    saveBehaviorData = fullfile(parent_directory,'Behavior_RtMtData');
    saveBeahvioralFile = fullfile(saveBehaviorData,'behaviorDataSummary.mat');
    load(saveBeahvioralFile)
end


%% ============================
%   PLOTTING SECTION
% ============================

if plotData

plotVars = {'allRatRT','allRatMT','allIpsiRT','allIpsiMT','allContraRT','allContraMT', ...
            'allRatRTMT','allIpsiRTMT','allContraRTMT'};

histFolder = fullfile(saveBehaviorData,'Histograms');
if ~exist(histFolder,'dir')
    mkdir(histFolder);
end

for iVar = 1:length(plotVars)
    varName = plotVars{iVar};

    if ~isfield(behaviorData.controlRats,varName) || ~isfield(behaviorData.lesionRats,varName)
        fprintf('Skipping %s (missing field)\n',varName);
        continue
    end

    controlData = behaviorData.controlRats.(varName);
    lesionData  = behaviorData.lesionRats.(varName);

    controlData = controlData(~isnan(controlData));
    lesionData  = lesionData(~isnan(lesionData));

    [p_value, shuffle_diffs] = meanDifference_shuffleTest(controlData, lesionData, n_shuffles);

    %% --- (1) TRACE HISTOGRAM USING KSDENSITY ---
    figHist = figure('Visible','on','Position',[100 100 800 600]);
    hold on;

    [f_ctrl, x_ctrl] = ksdensity(controlData,'NumPoints',200);
    [f_les,  x_les]  = ksdensity(lesionData,'NumPoints',200);

    plot(x_ctrl,f_ctrl,'LineWidth',2,'Color',[0 0.447 0.741]);
    plot(x_les, f_les, 'LineWidth',2,'Color',[0.85 0.325 0.098]);

    ylabel('Probability Density');
    newVarName=strrep(varName,'_',' ');
    xlabel('Time (s)','Interpreter','none');
    title(sprintf('Lesion vs Control: %s', strrep(varName,'_',' ')),'Interpreter','none');
    legend({'Control','Lesion'}, 'Location','best');
    grid on; box off;
    ylim padded
    xlim([0 0.5])

    if p_value < 0.001
        starText = '***';
    elseif p_value < 0.01
        starText = '**';
    elseif p_value < 0.05
        starText = '*';
    else
        starText = 'n.s.';
    end
    ylim([0 (max([f_ctrl f_les])*1.5)])
    yStar = max([f_ctrl f_les]) * 1.1;
    text(mean(xlim), yStar, sprintf('%s (p = %.3g)', starText, p_value), ...
        'HorizontalAlignment','center','FontSize',14,'FontWeight','bold');

    saveas(figHist, fullfile(histFolder, sprintf('TraceHistogram_%s.png',varName)));
    close(figHist);


    %% --- (2) VIOLIN PLOT ---
    figViolin = figure('Visible','on','Position',[100 100 600 500]);

    dataCombined = [controlData; lesionData];
    groupLabels = [repmat({'Control'}, length(controlData),1); repmat({'Lesion'}, length(lesionData),1)];

    v = violinplot(dataCombined, groupLabels);

    title(sprintf('Reaction/Movement: %s', strrep(varName,'_',' ')),'Interpreter','none');
    ylabel('Time (s)');
    grid on; box off;

    v(1).ViolinColor = {[0 0.447 0.741]};
    v(2).ViolinColor = {[0.85 0.325 0.098]};

    hold on;
    scatter(1 + randn(size(controlData))*0.02, controlData, ...
            0.5, [0 0.447 0.741],'filled','MarkerFaceAlpha',0.6);
    scatter(2 + randn(size(lesionData))*0.02, lesionData, ...
            0.5, [0.85 0.325 0.098],'filled','MarkerFaceAlpha',0.6);

    yStar = max(dataCombined) * 1.05;
    text(1.5, yStar, starText, 'HorizontalAlignment','center', ...
        'FontSize',14,'FontWeight','bold');

    saveas(figViolin, fullfile(histFolder,sprintf('Violin_%s.png',varName)));
    close(figViolin);

end

disp(['Saved histograms + violin plots to: ' histFolder]);
end

disp('Done!')
