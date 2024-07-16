function [LFP_out, rmep, com] = artifact_detect(LFP_in, varargin)
%
% INPUTS:
%   LFP_in - input LFP array. Could be m x n, in which case m is the number
%       of channels and each row is the LFP on that channel (n is the 
%       number of samples)
%           OR
%       m x n x p where m is the number of trials, n is
%       the number of channels, and p is the number of samples per trial 
% 
% VARARGs:
%
% OUTPUTS:
%

fprintf('\nRunning auto-rejection protocol...\n');
rmep = zeros(1,0);
alleps = [1:EEG.trials];
EEG = pop_eegthresh(EEG,1,[1:size(EEG.data,1)],-opt.threshold,opt.threshold,EEG.xmin,EEG.xmax,0,0);
numrej = length(find(EEG.reject.rejthresh));  % count number of epochs marked

% threshold artifact rejection; adapted from EEGLAB version 24.0