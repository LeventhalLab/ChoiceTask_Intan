function [clean_lfp, artifact_mask] = reject_artifacts(lfp_data, threshold, min_duration)
    % Reject artifacts based on amplitude threshold
    %
    % INPUTS:
    %   lfp_data - num_channels x num_samples matrix of LFP data
    %   threshold - amplitude threshold for detecting artifacts (in microvolts)
    %   min_duration - minimum duration (in samples) for an artifact to be considered
    %
    % OUTPUTS:
    %   clean_lfp - LFP data with artifacts removed
    %   artifact_mask - binary mask indicating artifact regions (1 = artifact, 0 = clean)

    num_channels = size(lfp_data, 1);
    num_samples = size(lfp_data, 2);
    
    % Initialize the clean_lfp and artifact_mask
    clean_lfp = lfp_data;
    artifact_mask = zeros(num_channels, num_samples);
    
    % Loop through each channel to detect and reject artifacts
    for ch = 1:num_channels
        % Detect artifacts based on amplitude threshold
        artifact_indices = find(abs(lfp_data(ch, :)) > threshold);
        
        % Mark artifacts in the artifact_mask
        for i = 1:length(artifact_indices)
            idx = artifact_indices(i);
            % Ensure artifact duration is met
            if (i == 1) || (artifact_indices(i) - artifact_indices(i-1) > min_duration)
                start_idx = max(1, idx - min_duration);
                end_idx = min(num_samples, idx + min_duration);
                artifact_mask(ch, start_idx:end_idx) = 1;
            end
        end
        
        % Zero out artifact regions in clean_lfp
        clean_lfp(ch, artifact_mask(ch, :) == 1) = 0;
    end
end
