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
if contains(lower(trialfeatures), 'correct')
    valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'correct', true);
end

if contains(lower(trialfeatures), 'wrong')
    valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'correct', false);
end

if contains(lower(trialfeatures), 'moveright')
    valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'movementDirection', 1);
end

if contains(lower(trialfeatures), 'moveleft')
    valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'movementDirection', 2);
end

if contains(lower(trialfeatures), 'cuedleft')
    valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'tone', 1);
end

if contains(lower(trialfeatures), 'cuedright')
    valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'tone', 2);
end

if contains(lower(trialfeatures), 'falsestart')
    valid_trial_flags = valid_trial_flags & find_trials_by_field(trials, 'falseStart', 1);
end

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