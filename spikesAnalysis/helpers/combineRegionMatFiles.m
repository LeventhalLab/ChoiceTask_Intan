parentDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
% allEntries = dir(parentDir);
% isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
% regionsAvailable = {allEntries(isSubFolder).name};
regionsAvailable={'VM'};
% % Load both region files
for i = 1:length(regionsAvailable)
    region = regionsAvailable{i};
    
    regionSummaryPath=fullfile(parentDir,region);
    % Define paths
    regionFile = fullfile(regionSummaryPath, [region '_unitSummary.mat']);
    regionFileALL = fullfile(regionSummaryPath, [region '_unitSummaryALLTRIALS.mat']);

    if isfile(regionFile) && isfile(regionFileALL)
        % Loads regionUnits
        disp('Loading first mat file')
        tic
        load(regionFile, 'regionUnits');
        toc    
        disp('First mat file loaded now loading the second')
        tic
        loaded = load(regionFileALL, 'regionUnits');  % Load into a struct
        toc
        disp('Both mat files loaded')
        regionUnitsAll = loaded.regionUnits;
    
        % Iterate over units
        unitIDs = fieldnames(regionUnitsAll);
        totalUnitNumber = numel(unitIDs);
        for u = 1:numel(unitIDs)
            unitID = unitIDs{u};
            fprintf('Processing unit %d out of %d: %s\n', u, totalUnitNumber, unitID);
            % If this unit exists in the original file
            if isfield(regionUnits, unitID)
                % If behavioralFeatures exists in both
                if isfield(regionUnitsAll.(unitID), 'behavioralFeatures')
                    % Initialize behavioralFeatures field if not present
                    if ~isfield(regionUnits.(unitID), 'behavioralFeatures')
                        regionUnits.(unitID).behavioralFeatures = struct();
                    end
    
                    % Copy each behavioral feature field
                    behaviorFields = fieldnames(regionUnitsAll.(unitID).behavioralFeatures);
                    for b = 1:numel(behaviorFields)
                        feature = behaviorFields{b};
                        regionUnits.(unitID).behavioralFeatures.(feature) = ...
                            regionUnitsAll.(unitID).behavioralFeatures.(feature);
                    end
                end
            else
                % If unit is missing entirely, optionally add it
                keyboard
                regionUnits.(unitID) = regionUnitsAll.(unitID);
            end
        end
    
        % Save the merged structure back to _unitSummary.mat
        disp('saving new file')
        tic
        save(regionFile, 'regionUnits');
        toc
        disp('New file saved')
        fprintf('Merged behavioral features from %s into %s\n', regionFileALL, regionFile);
    else
        keyboard
        disp('One or both region files not found.');
    end
end