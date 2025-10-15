function [ts_data,valid_trials, valid_trial_flags,valid_eventNames]=unit_correct_trial_data_RL(trials, trialfeatures,eventNames)

[valid_trials, valid_trial_flags] = extract_trials_by_features(trials, trialfeatures);

ts_data=struct(); 
valid_eventNames = {};

for i=1:length(eventNames)
    event_name=eventNames{i};
    % event_name=eventName{1};
    %extract trials by feature (incl. correct, wrong, moveright, moveleft, cudeleft, cuedright, falsestart) 

    
    %timestames from specific event during trial
    ts = ts_from_trials(valid_trials, event_name); 
    
    %remove any events that don't exist or contain nans for this trial feature type and
    %create data structure
    if ~contains(trialfeatures,'alltrials')
        if any(isnan(ts)) || any(ts==0)
            continue
        else
            ts_data.(event_name)=ts;
            valid_eventNames{end+1} = event_name;
        end 
    else
        ts = ts(~isnan(ts) & ts ~= 0);
        ts_data.(event_name)=ts;
        valid_eventNames{end+1}=event_name;
    end
    

end