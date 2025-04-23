function scalingFactors = getAnalogToVoltageScaling(param) 

%%Attempting to avoid error where conditional tries to readSpikeGLXMetaFile
%%whcich doesn't exist. Bombcell runs just fine without meta files so not
%%sure why this thinks param.ephysMetaFile isn't NaN RL 01/09/25
param.ephysMetaFile='NaN';


% get scaling factor 
if strcmp(param.ephysMetaFile, 'NaN') == 0
    if contains(param.ephysMetaFile, 'oebin')
        % open ephys format
        scalingFactor = bc.load.readOEMetaFile(param.ephysMetaFile); % single sclaing factor per channel for now 
        scalingFactors = repmat(scalingFactor, [param.nChannels - param.nSyncChannels, 1]);
    else
        % spikeGLX format
        [scalingFactors, ~, ~] = bc.load.readSpikeGLXMetaFile(param);
    end
else
     scalingFactors = repmat(param.gain_to_uV, [param.nChannels - param.nSyncChannels, 1]);
end
