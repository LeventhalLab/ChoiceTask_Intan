% function rtMtDist(analysisConf)
doLabels = false;
doSave = true;

if true
    all_rt = [];
    all_rt_c = {};
    all_mt = [];
    all_mt_c = {};
    all_subjects__id = [];
    lastSession = '';
    iSession = 0;
    for iNeuron = 1:size(analysisConf.neurons,1)
        iSession = iSession + 1;
        sessionConf = analysisConf.sessionConfs{iNeuron};
        if strcmp(sessionConf.sessions__name,lastSession)
            continue;
        end
        lastSession = sessionConf.sessions__name;
        logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
        logData = readLogData(logFile);
        neuronName = analysisConf.neurons{iNeuron};
        nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
        load(nexMatFile);
        if strcmp(neuronName(1:5),'R0154')
            nexStruct = fixMissingEvents(logData,nexStruct);
        end
        
%         corrIdx = find(logData.outcome == 0);
%         corrIdx_trials = find([trials(:).correct] == 1);
        trials = createTrialsStruct_simpleChoice(logData,nexStruct);

        timingField = 'RT';
        [trialIds,rt] = sortTrialsBy(trials,timingField); % forces to be 'correct'
        all_rt = [all_rt rt];
        all_rt_c{iSession} = rt;
        mt = [];
        for iTrial = 1:numel(trialIds)
            curTrial = trialIds(iTrial);
            mt(iTrial) = getfield(trials(curTrial).timing,'MT');
        end
        all_mt = [all_mt mt];
        all_mt_c{iSession} = mt;
        
        all_subjects__id = [all_subjects__id sessionConf.subjects__id];
        disp(['Session: ',num2str(iSession)]);
    end
end


rtDataPrct = numel(find(all_rt > expressRT & all_rt < ordinaryRT)) / numel(all_rt);
mtDataPrct = numel(find(all_mt < ordinaryMT)) / numel(all_mt);
rtmtDataPrct = mean([rtDataPrct mtDataPrct])

% let's try per-subject RT/MT line histograms
RTcounts = [];
histInt = .01;
xlimVals = [0 1];
subjects__ids = unique(all_subjects__id);
RTcounts = [];
MTcounts = [];
nSmooth = 5;
for iSubject = 1:numel(subjects__ids)
    curSubject = subjects__ids(iSubject);
    curRTsessions = all_rt_c(all_subjects__id == curSubject);
    curRT = [curRTsessions{:}];
    curMTsessions = all_mt_c(all_subjects__id == curSubject);
    curMT = [curMTsessions{:}];
    [counts,~] = hist(curRT,[xlimVals(1):histInt:xlimVals(2)]+histInt);
    RTcounts(iSubject,:) = smooth(interp(normalize(counts),nSmooth),nSmooth);
    [counts,~] = hist(curMT,[xlimVals(1):histInt:xlimVals(2)]+histInt);
    MTcounts(iSubject,:) = smooth(interp(normalize(counts),nSmooth),nSmooth);
end

% looks like trash, deprecate
% % figure;
% % plot(RTcounts','lineWidth',2);
% % 
% % figure;
% % plot(MTcounts','lineWidth',2);
useMeanColors = false;
grayColor = [.8 .8 .8];

nSmooth = 5;
lineWidth = 2;
adjLabel = 15;
h = figuree(600,300);
[rt_counts,rt_centers] = hist(all_rt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
[mt_counts,mt_centers] = hist(all_mt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
x = interp(rt_centers,nSmooth);
y = abs(interp(rt_counts,nSmooth));
if useMeanColors
    % run plotPermutations.m
    rtc1 = find(x > RT_meanBinsSeconds(2),1,'first');
    rtc2 = find(x > RT_meanBinsSeconds(10),1,'first');
    rt_meanColors = [repmat(grayColor,rtc1,1);cool(rtc2-rtc1);repmat(grayColor,numel(x)-rtc2,1)];
    lns_rt = colormapline(x,y,[],rt_meanColors);
else
    lns_rt = plot(x,y,'k');
end
set(lns_rt,'lineWidth',lineWidth);
% % plot(x,y,'k','lineWidth',lineWidth);
hold on;
[v,k] = max(y);
text(x(k),v + adjLabel,'RT','fontSize',14,'HorizontalAlignment','Center');
x = interp(mt_centers,nSmooth);
y = abs(interp(mt_counts,nSmooth));
if useMeanColors
    % run plotPermutations.m
    rtc1 = find(x > MT_meanBinsSeconds(2),1,'first');
    rtc2 = find(x > MT_meanBinsSeconds(10),1,'first');
    mt_meanColors = [repmat(grayColor,rtc1,1);summer(rtc2-rtc1);repmat(grayColor,numel(x)-rtc2,1)];
    lns_mt = colormapline(x,y,[],mt_meanColors);
else
    lns_mt = plot(x,y,'-','color',repmat(.65,[1,3]));
    plot(x,y,'k:');
end
set(lns_mt,'lineWidth',lineWidth);
% % lns = plot(x,y,'k','lineWidth',lineWidth);
[v,k] = max(y);
text(x(k),v + adjLabel,'MT','fontSize',14,'HorizontalAlignment','Center');
ylim([0 220]);
yticks(ylim);
xlim([0 1]);
xticks(xlim);
setFig('Time (s)','Trials');

if doSave
    if ~doLabels
        cleanPlot;
        tightfig;
        setFig('','',[1,1]);
    end
    exportEPS(h,figPath,'RTMT_distribution');
    close(h);
end

% per session/subject distributions
if false
    figuree(1200,250);
    cols = 3;

    histInt = .01;
    xlimVals = [0 1];
    subplot(1,cols,1);
    [counts,centers] = hist(all_rt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
    bar(centers,counts,'faceColor','k','edgeColor','k');
    xlabel('RT (s)');
    xlim(xlimVals);
    xticks(xlimVals);
    ylim([0 200]);
    yticks(ylim);
    ylabel('trials');
    set(gca,'fontSize',16);
    % title(['RT Distribution, ',num2str(numel(all_rt)),' trials, ',num2str(histInt*1000),' ms bins']);

    [counts,centers] = hist(all_mt,[xlimVals(1):histInt:xlimVals(2)]+histInt);
    subplot(1,cols,2);
    bar(centers,counts,'faceColor','k','edgeColor','k');
    xlabel('MT (s)');
    xlim(xlimVals);
    xticks(xlimVals);
    ylim([0 200]);
    yticks(ylim);
    ylabel('trials');
    set(gca,'fontSize',16);
    % title(['MT Distribution, ',num2str(numel(all_mt)),' trials, ',num2str(histInt*1000),' ms bins']);

    subplot(1,cols,3);
    subjects__ids = unique(all_subjects__id);
    colors = lines(numel(subjects__ids));
    curSubject = all_subjects__id(1);
    curColor = 1;
    lns = [];
    for iSession = 1:numel(all_subjects__id)
        if curSubject ~= all_subjects__id(iSession)
            curColor = curColor + 1;
            curSubject = all_subjects__id(iSession);
        end
        plot(all_rt_c{iSession},all_mt_c{iSession},'.','color',colors(curColor,:),'MarkerSize',10);
        hold on;
    end
    for iSubject = 1:numel(subjects__ids)
        lns(iSubject) = plot(-1,-1,'.','color',colors(iSubject,:),'MarkerSize',40);
    end
    xlim(xlimVals);
    xticks(xlimVals);
    ylim([0 1]);
    yticks(ylim);
    xlabel('RT (s)');
    ylabel('MT (s)');
    % title(['by subject, n = ',num2str(numel(subjects__ids))]);
    % % legend(lns,num2str(subjects__ids(:)));
    % % legend boxoff;
    set(gca,'fontSize',16);

    if cols > 3
        % RT-MT correlation
        subplot(1,cols,4);
        colors = jet(numel(all_mt_c));
        for iSession = 1:numel(all_rt_c)
            plot(all_rt_c{iSession},all_mt_c{iSession},'.','color',colors(iSession,:),'MarkerSize',10);
            hold on;
        end
        grid on;
        xlim(xlimVals);
        ylim([0 1]);
        xlabel('RT (s)');
        ylabel('MT (s)');
        title(['by session, N = ',num2str(numel(all_mt_c))]);
        set(gca,'fontSize',16);
    end

    set(gcf,'color','w');
    tightfig;
end
