% plot periEvent information by trial type - using correctgo as my initial
% practice testing of the information pulled from getTrialEventParams,
% extractTrials, periEventTrialTs and the ChoiceTaskIntan Workflow (e.g.
% trialStruct/log data). 

trialRanges_by_frequency = trialRanges * 20000; %Multiply the trialRange Ts by recording frequency (20kHz)
% x = trialRanges_by_frequency(1,1,:);
%Write code here to squeeze the multidimentional array created from
%periEventTrialTs into a single dimensional array. This will make finding
%the values for the plot easier.
%For example: A = squeeze(trialRanges(1,1,:)); Use this in a for loop and
%concatanate? 
A = squeeze(trialRanges(1,1,:));
A_by_frequency = A * 20000;
y = lfp_NNsite_diff(1,:);
plot(A_by_frequency, lfp_NNsite_diff);
