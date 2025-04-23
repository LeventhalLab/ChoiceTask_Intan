function [spikeStruct, clu, st, unique_clusters, numSpks, cluster_spikes] = import_ephys_data_RL(ephysKilosortPath)
%function to pull all kilosort and intan data into matlab, generate spike
%structure, and pull desired timestamps based off selected event
% Inputs: 
% Intan folder - output from ChoiceTask Intan Function - path to session
% data folder
% trials - output from ChoiceTask Intan Function - struct of trials during
% session
% trialfeatures - selected trial feature (Features: correct, incorrect,
% moveright, moveleft, cuedleft, cuedright, falsestart)
% event_name - seclected event 
% Events - cueOn, centerIn, centerOut, tone, sideIn, sideOut, foodclick, foodRetrieval


%Loading all Kilosort Data
spikeStruct = loadKSdir_RL(ephysKilosortPath);
%calculate amplitudes 
% [spikeStruct.spikeAmps, spikeStruct.spikeDepths, spikeStruct.templateDepths, spikeStruct.templateXpos,...
%     spikeStruct.tempAmps, spikeStruct.tempsUnW, spikeStruct.templateDuration, spikeStruct.waveforms] = ...
%     templatePositionsAmplitudes(spikeStruct.temps, spikeStruct.winv, spikeStruct.ycoords, spikeStruct.xcoords,...
%     spikeStruct.spikeTemplates, spikeStruct.tempScalingAmps); %from the spikes toolbox
% templateWaveforms=spikeStruct.temps;
% 
% spikeStruct = RemoveNoiseAmplitudeBased(spikeStruct);
if ~isempty(spikeStruct)
    clu = spikeStruct.clu;
    st = spikeStruct.st;
    
    %Generate matrix with N rows for each unit's spike timestamps
    [unique_clusters, numSpks, cluster_spikes] = unit_spike_activity(clu, st);


else 
    ksDir = [];
    clu = [];
    st = [];
    unique_clusters = [];
    numSpks = [];
    cluster_spikes = [];
    valid_trials = [];
    valid_trial_flags = [];
    ts = [];
end