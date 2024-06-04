function trialRanges = periEventTrialTs(trials,tWindow,eventFieldnames)
%
%
% INPUTS
%   trials - trials structure
%   tWindow - two-element array containing length of time (in seconds)
%       before and after each event to extract. Note that both elements of
%       tWindow will be added to the reference event (so usually the first
%       number will be negative, second will be positive)
%   eventFieldnames - length of event fields for which to extract time
%       windows
%       For a correct trial, eventFieldnames are as follows:
%         cueOn, centerIn, tone, centerOut, sideIn, sideOut, foodClick, foodRetrieval
%         - to find eventFieldnames for non-correct trials, check the
%         timestamps column in the trials structure.
%
% OUTPUTS
%   trialRanges - m x n x 2 array, where m is the number of fields being
%       analyzed, n is the number of trials, and the last two elements
%       contain the start and end time for each window

trialRanges = NaN(numel(eventFieldnames),numel(trials),2);
for iField = 1:numel(eventFieldnames)
    for iTrial = 1:numel(trials)
        try
            centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
            trialRanges(iField,iTrial,:) = centerTs + tWindow;
%             trialRanges(iField,iTrial,1) = centerTs + tWindow(1); %this
%                   code is from an older version of this function.
%             trialRanges(iField,iTrial,2) = centerTs + tWindow(2);
        catch
            % do nothing, filled with NaN
        end
    end
end