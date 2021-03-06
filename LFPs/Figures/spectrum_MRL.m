% load('fig__spectrum_MRL_20181108');
% raw data was compiled with LFP_byX.m (doSetup = true)
% freqList = logFreqList([1 200],30);
doSave = false;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.05 .02];

eventfields = {'Cue','Nose In','Tone','Nose Out','Side In','Side Out','Reward'};
scaloPower = squeeze(mean(session_Wz_power(:,:,:,:)));
scaloPhase = squeeze(mean(session_Wz_phase(:,:,:,:)));
scaloRayleigh = squeeze(mean(session_Wz_rayleigh_pval(:,:,:,:)));
t = linspace(-1,1,size(scaloPower,2));

h = ff(1400,800);
rows = 2;
cols = 7;
colors = magma(30);
hFreq = closest(freqList,9);
for iEvent = 1:7
    for iFreq = 1:numel(freqList)
        subplot(rows,cols,prc(cols,[1,iEvent]));
        plot(t,smooth(squeeze(scaloPower(iEvent,:,iFreq))),'color',colors(iFreq,:));
        hold on;
    end
    plot(t,smooth(squeeze(scaloPower(iEvent,:,hFreq))),'color',colors(hFreq,:),'linewidth',3);
    ylim([-1 4]);
    yticks(sort([0 ylim]));
    xticks(sort([0 xlim]));
    grid on;
    title({eventfields{iEvent},'power'},'color','w');
    set(gca,'color','k');
    set(gca,'XColor','w');
    set(gca,'YColor','w');
    if iEvent == 1
        ylabel('Z-score','color','w');
    end
    if iEvent == 7
        cb = colorbar;
        colormap(colors);
        cb.Limits = [0 1];
        cb.Ticks = linspace(0,1,numel(freqList));
        cb.TickLabels = compose('%2.1f',freqList);
        cb.Color = 'w';
    end
    
    for iFreq = 1:numel(freqList)
        subplot(rows,cols,prc(cols,[2,iEvent]));
        plot(t,smooth(squeeze(scaloPhase(iEvent,:,iFreq))),'color',colors(iFreq,:));
        hold on;
    end
    plot(t,smooth(squeeze(scaloPhase(iEvent,:,hFreq))),'color',colors(hFreq,:),'linewidth',3);
    ylim([0 0.6]);
    yticks(ylim);
    xticks(sort([0 xlim]));
    grid on;
    title('phase','color','w');
    set(gca,'color','k');
    set(gca,'XColor','w');
    set(gca,'YColor','w');
    if iEvent == 1
        ylabel('MRL','color','w');
    end
    if iEvent == 7
        cb = colorbar;
        colormap(colors);
        cb.Limits = [0 1];
        cb.Ticks = linspace(0,1,numel(freqList));
        cb.TickLabels = compose('%2.1f',freqList);
        cb.Color = 'w';
    end
    
    set(gcf,'color','k');
end

h = ff(1200,450);
rows = 2;
cols = 7;
caxisVals = [-1 4];

for iEvent = 1:7
    subplot_tight(rows,cols,prc(cols,[1,iEvent]),subplotMargins);
    imagesc(t,1:numel(freqList),squeeze(scaloPower(iEvent,:,:))');
    colormap(gca,jet);
    caxis(caxisVals);
    xlim([-1 1]);
    xticks(0);
    xticklabels([]);
    yticks([]);
    set(gca,'YDir','normal');
    box off;
    grid on;
    
    subplot_tight(rows,cols,prc(cols,[2,iEvent]),subplotMargins);
    imagesc(linspace(-1,1,size(scaloPhase,2)),1:numel(freqList),squeeze(scaloPhase(iEvent,:,:))');
    colormap(gca,hot);
    caxis([0 1]);
    xlim([-1 1]);
    xticks(0);
    xticklabels([]);
    yticks([]);
    set(gca,'YDir','normal');
    box off;
    grid on;
end
tightfig;
setFig('','',[2,4]);
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'spectrum_MRL.eps'));
    close(h);
end

if doSave
    h = ff(1200,450);
    subplot_tight(rows,cols,7,subplotMargins);
    colormap(gca,jet);
    cb = colorbar;
    cb.Ticks = [];

    subplot_tight(rows,cols,14,subplotMargins);
    colormap(gca,hot);
    cb = colorbar;
    cb.Ticks = [];
    if doSave
        print(gcf,'-painters','-depsc',fullfile(figPath,'spectrum_MRL_colorbars.eps'));
        close(h);
    end
end