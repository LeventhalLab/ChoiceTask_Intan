function [unique_clusters, numSpks, cluster_spikes] = unit_spike_activity(clu, st)
%Function to generate matrix with N rows for each unit's spike timestamps
% Inputs:
%  clu = spikeStruct.clu; (clusters from spikeStruct)
% st = spikeStruct.st; (spiketimes from spikeStruct)
unique_clusters = unique(clu); %Finds unique cluster ids
numSpks = nan(size(unique_clusters)); %number of total spikes for each unit
for a=1:length(unique_clusters)
    numSpks(a)=sum(clu==unique_clusters(a));
end 
cluster_spikes = nan(length(unique_clusters), max(numSpks)); %matrix of each unit's spike times in ms
for a=1:length(unique_clusters)
    cluster_spikes(a,1:sum(clu==unique_clusters(a)))=st(clu==unique_clusters(a))'.*1000;
end
end