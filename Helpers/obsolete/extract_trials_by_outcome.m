function [outputArg1,outputArg2] = extract_trials_by_outcome(trials, trialoutcome)
% INPUTS
%   trials
%   trialoutcome
%   Detailed explanation goes here

valid_trial_idx = 
if contains(lower(trialoutcome), 'correct')
    
end

if contains(lower(trialoutcome), 'moveright')

end

if contains(lower(trialoutcome), 'moveleft')

end
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end


function is_valid_trial = find_trials_by_field(trials, field, value)

num_trials = length(trials);

for i_trial = 1 : num_trials

    