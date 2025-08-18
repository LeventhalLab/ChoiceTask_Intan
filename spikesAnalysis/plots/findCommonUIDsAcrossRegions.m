function commonUIDs = findCommonUIDsAcrossRegions(parentDir)
    % Initialize
    allEntries = dir(parentDir);
    isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
    regionsAvailable = {allEntries(isSubFolder).name};
    
    uidSets = cell(1, numel(regionsAvailable));
    
    % Loop through each region and extract UIDs
    for i = 1:numel(regionsAvailable)
        region = regionsAvailable{i};
        unitTableFile = fullfile(parentDir, region, strcat(region, '_unitTable.mat'));
        
        if exist(unitTableFile, 'file')
            S = load(unitTableFile);  % should contain unitTable
            if isfield(S, 'unitTable')
                unitTable = S.unitTable;
                if ismember('MatchedUnitID', unitTable.Properties.VariableNames)
                    uidSets{i} = unique(unitTable.MatchedUnitID);
                else
                    warning('No UID column in %s', unitTableFile)
                end
            else
                warning('No unitTable in %s', unitTableFile)
            end
        else
            warning('File not found: %s', unitTableFile)
        end
    end
    
    % Intersect UIDs across all non-empty regions
    nonEmptySets = uidSets(~cellfun(@isempty, uidSets));
    if isempty(nonEmptySets)
        commonUIDs = [];
        warning('No UID sets found.')
        return;
    end

    commonUIDs = nonEmptySets{1};
    for i = 2:length(nonEmptySets)
        commonUIDs = intersect(commonUIDs, nonEmptySets{i});
    end

    fprintf('Found %d common UIDs across all regions.\n', numel(commonUIDs));
end