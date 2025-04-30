function spikeStruct = loadKSdir_RL(ksDir, varargin)

if ~isempty(varargin)
    params = varargin{1};
else
    params = [];
end

if ~isfield(params, 'excludeNoise')
    params.excludeNoise = false;
end
if ~isfield(params, 'loadPCs')
    params.loadPCs = false;
end
%Set params to exlude non good units for now 3/31/25
params.excludeNoise=true;
params.excludeNonSomatic=true;
params.excludeMUA=true;
params.loadPCs=true;
% load spike data
spikeStruct = loadParamsPy(fullfile(ksDir, 'params.py'));
savePath=fullfile(ksDir,'qmetrics');
if exist(fullfile(ksDir, 'spike_times_corrected.npy'))
    ss = readNPY(fullfile(ksDir, 'spike_times_corrected.npy')); %For chronic sessions
    sessionid = ones(size(ss));
    idx = find([0; diff(ss)]<0);
    for id = 1:length(idx)
        sessionid(idx(id):end) = id+1;
    end
else
    ss = readNPY(fullfile(ksDir, 'spike_times.npy'));
    sessionid = ones(size(ss));

end
st = double(ss)/spikeStruct.sample_rate;
spikeTemplates = readNPY(fullfile(ksDir, 'spike_templates.npy')); % note: zero-indexed

if exist(fullfile(ksDir,'spike_datasets.npy'))
    datas = readNPY(fullfile(ksDir,'spike_datasets.npy'));
else
    datas = zeros(length(spikeTemplates),1);
    params.thisdate = [];
end

if ~isfield(params,'thisdate') || isempty(params.thisdate)
    datasetidx = unique(datas);
else 
    datasetidx = find(cell2mat(cellfun(@(X) any(strfind(X,params.thisdate)),strsplit(spikeStruct.dat_path,','),'UniformOutput',0)))-1; %Which dataset to take?
end
coords = readNPY(fullfile(ksDir, 'channel_positions.npy'));
ycoords = coords(:,2); 
xcoords = coords(:,1);
temps = readNPY(fullfile(ksDir, 'templates.npy'));
channelMap=readNPY(fullfile(ksDir,'channel_map.npy'));
winv = readNPY(fullfile(ksDir, 'whitening_mat_inv.npy'));
try
    tempScalingAmps = readNPY(fullfile(ksDir, 'amplitudes.npy'));
catch
    tempScalingAmps = nan(length(st),1);
end
if params.loadPCs
    pcFeat = readNPY(fullfile(ksDir,'pc_features.npy')); % nSpikes x nFeatures x nLocalChannels
    pcFeatInd = readNPY(fullfile(ksDir,'pc_feature_ind.npy')); % nTemplates x nLocalChannels
else
    pcFeat = [];
    pcFeatInd = [];
end

%%Correlate Channels to clusters ID
templateWaveforms = zeros(size(temps));

for t = 1:size(templateWaveforms, 1)
    templateWaveforms(t, :, :) = squeeze(temps(t, :, :)); %* winv;
end
cgsFile = '';
%load in clusters based on their bombcell classifications. 
if exist(fullfile(ksDir, 'cluster_bc_unitType.tsv')) 
    cgsFile = fullfile(ksDir, 'cluster_bc_unitType.tsv');
    [cids, cgs] = readBCunitTypeTSV(cgsFile);
else
    fprintf('\nPausing --- Bombcell QC not done.\n');
    fprintf('See: github.com/LeventhalLab/ChoiceTask_Intan/spikesAnalysis/bombcell-LeventhalLab/bombcell_batch_run.m before continuing\n\n');
    keyboard
end

 %If manual curation was done, account for mismatched units following curation 
if exist(fullfile(ksDir, 'spike_clusters.npy'))
    clu = readNPY(fullfile(ksDir, 'spike_clusters.npy')); %Changed by phy
    clu1index=int32(clu)+1;
    spikeTemp1index=int32(spikeTemplates)+1;
   
    newTemplates = unique(clu1index(~ismember(clu1index, spikeTemp1index)));%%May not need to be 1 indexed
    if ~isempty(newTemplates)
        % initialize templates and pc features
        try
            templateWaveforms = [templateWaveforms; zeros(max(newTemplates)-size(templateWaveforms, 1), size(templateWaveforms, 2), size(templateWaveforms, 3))];
            
        catch
            keyboard
        end
        pcFeatInd = [pcFeatInd; zeros(max(newTemplates)-size(pcFeatInd, 1), size(pcFeatInd, 2))];
        for iNewTemplate = newTemplates'
            % find corresponding pre merge/split templates and PCs
            oldTemplates = spikeTemp1index(clu1index == iNewTemplate);
            if length(unique(oldTemplates)) > 1 % average if merge
                newWaveform = mean(templateWaveforms(unique(oldTemplates), :, :), 1);
                newpcFeatInd = mean(pcFeatInd(unique(oldTemplates), :), 1);
            else % just take value if split
                newWaveform = templateWaveforms(unique(oldTemplates), :, :);
                newpcFeatInd = pcFeatInd(unique(oldTemplates), :);
            end
            templateWaveforms(iNewTemplate, :, :) = newWaveform;
            pcFeatInd(iNewTemplate, :) = newpcFeatInd;

        end
        if length(unique(clu)) < size(templateWaveforms,1)
                validIdx=unique(clu1index);
                templateWaveforms=templateWaveforms(validIdx,:,:);
        end
%         % check raw waveforms 
%         bc.load.checkAndConvertRawWaveforms(savePath, spikeTemplates, clu)
% 
% 
    
    

    else
         clu = spikeTemplates;
%          % check raw waveforms 
%         bc.load.checkAndConvertRawWaveforms(savePath, spikeTemplates, spikeClusters)
% 
    end
else
    clu = spikeTemplates; %originial
%   % check raw waveforms 
%   bc.load.checkAndConvertRawWaveforms(savePath, spikeTemplates, spikeClusters)
end




% if exist(fullfile(ksDir, 'cluster_group.tsv')) 
%    cgsFile = fullfile(ksDir, 'cluster_group.tsv');
% end 

cluster_ids=unique(clu);






%Get the channel for the cluster ID
maxChannels= bc.qm.helpers.getWaveformMaxChannel(templateWaveforms);
%Needs to be referenced back to actual channel ids
maxChannels=channelMap(maxChannels);
%templateWaveformsMapped=templateWaveforms(:,:,channelMap);

if ~isempty(cgsFile)

    
    if isempty(cids(cgs==1))
        spikeStruct=[];
        return
    end
    maxChannels=maxChannels(ismember(cluster_ids,cids));
    cluster_ids=cluster_ids(ismember(cluster_ids,cids));
    clusterChannel = [double(cluster_ids), double(maxChannels)];
    
    
    unlabeledClusters = unique(clu(~ismember(clu, cids)));

    % Remove spikes belonging to those unlabeled clusters
    if ~isempty(unlabeledClusters)
        st = st(~ismember(clu, unlabeledClusters));
        spikeTemplates = spikeTemplates(~ismember(clu, unlabeledClusters));
        tempScalingAmps = tempScalingAmps(~ismember(clu, unlabeledClusters));
        datas = datas(~ismember(clu, unlabeledClusters));
        if params.loadPCs
            pcFeat = pcFeat(~ismember(clu, unlabeledClusters), :,:);
        end
        clu = clu(~ismember(clu, unlabeledClusters));
        % Note: no need to change cgs or cids here because these clusters were never in cids anyway
    end
    if params.excludeNoise % Remove noise units
        noiseClusters = cids(cgs==0);

        st = st(~ismember(clu, noiseClusters));
        spikeTemplates = spikeTemplates(~ismember(clu, noiseClusters));
        tempScalingAmps = tempScalingAmps(~ismember(clu, noiseClusters));        
        datas = datas(~ismember(clu, noiseClusters));
        if params.loadPCs
            pcFeat = pcFeat(~ismember(clu, noiseClusters), :,:);
            pcFeatInd = pcFeatInd(~ismember(cids, noiseClusters),:);
        end
        
        clu = clu(~ismember(clu, noiseClusters));
        cgs = cgs(~ismember(cids, noiseClusters));
        cids = cids(~ismember(cids, noiseClusters));
    end
    if params.excludeNonSomatic %Remove non-somatic units    
        nonSomaClusters = cids(cgs==3);

        st = st(~ismember(clu, nonSomaClusters));
        spikeTemplates = spikeTemplates(~ismember(clu, nonSomaClusters));
        tempScalingAmps = tempScalingAmps(~ismember(clu, nonSomaClusters));        
        datas = datas(~ismember(clu, nonSomaClusters));
        if params.loadPCs
            pcFeat = pcFeat(~ismember(clu, nonSomaClusters), :,:);
            pcFeatInd = pcFeatInd(~ismember(cids, noiseClusters),:);
        end
        
        clu = clu(~ismember(clu, nonSomaClusters));
        cgs = cgs(~ismember(cids, nonSomaClusters));
        cids = cids(~ismember(cids, nonSomaClusters));
    end
    if params.excludeMUA  %Remove MUA Units    
        muaClusters = cids(cgs==2);

        st = st(~ismember(clu, muaClusters));
        spikeTemplates = spikeTemplates(~ismember(clu, muaClusters));
        tempScalingAmps = tempScalingAmps(~ismember(clu, muaClusters));        
        datas = datas(~ismember(clu, muaClusters));
        if params.loadPCs
            pcFeat = pcFeat(~ismember(clu, muaClusters), :,:);
            pcFeatInd = pcFeatInd(~ismember(cids, noiseClusters),:);
        end
        
        clu = clu(~ismember(clu, muaClusters));
        cgs = cgs(~ismember(cids, muaClusters));
        cids = cids(~ismember(cids, muaClusters));
    end
    
    
else
    clu = spikeTemplates;
    
    cids = unique(spikeTemplates);
    cgs = 3*ones(size(cids));
end
good_ids=unique(clu);
goodIndices=setdiff(cluster_ids,good_ids);
goodIndices=goodIndices+1;
if ~isempty(goodIndices)
  templateWaveforms(goodIndices,:,:)=[]; 
end
clusterChannel = clusterChannel(ismember(clusterChannel(:,1), cids), :);   
% Only take needed data
spikeTemplates = spikeTemplates(ismember(datas,datasetidx));
tempScalingAmps = tempScalingAmps(ismember(datas,datasetidx));
st = st(ismember(datas,datasetidx));
clu = clu(ismember(datas,datasetidx));
datas = datas(ismember(datas,datasetidx));
% if params.loadPCs
%     pcFeat = pcFeat(ismember(datas,datasetidx), :,:);
%     pcFeatInd = pcFeatInd(~ismember(cids, noiseClusters),:);
% end
% 


%Create spikeStruct with all necessary information

spikeStruct.st = st;
spikeStruct.SessionID = sessionid;
spikeStruct.spikeTemplates = spikeTemplates;
spikeStruct.clu = clu;
spikeStruct.tempScalingAmps = tempScalingAmps;
spikeStruct.cgs = cgs;
spikeStruct.cids = cids;
spikeStruct.allClusIDs=cluster_ids;
spikeStruct.xcoords = xcoords;
spikeStruct.ycoords = ycoords;
spikeStruct.temps = temps;
spikeStruct.winv = winv;
spikeStruct.pcFeat = pcFeat;
spikeStruct.pcFeatInd = pcFeatInd;
spikeStruct.dataset = datas;
spikeStruct.templateWaveforms=templateWaveforms;

%spikeStruct.channelMap=channelMap;
% spikeStruct.maxChannels=maxChannels;
% spikeStruct.clusterMaxChannel=clusterChannel;
spikeStruct.clusterChannel=clusterChannel;
% [spikeStruct.spikeAmps, spikeStruct.spikeDepths, spikeStruct.templateDepths, spikeStruct.templateXpos, spikeStruct.tempAmps, spikeStruct.tempsUnW, spikeStruct.templateDuration, spikeStruct.waveforms] = ...
%     templatePositionsAmplitudes(spikeStruct.temps, spikeStruct.winv, spikeStruct.ycoords, spikeStruct.xcoords, spikeStruct.spikeTemplates, spikeStruct.tempScalingAmps); %from the spikes toolbox
%templateWaveforms = sp.temps;