function eventRaster(ts,event)
% [] needs a lot of work to be a real function

ts = nexStruct.neurons{2,1}.timestamps;

spikeWindow = 1; % second
theEvent = {}; % Mx1 cell of spike times, M = trials, each cell 1xN spike times
cellCount = 1;
sortVals = [];

useTrials = find([trials.correct]==1);
for ii=useTrials
    t = trials(ii).timestamps.centerOut;
    trialTs = ts(ts < t + spikeWindow & ts > t - spikeWindow) - t;
    theEvent(cellCount,1) = {trialTs'};
    sortVals(cellCount) = trials(ii).timing.MT;
    cellCount = cellCount + 1;
end
[B,I] = sort(sortVals);
% theEvent = theEvent(I,1);
correctCount = cellCount;

useTrials = find([trials.correct]==0);
for ii=useTrials
    t = trials(ii).timestamps.centerOut;
    trialTs = ts(ts < t + spikeWindow & ts > t - spikeWindow) - t;
    theEvent(cellCount,1) = {trialTs'};
    cellCount = cellCount + 1;
end

figure;
plotSpikeRaster(theEvent,'PlotType','vertline','AutoLabel',true);
hold on;
plot([-spikeWindow spikeWindow],[correctCount correctCount],'r');
% sortLine = length(find(B<0.4));
% plot([-spikeWindow spikeWindow],[sortLine sortLine],'g');


tSpans = [];
for ii=1:49
    tSpans(ii) = trials(ii).timestamps.centerOut;
end
% eventFieldnames = fieldnames(trials(iTrial).timestamps);
% eventTs = getfield(trials(iTrial).timestamps, eventFieldnames{iField});