% use primary + secondary classes
tWindow = 1;
binMs = 20;
binS = binMs / 1000;
trialTypes = {'correctContra','correctIpsi'};
useEvents = 1:7;
useTiming = {};
onlyPrimary = true;

% run together
% % [unitEvents,all_zscores,unitClass] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
% % primSec = primSecClass(unitEvents,0.5);

nSmooth = 3;
colors = [1 0 0;0 0 1];
plotAllClasses = false;
lineWidth = 3;
set_ylims = [-0.5 2];
ylabelloc = 1.5;

figuree(1200,400);
lns = [];
for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
% %     useNeurons = logical(sum(primSec(1,:) == iEvent,2));
% %     plot(squeeze(all_zscores(useNeurons,iEvent,:))','LineWidth',0.5,'Color',repmat(.1,1,4));
% %     hold on;

% %     if iEvent == 3
        if onlyPrimary
            useNeurons = logical(primSec(:,1) == 4);
        else
            useNeurons = logical(sum(primSec == 4,2)); % prim + sec
        end
        lns(2) = plot(smooth(mean(squeeze(all_zscores(useNeurons,iEvent,:))),nSmooth),'LineWidth',lineWidth,'Color',colors(1,:));
        hold on;
        if onlyPrimary
            useNeurons = logical(primSec(:,1) == 3);
        else
            useNeurons = logical(sum(primSec == 3,2)); % prim + sec
        end
        lns(1) = plot(smooth(mean(squeeze(all_zscores(useNeurons,iEvent,:))),nSmooth),'LineWidth',lineWidth,'Color',colors(2,:));
        medRT = median(all_rt);
        medRT_x = (size(all_zscores,3) / 2) + (medRT / binS);
% %         plot([medRT_x medRT_x],[-5 5],'k--');
% %         tx = text(medRT_x,ylabelloc,'median RT','fontSize',16,'HorizontalAlignment','center','VerticalAlignment','top');
% %         set(tx,'Rotation',90);
        legend(lns,{'Tone','Nose Out'},'location','south');
% %     elseif iEvent == 4
% %         if onlyPrimary
% %             useNeurons = logical(primSec(:,1) == 3);
% %         else
% %             useNeurons = logical(sum(primSec == 3,2)); % prim + sec
% %         end
% %         lns(1) = plot(smooth(mean(squeeze(all_zscores(useNeurons,iEvent,:))),nSmooth),'LineWidth',lineWidth,'Color',colors(2,:));
% %         hold on;
% %         if onlyPrimary
% %             useNeurons = logical(primSec(:,1) == 4);
% %         else
% %             useNeurons = logical(sum(primSec == 4,2)); % prim + sec
% %         end
% %         lns(2) = plot(smooth(mean(squeeze(all_zscores(useNeurons,iEvent,:))),nSmooth),'LineWidth',lineWidth,'Color',colors(1,:));
% %         medMT = median(all_mt);
% %         medMT_x = (size(all_zscores,3) / 2) + (medMT / binS);
% %         plot([medMT_x medMT_x],[-5 5],'k--');
% %         tx = text(medMT_x,ylabelloc,'median MT','fontSize',16,'HorizontalAlignment','center','VerticalAlignment','top');
% %         set(tx,'Rotation',90);
% %         legend(lns,{'Tone','Nose Out'},'location','south');
% %     else
% % % %         useNeurons = logical(primSec(:,1) == iEvent);
% %         useNeurons = logical(sum(primSec == iEvent,2));
% %         lns(iEvent) = plot(smooth(mean(squeeze(all_zscores(useNeurons,iEvent,:))),nSmooth),'LineWidth',lineWidth,'Color','k');
% %     end
  
    xlim([1 size(all_zscores,3)]);
    xticks([1 size(all_zscores,3)/2 size(all_zscores,3)]);
    xticklabels({'-1','0','1'});
    ylim(set_ylims);
    yticks([set_ylims(1) 0 set_ylims(2)]);
    
    title({[eventFieldnames{iEvent}]});
    if iEvent == 1
        ylabel('Z score');
    end
    if iEvent == 4
        xlabel('Time (s)');
    end
    
    set(gca,'fontSize',16);
    grid on;
end
set(gcf,'color','white');