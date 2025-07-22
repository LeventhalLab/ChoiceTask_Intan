function [valid_trials, valid_trial_flags] = extract_trials_by_features(trials, trialfeatures)
% INPUTS
%   trials
%   trialfeatures - string containing trial features to extract. If any of
%       the following strings are containes in 'trialfeatures', the
%       following will be extracted. Can do this in any combination
%           'correct' - extracts correct trials
%           'wrong' - extracts incorrect trials
%           'moveright' - extracts trials in which rat moved right
%           'moveleft' - extracts trials in which rat moved left
%           'cuedleft' - extracts trials in which tone prompted rat to move
%               left
%           'cuedright' - extracts trials in which tone prompted rat to move
%               right
%           'falsestart' - extracts false start trials
%   Detailed explanation goes here

num_trials = length(trials);
valid_trial_flags = true(num_trials, 1);

%%%%%4/7
% if contains(lower(trialfeatures), 'all_correct_trials')
%     valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'correct', true);
% end
% if contains(lower(trialfeatures), 'correct_right')
%     valid_trial_flags = valid_trial_flags & (find_trials_by_field(trials, 'correct', true) && find_trials_by_field(trials, 'movementDirection', 2)) ;
% end
% if contains(lower(trialfeatures), 'correct_left')
%     valid_trial_flags = valid_trial_flags & (find_trials_by_field(trials, 'correct', true) && find_trials_by_field(trials, 'movementDirection', 2)) ;
% end
% if contains(lower(trialfeatures), 'all_wrong')
%     valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'correct', false);
% end
% 
% if contains(lower(trialfeatures), 'moveright')
%     valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'movementDirection', 2);
% end
% 
% if contains(lower(trialfeatures), 'moveleft')
%     valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'movementDirection', 1);
% end
% 
% if contains(lower(trialfeatures), 'cuedleft')
%     valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'tone', 1);
% end
% 
% if contains(lower(trialfeatures), 'cuedright')
%     valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'tone', 2);
% end
% 
% if contains(lower(trialfeatures), 'falsestart')
%     valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'falseStart', 1);
% end
for i = 1:length(trialfeatures)
    feature = lower(trialfeatures{i});
    if strcmp(feature,'alltrials')
        valid_trial_flags=valid_trial_flags;
    elseif strcmp(feature, 'correct')
        valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'correct', true);
    elseif strcmp(feature, 'correct_right')
        valid_trial_flags = valid_trial_flags & ...
            find_trials_by_field(trials, 'correct', true) & ...
            find_trials_by_field(trials, 'movementDirection', 2);
    elseif strcmp(feature, 'correct_left')
        valid_trial_flags = valid_trial_flags & ...
            find_trials_by_field(trials, 'correct', true) & ...
            find_trials_by_field(trials, 'movementDirection', 1); % <== this was originally wrong
    elseif strcmp(feature, 'wrong')
        valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'correct', false);
    elseif strcmp(feature, 'moveright')
        valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'movementDirection', 2);
    elseif strcmp(feature, 'moveleft')
        valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'movementDirection', 1);
    elseif strcmp(feature, 'cuedleft')
        valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'tone', 1);
    elseif strcmp(feature, 'cuedright')
        valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'tone', 2);
    elseif strcmp(feature, 'slowmovement')
        valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'movementTooLong', 1);
    elseif strcmp(feature, 'slowreaction')
        valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'holdTooLong', 1);
    elseif strcmp(feature, 'falsestart')
        valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'falseStart', 1);
    elseif strcmp(feature, 'wrongstart')
        valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'invalidNP', 1);
    end
end
%%%%%2025
valid_trials = trials(valid_trial_flags);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function is_valid_trial = find_trials_by_field(trials, field, value)

num_trials = length(trials);
is_valid_trial = false(num_trials, 1);

for i_trial = 1 : num_trials
    is_valid_trial(i_trial) = (trials(i_trial).(field) == value);
end

end