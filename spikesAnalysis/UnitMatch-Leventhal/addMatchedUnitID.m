%Script to store units that are recorded within a given region of interest in a matfile.
% Code calculates psth and rasters for all units within a given choice task beahvioral assays
%by using behaviorA and behaviorB, user can look at any behavioral events
%of interest possible in the choice task by combining possible options along
% with incompatible behavioral options listed in parentheses or risk throwing error.
% Mat files are stored in Neuro-Leventhal/data/ChoiceTask/RegionSummary
%% Options include
    %alltrials- extracts all trials
    %correct- only correct trials (no wrong,slowmovement,slowreaction,falsestart,wrongstart)
    
    %wrong-only wrong trials (no correct)
    
    %moveright- the side direction the rat moved was to the right 
    % (no moveleft,slowmovement,slowreaction,falsestart,wrongstart)
    
    %moveleft- the side direction the rat moved was to the right 
    %(no moveright slowmovement,slowreaction,falsestart,wrongstart)
    
    %cuedright- rat was instructed to go right 
    % (no cuedleft,wrongstart,falsestart)
    
    %cuedleft- rat was instructed to go left
    % (no cuedright,wrongstart,falsestart)
    
    %slowmovement-rat was too slow to getting to side port
    % (no moveleft,moveright,correct,wrongstart,falsestart)
    
    %slowreaction-rat was too slow leaving centerport
    % (no moveleft,moveright,correct,wrongstart,falsestart)
    
    %wrongstart-rat poked to wrong centerport 
    % (not compatible with other behaviors besides wrong)
    
    %falsestart-rat poked badly to centerport 
    % (not compatible with other behaviors besisdes wrong)


%% Set up parent directories and ignore rat ids not interested in


parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls_dir = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);
sessions_to_ignore = {'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a','R0427_20220919a','R0479_20230601a',}; % 'R0493_20230720a' R0425_20220728a debugging because the intan side was left on for 15 hours;

processSpecificSessions=0;% do you want to only process a specific subset of sessions?
removeOldUnits=0; %do you want to remove the units from this session that were previously processed?
if processSpecificSessions
    sessions_to_process={};
    ratsToReprocess={};
    [regionsAvailable]=regionFinder(ratsToReprocess);
else
    regionDir = 'X:\Neuro-Leventhal\data\ChoiceTask\RegionalSummary';
    allEntries = dir(regionDir);
    % Filter only directories, excluding '.' and '..'
    isSubFolder = [allEntries.isdir] & ~ismember({allEntries.name}, {'.', '..'});
    regionsAvailable = {allEntries(isSubFolder).name};
end
probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER%
% INFORMATION OUT OF THAT SPREADSHEET

%[rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();
ratIDs=probe_types.ratID;
ignoreRats={'R0326','R0327','R0372','R0374','R0379','R0376','R0378','R0394','R0395','R0396','R0411','R0412','R0413','R0419',...
            'R0425','R0427','R0456','R0459','R0546'};%,'R0420','R0460','R0463','R0466','R0465','R0467','R0492','R0494','R0495','R0493',''
num_rats = length(ratIDs);
ignoreTheseRegions=1;
ignoreRegions={'AHP','LH','Mt','Mt-VM','PLH','PaPo','PefLH-LH','Rt','Rt-VA','SubI','VA-VPL-VM','VL','VL-VPL','VL-VPL-VPM','VM','cbRecipients','cbRecipientsBroad','VM-AM','VM-VL'};


%% Loop through all rats and locate any ephys sessions with Kilosort data
wholeSetTimer=tic;
T=zeros(1,length(regionsAvailable));
for r=1:length(regionsAvailable)
    regionOfinterest=regionsAvailable{r};
    if ignoreTheseRegions
        if any(strcmp(regionOfinterest,ignoreRegions))
            fprintf('Ignoring %s\n',regionOfinterest)
            continue
        end
    end
    regionOfinterest=strrep(regionOfinterest,'/','-');
    tic
    fprintf('Working on region %s\n',regionOfinterest)
    regionSummaryPath=fullfile(parent_directory,'RegionalSummary');
    regionSummaryPath=fullfile(regionSummaryPath,regionOfinterest);
    regionFile = fullfile(regionSummaryPath, [regionOfinterest '_unitSummary.mat']);
    if isfile(regionFile)
        fprintf('Loading region %s\n',regionOfinterest)
        load(regionFile);
        disp('region loaded')
    else
        regionUnits=struct();
    end
    
  for i_rat = 1 : num_rats
        ratID = ratIDs{i_rat};
        
        rat_folder = fullfile(parent_directory, ratID);
        if any(strcmp(ratID,ignoreRats))
            continue
        end
        if ~isfolder(rat_folder)
            continue;
        end
         % Create variable that contains channel-region information
        ratHisto=strcat(ratID,'_','finished');
        ratTreatment=probe_types.Treatment{i_rat};
        histo_data = readtable(summary_xls,'filetype','spreadsheet',...
                'sheet',ratHisto,...
                'texttype','string');
        channelRegion=[histo_data.Intan_Site_Number,histo_data.Region];
        channelRegion(:, 1) = cellfun(@(x) num2str(str2double(x)), channelRegion(:, 1), 'UniformOutput', false); %changed back to zero scale 4/15
        regionOfinterest=strrep(regionOfinterest,'/','-');%Matlab doesnt like slashes
        channelRegion=strrep(channelRegion,'/','-');
        if ~any(ismember(regionOfinterest,channelRegion(:,2)))
            fprintf('No electrodes from this rat contain region of interest skipping... %s\n',ratID)
            
            continue
        end
        UMoutputDir=fullfile(rat_folder,'MatchingUnits\UnitMatch');
        UMstruct={};
        UMstruct=load(fullfile(UMoutputDir,'UnitMatch.mat'));
        regionUnits=findUnitMatches(UMstruct,regionUnits);
      

  end
    
    fprintf('Saving summary mat file for %s\n',regionOfinterest)
    [unitTable,saveRegionFlag]=regionStatistics(regionUnits);
    saveFileName = fullfile(regionSummaryPath, strcat(regionOfinterest, '_unitTable.mat'));
    csvFileName = fullfile(regionSummaryPath, strcat(regionOfinterest, '_unitTable.csv'));
    save(saveFileName, 'unitTable');
    writetable(unitTable, csvFileName);
    save(regionFile,'regionUnits','-v7.3','-mat')
    
    T(r)=toc;
    fprintf('Finished this region on to the next! %s\n',regionOfinterest)
    clearvars('regionUnits','regionFile')
end
wholeSetTimerEnd=toc(wholeSetTimer)

disp('Done!')