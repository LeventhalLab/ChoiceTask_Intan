function event_triggered_lfps = extract_LFP_around_timestamps(ordered_lfp, trial_ts, t_win, Fs)

% INPUTS
%   ordered_lfp - this is an array m x n where m is the number of channels
%        and n is the number of samples. THIS MAY OR MAY NOT ACTUALLY BE
%        ORDERED DEPENDING ON WHAT WAS PASSED INTO THIS FUNCTION
%   ts - vector of timestamps. NOT an array of time ranges
%   t_win - 2-element vector with start and end time for each event
%   Fs - sampling rate in Hz
%
% OUTPUTS
%   event_triggered_lfps - num_events x num_channels x samples_per_event
%       containing lfp snips

% LFP_data = load(LFP_fname); grandfathered code when needing to load data
% in from fname
% LFP = LFP_data.ordered_lfp;

num_channels = size(ordered_lfp, 1);
num_samples = size(ordered_lfp, 2);
max_t = num_samples / 500;
valid_ts = trial_ts((trial_ts > -t_win(1)) | isnan(trial_ts));
valid_ts = valid_ts((valid_ts < max_t - t_win(2)) | isnan(trial_ts));

num_events = length(valid_ts);
samples_per_event = range(t_win) * Fs + 1; 

event_triggered_lfps = zeros(num_events, num_channels, samples_per_event);

for i_ts = 1 : num_events

    if isnan(trial_ts(i_ts))
        % trial_ts is assinged a value of NaN if that event does not exist
        % for that trial (e.g., foodClick on an incorrect trial)
        % if that happens, write NaNs into the event_triggered_lfps array
        current_lfp = NaN(num_channels, samples_per_event);
    else
        start_sample = floor(trial_ts(i_ts) * Fs);
        end_sample = start_sample + samples_per_event - 1;
        
        try
        current_lfp = ordered_lfp(:, start_sample:end_sample); % changed LFP to ordered_lfp for the calculate_cwt_3D_matrix script
        catch
            keyboard;
        end
    end
    
    event_triggered_lfps(i_ts, :, :) = current_lfp;
    
end

% mean_lfp = mean(event_triggered_lfps, 1);
    