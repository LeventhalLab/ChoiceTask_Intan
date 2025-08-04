function regionUnits=archiveReprocessedSessionUnits(regionUnits,sessions_to_process)
unitNames = fields(regionUnits);
if isfield(regionUnits,'previouslyCurated')
    disp('careful there are already sessions that have been removed because of previous curation or reprocessing')
    keyboard

end

previouslyCurated=struct;
for u = 1:length(unitNames)
    unitID = unitNames{u};
    
    % Skip special fields
    if ismember(unitID, {'unitCount', 'regionMetrics', 'previouslyCurated'})
        continue;
    end
    
    % Check if unitID starts with the session_name
    for s=1:length(sessions_to_process)
        processedSessionID=sessions_to_process{s};
        if startsWith(unitID, processedSessionID)
            if isfield(regionUnits,'previouslyCurated') && isfield(regionUnits.previouslyCurated, unitID)
                
                disp('Session already archived archived do you need to remove again? If so consider renaming untis')
                keyboard
                previouslyCurated.(unitID)=regionUnits.(unitID);
            else
                previouslyCurated.(unitID) = regionUnits.(unitID);
            end
            
        end
    end
end

% Remove these units from regionUnits
if isfield(regionUnits, 'previouslyCurated')
    
    curatedUnitNames=fieldnames(regionUnits.previouslyCurated);
    
else
    curatedUnitNames = fieldnames(previouslyCurated);
end
for i = 1:length(curatedUnitNames)
    if ~isfield(regionUnits,curatedUnitNames{i})
        continue
    else
        regionUnits = rmfield(regionUnits, curatedUnitNames{i});
    end
end

% Add or merge into .previouslyCurated field
if isfield(regionUnits, 'previouslyCurated')
    regionUnits.previouslyCurated = mergeStructs(regionUnits.previouslyCurated, previouslyCurated);
else
    regionUnits.previouslyCurated = previouslyCurated;
end
