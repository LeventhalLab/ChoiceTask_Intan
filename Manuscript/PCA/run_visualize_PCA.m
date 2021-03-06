doSave = true;
doLabels = false;
coeff_event = 4;
nSources = 3; % 1 = standard, 2 = ipsi/contra, 3 = all/ipsi/contra

colors = lines(2);
tWindow_vis = 1;
SDEsamples = tWindow_vis * 2 * 1000;
t_vis = linspace(-tWindow_vis,tWindow_vis,SDEsamples);
maxRows = 6;
cols = 7;
ylimVals = [-2 4];

sessionPCA_coeff = sessionPCA_500ms;

for iSession = [2,16]%1:numel(sessionPCA_500ms)
    rows = min([size(sessionPCA_500ms(iSession).PCA_arr,2) maxRows]);
    h = figuree(1200,133*rows);
    for iSource = 1:nSources
        if nSources == 1
            sessionPCA_covMatrix = sessionPCA_1000ms;
            lineColor = [0 0 0];
            fileLabel = 'PCA';
            savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/PCA/perSessionAnalysis';
        else
            fileLabel = 'contraIpsiPCA';
            savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/PCA/perSessionAnalysis/contraIpsi';
            switch iSource
                case 1
                    sessionPCA_covMatrix = sessionPCA_1000ms;
                    lineColor = repmat(.5,[1,4]);
                case 2
                    sessionPCA_covMatrix = sessionPCA_1000ms_contra;
                    lineColor = colors(1,:);
                case 3
                    sessionPCA_covMatrix = sessionPCA_1000ms_ipsi;
                    lineColor = colors(2,:);
            end
        end
        
        for iEvent = 1:cols
            covMatrix = squeeze(sessionPCA_covMatrix(iSession).PCA_arr(iEvent,:,:))';
            if coeff_event == 0
                coeff = squeeze(sessionPCA_coeff(iSession).coeff(iEvent,:,:)); % NOTE COEFF SOURCE: coeff_event or iEvent?
            else
                coeff = squeeze(sessionPCA_coeff(iSession).coeff(coeff_event,:,:));
            end
            pca_data = covMatrix * coeff;
            for iPCA = 1:rows
                subplot(rows,cols,prc(cols,[iPCA iEvent]));
                demixed_data = pca_data(:,iPCA);
                reshaped_demixed_data = reshape(demixed_data,[SDEsamples numel(demixed_data)/SDEsamples]);
                plot(t_vis,mean(reshaped_demixed_data,2),'-','lineWidth',0.5,'color',lineColor);
                hold on;
                xlim([min(t_vis) max(t_vis)]);
                ylim(ylimVals);
                yticks(sort([ylimVals 0]));
                pcaStr = ['PC ',num2str(iPCA),', ',num2str(sessionPCA_coeff(iSession).explained(coeff_event,iPCA),'%1.2f'),'% exp'];
                if doLabels
                    if iPCA == 1
                        if iEvent == 1
                            title({[sessionNames_PCA{iSession},', ',num2str(size(sessionPCA_500ms(iSession).PCA_arr,2)),' units'],eventFieldlabels{iEvent},pcaStr},'interpreter','none');
                        elseif iEvent == coeff_event
                            title({'COEFF EVENT',eventFieldlabels{iEvent},pcaStr});
                        else
                            title({'',eventFieldlabels{iEvent},pcaStr});
                        end
                    else
                        if iEvent == 4
                            title(pcaStr);
                        else
                            title(['PC ',num2str(iPCA)]);
                        end
                    end
                    if iPCA == rows
                        xlabel('time (s)');
                    end
                    if iEvent == 1
                        ylabel('Z');
                    end
                else
                    xticklabels({});
                    yticklabels({});
                end
                grid on;
            end
        end
    end
    
    set(h,'color','w');
    saveFile = [fileLabel,'_',sessionNames_PCA{iSession}];
    if doSave
        if doLabels
            saveas(h,fullfile(savePath,saveFile),'png');
        else
            tightfig;
            setFig('','',[1.5,0]);
            print(gcf,'-painters','-depsc',fullfile(savePath,saveFile));
        end
        close(h);
    end
end