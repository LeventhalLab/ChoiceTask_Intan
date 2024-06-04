function trial_ts = extract_trial_ts(trials, eventFieldnames)
%
%
% INPUTS
%   trials - trials structure

% %   tWindow - two-element array containing length of time (in seconds)
% %       before and after each event to extract. Note that both elements of
% %       tWindow will be added to the reference event (so usually the first
% %       number will be negative, second will be positive)

% WHY DOES THIS FILE NEED TWINDOW?? DOES NOT MAKE SENSE.

%   eventFieldnames - event fields for which to extract time
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

trial_ts = NaN(numel(eventFieldnames),numel(trials));
for iField = 1:numel(eventFieldnames)
    for iTrial = 1:numel(trials)
        try
            ts = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
            trial_ts(iField, iTrial) = ts;
        catch
            % do nothing, filled with NaN
        end
    end
end