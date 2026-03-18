function [unitFRRTMTcorrelations]=unitZscoreFRvsRTMT(regionUnits, params,unitFRRTMTcorrelations)
% unitFRvsRTMT
%
% This function computes per-trial firing rates for individual single units
% in sliding time windows around a behavioral event (center-out), and
% associates those firing rates with reaction time (RT) and movement time (MT)
% on a trial-by-trial basis.
%
% For each unit that passes filtering criteria:
%   - Trials are selected based on a behavioral feature (e.g., 'correct')
%   - Spike times are aligned to the center-out event (t = 0)
%   - A sliding window analysis is performed from -1 to +1 seconds
%     around center-out, using:
%         • 200 ms window width
%         • 50 ms step size
%   - For each trial and each time bin:
%         • Spikes within the bin are counted
%         • Firing rate (Hz) is computed
%
% Reaction Time (RT) is defined as:
%     RT = centerOut - tone
%
% Movement Time (MT) is defined as:
%     MT = sideIn - centerOut
%
% All computations are performed per trial. Trials with missing or NaN
% timestamps are skipped. No plotting or correlation is performed in this
% function; the output variables are intended for downstream analysis
% (e.g., per-bin correlation of firing rate vs RT/MT).
%
% Inputs:
%   regionUnits : struct
%       Contains single-unit data, spike timestamps, unit metrics,
%       and behavioral trial structures.
%
%   params : struct
%       Must contain:
%           params.behaviorField
%           params.combinedRegionFlag
%           params.excludeMatchUnits
%           (and other filtering-related parameters used below)
%
% Notes:
%   - Spike timestamps (unit.unitMetrics.clusterSpikes) are assumed to be in
%     absolute time (seconds), in the same timebase as behavioral timestamps.
%   - Sliding bins are half-open intervals: [binStart, binEnd)
%     to avoid double-counting spikes at bin edges.
%

    unitNames = fields(regionUnits);
    behavior = params.behaviorField;
    ratIDs = cellfun(@(x) regexp(x, 'R0\d{3}', 'match', 'once'), ...
                 unitNames, 'UniformOutput', false);
    ratIDs = unique(ratIDs);
    
for r = 1:length(ratIDs)
    ratID = ratIDs{r};
    if isempty(ratID)
        continue
    end
    if~startsWith(ratID,'R') && (params.combinedRegionFlag==0)
        continue
    end
    filteredUnitNames = {};

    % -----------------------------
    % Unit filtering loop
    % -----------------------------
    for uu = 1:length(unitNames)
        uid = unitNames{uu};
        if ~contains(uid,ratID)
            continue
        end              
        if ~startsWith(uid,'R') && (params.combinedRegionFlag == 0)
            continue
        end
        if ~isfield(regionUnits.(uid),'unitMetrics')
            continue
        end
        if ~isfield(regionUnits.(uid).behavioralFeatures, behavior)
            continue
        end

        unit = regionUnits.(uid);

        if ~isfield(unit.unitMetrics,'unitClass')
            continue
        end

        % treatment handling
        if isfield(unit.unitMetrics,'treatement')
            treatment = unit.unitMetrics.treatement;
        elseif isfield(unit.unitMetrics,'treatment')
            treatment = unit.unitMetrics.treatment;
        else
            treatment = '';
        end

        unitClass = unit.unitMetrics.unitClass;

        % direction dependence handling
        if isfield(unitClass,'directionDependence')
            dd = unitClass.directionDependence;
            if isstruct(dd) && isfield(dd,'direction')
                noseOutResponsiveness = dd.direction;
            else
                noseOutResponsiveness = dd;
            end
        else
            noseOutResponsiveness = 'undeterminable';
        end

        % Apply filters (unchanged logic)
        % if ~isempty(params.treatmentToProcess) && ischar(params.treatmentToProcess)
        %     if ~strcmp(params.treatmentToProcess, treatment)
        %         continue
        %     end
        % end
        if params.excludeUndeterminable && strcmp(noseOutResponsiveness,'undeterminable')
            continue
        end
        if params.excludeNonSelectiveUnits && strcmp(noseOutResponsiveness,'NotDirectionallySelective')
            continue
        end
        if params.excludeNonResponsive && ...
                isfield(unitClass,'type') && strcmp(unitClass.type,'nonResponsive')
            continue
        end
        if params.excludeSelectiveUnits && ...
                (strcmp(noseOutResponsiveness,'ipsilateral') || ...
                 strcmp(noseOutResponsiveness,'contralateral'))
            continue
        end
        if params.excludeIpsilateral && strcmp(noseOutResponsiveness,'ipsilateral')
            continue
        end
        if params.excludeContralateral && strcmp(noseOutResponsiveness,'contralateral')
            continue
        end

        filteredUnitNames{end+1} = uid; %#ok<AGROW>
    end

    if isempty(filteredUnitNames)
        warning('No units survived filtering for behavior "%s"', behavior);
        return
    end

    % -----------------------------
    % Per-unit FR vs RT/MT extraction
    % -----------------------------
    for uu = 1:length(filteredUnitNames)
        uid = filteredUnitNames{uu};
        unit = regionUnits.(uid);
        if isfield(unitClass,'directionDependence')
            dd = unit.unitMetrics.unitClass.directionDependence;
            if isstruct(dd) && isfield(dd,'direction')
                noseOutResponsiveness = dd.direction;
            else
                noseOutResponsiveness = dd;
            end
        else
            noseOutResponsiveness = 'undeterminable';
        end
        if isfield(unit.unitMetrics,'treatement')
            treatment = unit.unitMetrics.treatement;
        elseif isfield(unit.unitMetrics,'treatment')
            treatment = unit.unitMetrics.treatment;
        else
            treatment = '';
        end
        session = regexp(uid, '(?<=R\d+_)[^_]+', 'match', 'once');
        session = strcat('date_',session);
        spikes = unit.unitMetrics.clusterSpikes/1000;
        if ~isfield(unit.behavioralFeatures.(behavior),'valid_trials')
            continue  
        end
        trials = unit.behavioralFeatures.(behavior).valid_trials;

        % Sliding bin parameters
        binWidth = 0.200;   % seconds
        binStep  = 0.050;   % seconds
        winStart = -1.0;
        winEnd   =  1.0;

        binCenters = winStart : binStep : (winEnd - binWidth);
        nBins = length(binCenters);
        unitFR=unit.unitMetrics.meanFiringRate;
        unitSD=unit.unitMetrics.stdMeanFR;
        for t = 1:length(trials)
            trial = trials(t);

            % Skip trials with missing timestamps
            if ~isfield(trial.timestamps, 'tone') || ...
                isempty(trial.timestamps.tone) || ...
                ~isfield(trial.timestamps, 'centerOut') || ...
               isempty(trial.timestamps.centerOut) || ...
                ~isfield(trial.timestamps, 'sideIn') || ...
               isempty(trial.timestamps.sideIn)
                continue
            end
            if any(isnan([trial.timestamps.tone, ...
                          trial.timestamps.centerOut, ...
                          trial.timestamps.sideIn]))
                continue
            end

            % Preallocate on first valid trial
            if t == 1
                zScoreFR_perTrial = nan(length(trials), nBins);
                RT_all = nan(length(trials),1);
                MT_all = nan(length(trials),1);
            end

            % Event timestamps
            coEventTs = trial.timestamps.centerOut;
            toneTs    = trial.timestamps.tone;
            sideInTs  = trial.timestamps.sideIn;

            % Reaction and movement times
            RT_all(t) = coEventTs - toneTs;
            MT_all(t) = sideInTs - coEventTs;

            % Extract spikes in analysis window
            absWinStart = coEventTs + winStart;
            absWinEnd   = coEventTs + winEnd;

            spikesInWindow = spikes(spikes >= absWinStart & spikes <= absWinEnd);

            % Sliding window spike counts
            for b = 1:nBins
                binStart = coEventTs + binCenters(b);
                binEnd   = binStart + binWidth;

                nSpikes = sum(spikesInWindow >= binStart & ...
                              spikesInWindow <  binEnd);

                zScoreFR_perTrial(t,b) = (((nSpikes / binWidth)-unitFR)/unitSD); % Hz
            end
        end
        % -----------------------------
        % Per-bin FR vs RT regression
        % -----------------------------
        RT_beta = nan(1, nBins);
        RT_p    = nan(1, nBins);
        RT_r2   = nan(1, nBins);
        
        for b = 1:nBins
            y = zScoreFR_perTrial(:, b);   % firing rate
            x = RT_all;              % reaction time
        
            validIdx = ~isnan(x) & ~isnan(y);
        
            if sum(validIdx) < 3
                continue
            end
        
            X = x(validIdx);
            Y = y(validIdx);
        
            mdl = fitlm(X, Y);  % Y = beta0 + beta1*X
        
            RT_beta(b) = mdl.Coefficients.Estimate(2);   % slope
            RT_p(b)    = mdl.Coefficients.pValue(2);     % p-value for slope
            RT_r2(b)   = mdl.Rsquared.Ordinary;   % r^2
            if params.plotScatter && RT_p(b)<0.05
                % x = RT or MT per trial (seconds)
                xVals = RT_all;        % or MT_allTrials
                
                % y = firing rate per trial for bin n (Hz)
                yVals = zScoreFR_perTrial(:,b);         % 1 x nTrials or nTrials x 1
                
                % remove NaNs (safety)
                valid = ~isnan(xVals) & ~isnan(yVals);
                x = xVals(valid);
                y = yVals(valid);
                
                % --- fit (if not already saved) ---
                p = polyfit(x, y, 1);        % linear regression
                xFit = linspace(min(x), max(x), 100);
                yFit = polyval(p, xFit);
                
                % --- plot ---
                figure; hold on
                scatter(x, y, 40, 'k', 'filled')
                plot(xFit, yFit, 'r', 'LineWidth', 2)
                
                xlabel('Reaction Time (s)')   % or 'Movement Time (s)'
                ylabel('Firing Rate (Hz)')
                title(sprintf('Bin %d: FR vs RT', n))
                
                box off
                set(gca,'TickDir','out')
            end
        end
        % -----------------------------
        % Per-bin zFR vs MT regression
        % -----------------------------
        MT_beta = nan(1, nBins);
        MT_p    = nan(1, nBins);
        MT_r2   = nan(1, nBins);
        
        for b = 1:nBins
            y = zScoreFR_perTrial(:, b);
            x = MT_all;
        
            validIdx = ~isnan(x) & ~isnan(y);
        
            if sum(validIdx) < 3
                continue
            end
        
            X = x(validIdx);
            Y = y(validIdx);
        
            mdl = fitlm(X, Y);
        
            MT_beta(b) = mdl.Coefficients.Estimate(2);
            MT_p(b)    = mdl.Coefficients.pValue(2);
            MT_r2(b)   = mdl.Rsquared.Ordinary;
        end

        unitFRRTMTcorrelations.(treatment).(ratID).(session).binCenters = binCenters;
        
        
        unitFRRTMTcorrelations.(treatment).(ratID).(session).RT_perTrial=RT_all;
        unitFRRTMTcorrelations.(treatment).(ratID).(session).MT_perTrial=MT_all;
        unitFRRTMTcorrelations.(treatment).(ratID).(session).units.(uid).zScoreFR_perTrial=zScoreFR_perTrial;
        unitFRRTMTcorrelations.(treatment).(ratID).(session).units.(uid).noseOutResponsiveness=noseOutResponsiveness;

        unitFRRTMTcorrelations.(treatment).(ratID).(session).units.(uid).zScoredRTcorrResults.beta = RT_beta;
        unitFRRTMTcorrelations.(treatment).(ratID).(session).units.(uid).zScoredRTcorrResults.p    = RT_p;
        unitFRRTMTcorrelations.(treatment).(ratID).(session).units.(uid).zScoredRTcorrResults.r2   = RT_r2;
        
        unitFRRTMTcorrelations.(treatment).(ratID).(session).units.(uid).zScoredMTcorrResults.beta = MT_beta;
        unitFRRTMTcorrelations.(treatment).(ratID).(session).units.(uid).zScoredMTcorrResults.p    = MT_p;
        unitFRRTMTcorrelations.(treatment).(ratID).(session).units.(uid).zScoredMTcorrResults.r2   = MT_r2;

        % regionUnits.unitFRRTMTcorrelations.(treatment).(behavior).(ratID).(noseOutResponsiveness).(uid).binCenters = binCenters;
        % 
        % regionUnits.unitFRRTMTcorrelations.(treatment).(behavior).(ratID).(noseOutResponsiveness).(uid).RT.beta = RT_beta;
        % regionUnits.unitFRRTMTcorrelations.(treatment).(behavior).(ratID).(noseOutResponsiveness).(uid).RT.p    = RT_p;
        % regionUnits.unitFRRTMTcorrelations.(treatment).(behavior).(ratID).(noseOutResponsiveness).(uid).RT.r2   = RT_r2;
        % 
        % regionUnits.unitFRRTMTcorrelations.(treatment).(behavior).(ratID).(noseOutResponsiveness).(uid).MT.beta = MT_beta;
        % regionUnits.unitFRRTMTcorrelations.(treatment).(behavior).(ratID).(noseOutResponsiveness).(uid).MT.p    = MT_p;
        % regionUnits.unitFRRTMTcorrelations.(treatment).(behavior).(ratID).(noseOutResponsiveness).(uid).MT.r2   = MT_r2;

        % At this point, for this unit:
        %   FR_perTrial : [nTrials x nBins]
        %   RT_all      : [nTrials x 1]
        %   MT_all      : [nTrials x 1]
        %   binCenters  : relative to center-out
    end
end
end