load("\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask\R0492\R0492-processed\R0492_20230803a\R0492_20230803a_bipolar_lfp.mat")
load("\\corexfs.med.umich.edu\SharedX\Neuro-Leventhal\data\ChoiceTask\R0492\R0492-processed\R0492_20230803a\R0492_20230803a_trials.mat")

event_list = {'cueOn', 'centerIn', 'tone', 'centerOut', 'sideIn', 'sideOut', 'foodRetrieval', 'wrong', 'houseLightOn'};
n_events = length(event_list);

trial_types = {'alltrials', 'correct', 'cuedleft', 'movedleft', 'cuedright', 'movedright'};
n_trialtypes = length(trial_types);

% also will need a shuffle test for each of these

for i_trialtype = 1 : n_trialtypes
    for i_event = 1 : n_events

        

    end
end