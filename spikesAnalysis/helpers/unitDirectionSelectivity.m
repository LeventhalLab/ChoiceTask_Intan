function unitSelectivity=unitDirectionSelectivity(behavioralFeatures,spikeTimes,behaviorFields,directionSelectivityEvent,window,binSize,n_shuffles)

behaviorA=[];
behaviorB=[];
if isempty(binSize)
    binSize=0.02;
end
if isempty(n_shuffles)
    n_shuffles=1000;
end
if isempty(window)
    window=[-1 1];
end
for b=1:length(behaviorFields)
    behavior=behaviorFields{b};
    if isempty(behaviorA)
        behaviorA=behavior;
    else
        behaviorB=behavior;
    end
end

if isfield(behavioralFeatures,behaviorA)
    behaviorAstruct=behavioralFeatures.(behaviorA);
else
    behaviorAstruct=[];
end
if isfield(behavioralFeatures,behaviorB)
    behaviorBstruct=behavioralFeatures.(behaviorB);
else
    behaviorBstruct=[];
end 
unitSelectivity={};
if ~isfield(behaviorAstruct,directionSelectivityEvent) || ~isfield(behaviorBstruct,directionSelectivityEvent) 
    unitSelectivity='undeterminable';
    disp('cannot determine directional selectivity')
else
    psthDiffReal=behaviorAstruct.(directionSelectivityEvent).psthHz-behaviorBstruct.(directionSelectivityEvent).psthHz;
    
    behaviorAts=behaviorAstruct.(directionSelectivityEvent).timeStamps;
    behaviorBts=behaviorBstruct.(directionSelectivityEvent).timeStamps;
    
    
    [p_values,shuffle_data]=diffBehaviorShuffle(psthDiffReal,behaviorAts,behaviorBts,n_shuffles,binSize,spikeTimes,window);
    if isempty(p_values)
        unitSelectivity='undeterminable';
        disp('cannot determine directional selectivity')
        return
    end
    bins=behaviorAstruct.(directionSelectivityEvent).bins;
    time_window = [-0.2 0.4]; % in seconds
    
    % Find indices within that window
    keep_idx = bins >= time_window(1) & bins <= time_window(2);
    bins=bins(keep_idx);
    p_values_window=p_values(keep_idx);
    psthDiffWindow=psthDiffReal(keep_idx);
    unitSelectivity.shuffle_data=shuffle_data;
    try
        % 1. Find significant bins (p < 0.01)
        sig_mask = p_values_window < 0.01;
        % 2. Find two consecutive significant bins
        % Logical AND between shifted mask
        sig_consec = sig_mask(1:end-1) & sig_mask(2:end);
        % if any(sig_consec)
        %     keyboard
        % end
        % 3. Directionally selective if at least one pair of consecutive bins is significant
        if any(sig_consec)
            unitSelectivity=struct;
            first_consec_idx = find(sig_consec, 1, 'first');
            first_selective_time = bins(first_consec_idx);
            first_consec_idx=(bins==first_selective_time);
            magnitude=sum(abs(psthDiffWindow(sig_mask)));
            if psthDiffWindow(first_consec_idx) > 0
                psthHzA=behaviorAstruct.(directionSelectivityEvent).psthHz;
                psthHzA=psthHzA(keep_idx);
                unitSelectivity.direction='contralateral';
                unitSelectivity.psthDifferencesInWindow=psthDiffWindow;
                unitSelectivity.psthDifferencesReal=psthDiffReal;
                unitSelectivity.bins=bins;
                unitSelectivity.window=window;
                unitSelectivity.psthHz=psthHzA;
                unitSelectivity.pValues=p_values_window;
                unitSelectivity.selectiveTime=first_selective_time;
                unitSelectivity.pValuesInWindow=p_values_window;
                unitSelectivity.magnitude=magnitude;
                unitSelectivity.selectiveTime=first_selective_time;
            elseif psthDiffWindow(first_consec_idx) < 0
                psthHzA=behaviorBstruct.(directionSelectivityEvent).psthHz;
                psthHzA=psthHzA(keep_idx);
                unitSelectivity.direction='ipsilateral';
                unitSelectivity.psthDifferencesInWindow=psthDiffWindow;
                unitSelectivity.psthDifferencesReal=psthDiffReal;
                unitSelectivity.bins=bins;
                unitSelectivity.window=window;
                unitSelectivity.psthHz=psthHzA;
                unitSelectivity.pValues=p_values_window;
                unitSelectivity.magnitude=magnitude;
                unitSelectivity.selectiveTime=first_selective_time;
            else
                disp('significant bins but difference is zero? Low firing unit or low trial count')
                unitSelectivity='undeterminable';
                
            end
        else
            unitSelectivity.direction='NotDirectionallySelective';
        end
    catch ME
        disp(ME.message)
        keyboard
    end
end    

end

