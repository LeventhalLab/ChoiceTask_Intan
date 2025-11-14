%% Script to compile all of the rat reaction and movement time data 


parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls_dir = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);
sessions_to_ignore = {'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a','R0427_20220919a','R0479_20230601a',}; % 'R0493_20230720a' R0425_20220728a debugging because the intan side was left on for 15 hours;


probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER%
% INFORMATION OUT OF THAT SPREADSHEET

%[rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();
ratIDs=probe_types.ratID;
ignoreRats={'R0326','R0327','R0372','R0374','R0379','R0376','R0378','R0394','R0395','R0396','R0411','R0412','R0413','R0419',...
            'R0425','R0427','R0456','R0459'};%,'R0420','R0460','R0463','R0466','R0465','R0467','R0492','R0494','R0495','R0493',''
num_rats = length(ratIDs);

behaviorData={};
behaviorData.lesionRats=[];
behaviorData.controlRats=[];

ratRTMTdata=[];
compileData=0;
plotData=1;
probabilityNormalization=1;
n_shuffles=10000;
if compileData
      for i_rat = 1 : num_rats
            ratID = ratIDs{i_rat};
            
            rat_folder = fullfile(parent_directory, ratID);
            if any(strcmp(ratID,ignoreRats))
                continue
            end
            if ~isfolder(rat_folder)
                continue;
            end
             % Create variable that contains channel-region information
            ratHisto=strcat(ratID,'_','finished');
            ratTreatment=probe_types.Treatment{i_rat};
            
            rawdata_folder = find_data_folder(ratID, 'rawdata', parent_directory);
            session_dirs = dir(fullfile(rawdata_folder, strcat(ratID, '*')));
            num_sessions = length(session_dirs);
            
            saveFolder = strcat(ratID,'-behaviorData');
            savePath=fullfile(rat_folder,saveFolder);
            saveFile = fullfile(savePath, [ratID '_behaviorDataSummary.mat']);
            if ~exist(savePath)
                mkdir(savePath)
            end
            ratRTMTdata=[];
            for i_session = 1 : num_sessions
                
                sessionName = session_dirs(i_session).name;
                
                cur_dir = fullfile(session_dirs(i_session).folder, sessionName);
                cd(cur_dir)
        
                phys_folder = find_physiology_data(cur_dir);
                ephysKilosortPath = fullfile(phys_folder, 'kilosort4');
           
                if isempty(phys_folder)
                    sprintf('no physiology data found for %s', sessionName)
                    continue
                end
                % if ~exist(ephysKilosortPath)
                %     keyboard
                % end
                if any(strcmp(sessionName, sessions_to_ignore)) % Jen added this in to ignore sessions as an attempt to debut "too many input arguments"
                    continue;
                end
                if ~isfolder(fullfile(phys_folder,'kilosort4'))||~exist(fullfile(ephysKilosortPath,'params.py')) 
                    continue
                end
                sessionSummary=Compile_choiceRTlogDataDaily(ratID,sessionName,cur_dir);
                ratRTMTdata.sessions.(sessionName).sessionSummary=sessionSummary;
                
            end
            allRatRT=[];
            allRatMT=[];
            allIpsiRT=[];
            allIpsiMT=[];
            allContraRT=[];
            allContraMT=[];
            allRatRTMT=[];
            allIpsiRTMT=[];
            allContraRTMT=[];
            accuracyIpsi=[];
            accuracyContra=[];
            allAccuracy=[];
            seshs=fieldnames(ratRTMTdata.sessions);
            for s=1:length(seshs)
                session=seshs{s};
                allRatRT=[allRatRT; ratRTMTdata.sessions.(session).sessionSummary.allRT];
                allRatMT=[allRatMT; ratRTMTdata.sessions.(session).sessionSummary.allMT];
                allIpsiRT=[allIpsiRT; ratRTMTdata.sessions.(session).sessionSummary.ipsiRT];
                allIpsiMT=[allIpsiMT; ratRTMTdata.sessions.(session).sessionSummary.ipsiMT];
                allContraRT=[allContraRT; ratRTMTdata.sessions.(session).sessionSummary.contraRT];
                allContraMT=[allContraMT; ratRTMTdata.sessions.(session).sessionSummary.contraMT];
                allRatRTMT=[allContraRT; ratRTMTdata.sessions.(session).sessionSummary.allRTMT];
                allIpsiRTMT=[allIpsiRTMT; ratRTMTdata.sessions.(session).sessionSummary.ipsiRTMT];
                allContraRTMT=[allContraRTMT; ratRTMTdata.sessions.(session).sessionSummary.contraRTMT];
                accuracyIpsi=[accuracyIpsi; ratRTMTdata.sessions.(session).sessionSummary.acc(1)];
                accuracyContra=[accuracyContra; ratRTMTdata.sessions.(session).sessionSummary.acc(2)];
                allAccuracy=[allAccuracy; ratRTMTdata.sessions.(session).sessionSummary.acc(3)];
            end
            ratRTMTdata.allRatRT=allRatRT;
            ratRTMTdata.allRatMT=allRatMT;
            ratRTMTdata.allIpsiRT=allIpsiRT;
            ratRTMTdata.allIpsiMT=allIpsiMT;
            ratRTMTdata.allContraRT=allContraRT;
            ratRTMTdata.allContraMT=allContraMT;
            ratRTMTdata.allRatRTMT=allRatRTMT;
            ratRTMTdata.allIpsiRTMT=allIpsiRTMT;
            ratRTMTdata.allContraRTMT=allContraRTMT;
            ratRTMTdata.accuracyIpsi=accuracyIpsi;
            ratRTMTdata.accuracyContra=accuracyContra;
            ratRTMTdata.allAccuracy=allAccuracy;
            ratRTMTdata.treatement=ratTreatment;
            fprintf('Saving summary mat file for %s\n',ratID)
            
            save(saveFile,'ratRTMTdata','-v7.3','-mat')
            fprintf('Finished this rat on to the next! %s\n',ratID)
            if strcmp(ratTreatment, 'control')
       
                behaviorData.controlRats.(ratID) = ratRTMTdata;
            
                % Append to group-level data (initialize if needed)
                if ~isfield(behaviorData.controlRats, 'allRatRT')
                    behaviorData.controlRats.allRatRT = [];
                    behaviorData.controlRats.allRatMT = [];
                    behaviorData.controlRats.allIpsiRT = [];
                    behaviorData.controlRats.allIpsiMT = [];
                    behaviorData.controlRats.allContraRT = [];
                    behaviorData.controlRats.allContraMT = [];
                    behaviorData.controlRats.allRatRTMT = [];
                    behaviorData.controlRats.allIpsiRTMT = [];
                    behaviorData.controlRats.allContraRTMT = [];
                    behaviorData.controlRats.accuracyIpsi = [];
                    behaviorData.controlRats.accuracyContra = [];
                    behaviorData.controlRats.allAccuracy = [];
                end
            
                % Append new data for this rat
                behaviorData.controlRats.allRatRT = [behaviorData.controlRats.allRatRT; ratRTMTdata.allRatRT];
                behaviorData.controlRats.allRatMT = [behaviorData.controlRats.allRatMT; ratRTMTdata.allRatMT];
                behaviorData.controlRats.allIpsiRT = [behaviorData.controlRats.allIpsiRT; ratRTMTdata.allIpsiRT];
                behaviorData.controlRats.allIpsiMT = [behaviorData.controlRats.allIpsiMT; ratRTMTdata.allIpsiMT];
                behaviorData.controlRats.allContraRT = [behaviorData.controlRats.allContraRT; ratRTMTdata.allContraRT];
                behaviorData.controlRats.allContraMT = [behaviorData.controlRats.allContraMT; ratRTMTdata.allContraMT];
                behaviorData.controlRats.allRatRTMT = [behaviorData.controlRats.allRatRTMT; ratRTMTdata.allRatRTMT];
                behaviorData.controlRats.allIpsiRTMT = [behaviorData.controlRats.allIpsiRTMT; ratRTMTdata.allIpsiRTMT];
                behaviorData.controlRats.allContraRTMT = [behaviorData.controlRats.allContraRTMT; ratRTMTdata.allContraRTMT];
                behaviorData.controlRats.accuracyIpsi = [behaviorData.controlRats.accuracyIpsi; ratRTMTdata.accuracyIpsi];
                behaviorData.controlRats.accuracyContra = [behaviorData.controlRats.accuracyContra; ratRTMTdata.accuracyContra];
                behaviorData.controlRats.allAccuracy = [behaviorData.controlRats.allAccuracy; ratRTMTdata.allAccuracy];
            else
                % Save rat-specific data
                behaviorData.lesionRats.(ratID) = ratRTMTdata;
            
                % Append to group-level data (initialize if needed)
                if ~isfield(behaviorData.lesionRats, 'allRatRT')
                    behaviorData.lesionRats.allRatRT = [];
                    behaviorData.lesionRats.allRatMT = [];
                    behaviorData.lesionRats.allIpsiRT = [];
                    behaviorData.lesionRats.allIpsiMT = [];
                    behaviorData.lesionRats.allContraRT = [];
                    behaviorData.lesionRats.allContraMT = [];
                    behaviorData.lesionRats.allRatRTMT = [];
                    behaviorData.lesionRats.allIpsiRTMT = [];
                    behaviorData.lesionRats.allContraRTMT = [];
                    behaviorData.lesionRats.accuracyIpsi = [];
                    behaviorData.lesionRats.accuracyContra = [];
                    behaviorData.lesionRats.allAccuracy = [];
                end
            
                % Append new data for this rat
                behaviorData.lesionRats.allRatRT = [behaviorData.lesionRats.allRatRT; ratRTMTdata.allRatRT];
                behaviorData.lesionRats.allRatMT = [behaviorData.lesionRats.allRatMT; ratRTMTdata.allRatMT];
                behaviorData.lesionRats.allIpsiRT = [behaviorData.lesionRats.allIpsiRT; ratRTMTdata.allIpsiRT];
                behaviorData.lesionRats.allIpsiMT = [behaviorData.lesionRats.allIpsiMT; ratRTMTdata.allIpsiMT];
                behaviorData.lesionRats.allContraRT = [behaviorData.lesionRats.allContraRT; ratRTMTdata.allContraRT];
                behaviorData.lesionRats.allContraMT = [behaviorData.lesionRats.allContraMT; ratRTMTdata.allContraMT];
                behaviorData.lesionRats.allRatRTMT = [behaviorData.lesionRats.allRatRTMT; ratRTMTdata.allRatRTMT];
                behaviorData.lesionRats.allIpsiRTMT = [behaviorData.lesionRats.allIpsiRTMT; ratRTMTdata.allIpsiRTMT];
                behaviorData.lesionRats.allContraRTMT = [behaviorData.lesionRats.allContraRTMT; ratRTMTdata.allContraRTMT];
                behaviorData.lesionRats.accuracyIpsi = [behaviorData.lesionRats.accuracyIpsi; ratRTMTdata.accuracyIpsi];
                behaviorData.lesionRats.accuracyContra = [behaviorData.lesionRats.accuracyContra; ratRTMTdata.accuracyContra];
                behaviorData.lesionRats.allAccuracy = [behaviorData.lesionRats.allAccuracy; ratRTMTdata.allAccuracy];
            end
    
        clearvars('ratRTMTdata','saveFile')
    
    
      end
      saveBehaviorData=fullfile(parent_directory,'Behavior_RtMtData');
      saveBeahvioralFile=fullfile(saveBehaviorData,'behaviorDataSummary.mat');
      save(saveBeahvioralFile,'behaviorData','-v7.3','-mat')

      
else
    saveBehaviorData=fullfile(parent_directory,'Behavior_RtMtData');
      saveBeahvioralFile=fullfile(saveBehaviorData,'behaviorDataSummary.mat');
    load(saveBeahvioralFile)

end
if plotData

%% Plot histograms comparing lesion vs control rats (RT and MT metrics)
plotVars = {'allRatRT','allRatMT','allIpsiRT','allIpsiMT', ...
            'allContraRT','allContraMT','allRatRTMT','allIpsiRTMT','allContraRTMT'};

% Create save directory for histograms
histFolder = fullfile(saveBehaviorData, 'Histograms');
if ~exist(histFolder, 'dir')
    mkdir(histFolder);
end

for iVar = 1:length(plotVars)
    varName = plotVars{iVar};

    if ~isfield(behaviorData.controlRats, varName) || ~isfield(behaviorData.lesionRats, varName)
        fprintf('Skipping %s (missing in behaviorData)\n', varName);
        continue
    end

    controlData = behaviorData.controlRats.(varName);
    lesionData  = behaviorData.lesionRats.(varName);
    controlData = controlData(~isnan(controlData));
    lesionData  = lesionData(~isnan(lesionData));

    % --- Histogram figure ---
    allData = [controlData; lesionData];
    nBins = 100;
    edges = linspace(min(allData), max(allData), nBins);

    [p_value, shuffle_diffs] = meanDifference_shuffleTest(controlData, lesionData, n_shuffles);

    figHist = figure('Visible','on','Position',[100 100 800 600]);
    hold on

    if probabilityNormalization
        histogram(controlData, edges, 'FaceColor', [0 0.447 0.741], 'FaceAlpha', 0.6, 'Normalization','probability');
        histogram(lesionData,  edges, 'FaceColor', [0.85 0.325 0.098], 'FaceAlpha', 0.6, 'Normalization','probability');
        ylabel('Probability');
    else
        histogram(controlData, edges, 'FaceColor', [0 0.447 0.741], 'FaceAlpha', 0.6);
        histogram(lesionData,  edges, 'FaceColor', [0.85 0.325 0.098], 'FaceAlpha', 0.6);
        ylabel('Counts');
    end

    xlabel(strrep(varName, '_', ' '), 'Interpreter', 'none');
    title(sprintf('Lesion vs Control: %s', strrep(varName, '_', ' ')), 'Interpreter', 'none');
    legend({'Control','Lesion'}, 'Location','best');
    grid on
    box off
    ylim([0 0.8])
    xlim([0 1.5])
    % Significance star
    if p_value < 0.001
        starText = '***';
    elseif p_value < 0.01
        starText = '**';
    elseif p_value < 0.05
        starText = '*';
    else
        starText = 'n.s.';
    end
    yStar = 0.48; % slightly below 0.5
    text(mean(xlim), yStar, sprintf('%s (p = %.3g)', starText, p_value), ...
    'HorizontalAlignment','center', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
    saveFileName = fullfile(histFolder, sprintf('Histogram_%s.png', varName));
    saveas(figHist, saveFileName);
    close(figHist);

    % --- Bar graph of mean ± SEM ---
    figBar = figure('Visible','on','Position',[100 100 600 500]);
    means = [mean(controlData), mean(lesionData)];
    sems  = [std(controlData)/sqrt(numel(controlData)), std(lesionData)/sqrt(numel(lesionData))];

    barHandle = bar(1:2, means, 'FaceColor','flat');
    barHandle.CData(1,:) = [0 0.447 0.741];  % Control color
    barHandle.CData(2,:) = [0.85 0.325 0.098]; % Lesion color
    hold on
    errorbar(1:2, means, sems, 'k', 'LineStyle','none', 'LineWidth',1.5);
    if contains(varName,'RTMT')
        ylim([0 1])
    elseif contains(varName,'RT')
        ylim([0 0.4])
    else
        ylim([0 0.5])
    end
    set(gca, 'XTick', 1:2, 'XTickLabel', {'Control','Lesion'});
    ylabel('Time(s)', 'Interpreter', 'none');
    title(sprintf('Mean ± SEM: %s', strrep(varName, '_', ' ')), 'Interpreter', 'none');
    grid on
    box off

    % Add significance star above bars
    yStar = max(means + sems) * 1.05;
    text(1.5, yStar, starText, 'HorizontalAlignment','center', 'FontSize',14, 'FontWeight','bold');

    saveFileNameBar = fullfile(histFolder, sprintf('BarGraph_%s.png', varName));
    saveas(figBar, saveFileNameBar);
    close(figBar);
end

disp(['Saved histograms AND mean ± SEM bar graphs to: ' histFolder])
end
disp('Done!')
