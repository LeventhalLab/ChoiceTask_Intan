function [scalograms, f] = calculate_single_channel_event_triggered_scalograms(single_channel_triggered_lfps, fb)
%  calculate scalograms for each occurrence of a specific event for a
%  single channel. Store the scalograms in a 3-d array for saving and/or
%  later processing. Call this function from inside a loop through each
%  channel.
%
% INPUTS
%   single_channel_triggered_lfps - m x n array containing lfp data for a
%       single event from a single channel, where m is the number of events
%       (for example, number of "Nose In" events for a session), and 
%       n is the number of time samples for each event
%   fb - filter bank from cwtfilterbank function

% OUTPUTS
%   wt - wavelet transform; m x n x p array where m is the number of
%       events, n is the number of frequencies analyzed, and p is the
%       number of time samples for each event

% myData_ordered = load('R0326_20200228a_myData.mat'); % Will make the names of the variables more consistent for scripts. Using this for now for ease of troubleshooting.
% myData_ordered = myData_ordered.myData2;



% extract number of events and number
% of time points in a peri-event LFP sample from the input data array
num_events = size(single_channel_triggered_lfps, 1);
pts_per_event = size(single_channel_triggered_lfps, 2);

% assume time limits are symmetric around zero given the sampling rate and
% number of time points
% SHOULD MAKE TIME RANGE -2.5 TO +2.5 sec to avoid edge boundary distortion
% at low frequencies

% actually, don't really need these calculations other than to make the
% plot, should comment out once done debugging
% tlim = ((pts_per_event - 1) / (2*Fs)) * [-1, 1];
% t = linspace(tlim(1), tlim(2), pts_per_event); % time (x-axis)

% calculate the filter bank to be used. In fact, it might be more efficient
% to calculate the filter bank in the calling function and pass it into
% this function

% fb = cwtfilterbank('Wavelet', 'amor','SignalLength', 2001,'SamplingFrequency', 500 );

f = centerFrequencies(fb);
num_freqs = length(f);


% fb = cwtfilterbank(SignalLength==pts_per_event, ...
%     SamplingFrequency=Fs, ...
%     FrequencyLimits=flim, ...
%     wavelet=="amor");

% set up a 3-d array hold the complex scalogram for each event
scalograms = zeros(num_events, num_freqs, pts_per_event);

% loop through each event, calculate the scalogram for it, and store it in
% the scalogram array
for i_event = 1 : num_events

    % comment back in to have a counter to make sure it isn't stalled
    % during debugging
   % i_event - JM commented this out because I'm not sure what DL is
   % referring to here.

    eventlfp = squeeze(single_channel_triggered_lfps(i_event, :));

    % scalograms(i_event, :, :) = cwt(eventlfp, FilterBank=fb);
    scalograms(i_event, :, :) = cwt(eventlfp, 'FilterBank', fb); % Trying this line instead of 73 to troubleshoot
    
end
