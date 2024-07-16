function trial_ts = extract_trial_ts(trials, eventFieldnames)
%
% function to return a vector of timestamps given a trials data structure
% and a cell array of event names
%
% INPUTS
%   trials - trials structure
%
%   eventFieldnames - event fields for which to extract time
%       windows
%       For a correct trial, eventFieldnames are as follows:
%         cueOn, centerIn, tone, centerOut, sideIn, sideOut, foodClick, foodRetrieval
%         - to find eventFieldnames for non-correct trials, check the
%         timestamps column in the trials structure.
%
% OUTPUTS
%   trial_ts - m x n array, where m is the number of fields being
%       analyzed and n is the number of trials

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