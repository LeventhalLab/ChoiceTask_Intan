
function [ephysProperties, unitClassif] = runAllEphysProperties(ephysPath, ephysRawFile,savePath, gain_to_uV, rerunEP, region)


%% compute ephys properties 
ephysPropertiesExist = dir(fullfile(savePath, 'templates._bc_ephysProperties.parquet'));
ephysMetaDir='NaN';

if isempty(ephysPropertiesExist) || rerunEP
    paramEP = bc.ep.ephysPropValues(ephysMetaDir, ephysRawFile, ephysPath, gain_to_uV);
    [spikeTimes_samples, spikeTemplates, templateWaveforms, templateAmplitudes, ...
    pcFeatures, ~, channelPositions] = bc.load.loadEphysData(ephysPath, savePath);
    ephysProperties = bc.ep.computeAllEphysProperties(spikeTimes_samples, spikeTemplates, templateWaveforms,...
        templateAmplitudes, pcFeatures, channelPositions, paramEP, savePath);

elseif ~isempty(ephysPropertiesExist)
    [paramEP, ephysProperties, ~] = bc.ep.loadSavedProperties(savePath); 
end

%% classify cells 
if ~isempty(region) &&...
        ismember(region, {'CP', 'STR', 'Striatum', 'DMS', 'DLS', 'PS',...
        'Ctx', 'Cortical', 'Cortex'}) % cortex and striaum spelled every possible way 
    unitClassif = bc.clsfy.classifyCells(ephysProperties, paramEP, region);
    
else
    unitClassif = nan(size(ephysProperties,1),1);
end

end