function event_triggered_lfps = extract_event_related_LFPs(ordered_lfp, trials, eventFieldnames, varargin)

%   ordered_lfp - m x n array of channels x data-points in an ordered array
%   trials - trials structure
%   eventFieldnames - name of event for which to extract timestamps:
%       For a correct trial, eventname options are as follows:
%         cueOn, centerIn, tone, centerOut, sideIn, sideOut, foodClick, foodRetrieval
%         - to find eventFieldnames for non-correct trials, check the
%         timestamps column in the trials structure.
%
% VARARGs:
%   Fs
%   twin

if ~iscell(eventFieldnames)
    eventFieldnames = {eventFieldnames};
end

% default values for varargs
twin = [-2.5 2.5];
Fs = 500;

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'fs'
            Fs = varargin{iarg + 1};
        case 'twin'
            twin = varargin{iarg + 1};
    end
end

trial_ts = extract_trial_ts(trials, eventFieldnames);

event_triggered_lfps = extract_LFP_around_timestamps(ordered_lfp, trial_ts, twin, Fs);
