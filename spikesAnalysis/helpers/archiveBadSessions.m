function regionUnits=archiveBadSessions(regionUnits,badsession)
%% script to archive units that are from bad sessions%%
unitNames=fieldnames(regionUnits);
for u=1:length(fieldnames(regionUnits))
    uid=unitNames{u};
    if any(strfind(uid,badsession))
        regionUnits.previouslyCurated.badSessions.(uid)=regionUnits.(uid);
        regionUnits=rmfield(regionUnits,uid);
    end
end