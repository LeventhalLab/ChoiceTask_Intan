function [meanFR,stdFR]=preCueOnData(spikeTimes,trials,event_name,binWidth)


% RL Modified from Nick Steinmetz Spikes Toolbox Github
% % wr will have one entry per spike, corresponding to an integer identifying
% % which range the spike was in
% wr = WithinRanges(spikeTimes, ranges, rangeLabel', 'vector');
% 
% stIn = spikeTimes(wr>0); wr = wr(wr>0); % pick just the spikes and range indices that actually were within a range
% stRelToEvent = stIn-eventTimes(wr); % subtract the event time corresponding to each spike

% Define the pre-cue window (in seconds)
window = [-2 0];
windowLength = abs(diff(window));  % Should be 2 seconds

% Get event timestamps from trial data
eventTimes = ts_from_trials(trials, event_name);
eventTimes = eventTimes(~isnan(eventTimes));  % Remove NaNs

% Convert spike times to seconds (if they are in ms)
spikeTimes = spikeTimes / 1000;

% Initialize vector to store firing rates for each trial
numTrials = length(eventTimes);
firingRates = zeros(numTrials, 1);  % Store firing rate for each trial

% Loop through each trial
for i = 1:numTrials
    t0 = eventTimes(i);
    % Define the trial's pre-cue window
    trialWindow = [t0 + window(1), t0 + window(2)];

    % Calculate which spikes fall within the trial's pre-cue window
    % We use 'WithinRanges' to check for spikes in this window
    wr = WithinRanges(spikeTimes, trialWindow, 1, 'vector');  
    stIn = spikeTimes(wr > 0);  % Spikes within the trial window

    % Calculate the firing rate for this trial (spikes per second)
    firingRates(i) = (length(stIn) / windowLength);  % Spikes in 2 seconds
end

% Calculate the mean and standard deviation of the firing rate across trials
smoothedFR=movmean(firingRates,3);
meanFR = mean(smoothedFR);  % Mean firing rate across trials
stdFR = std(smoothedFR);  

