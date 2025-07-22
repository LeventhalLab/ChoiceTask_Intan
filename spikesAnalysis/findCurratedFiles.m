%% Set up parent directories and ignore rat ids not interested in
parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls_dir = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);
sessions_to_ignore = {'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a','R0427_20220919a','R0479_20230601a','R0493_20230720a'}; % R0425_20220728a debugging because the intan side was left on for 15 hours;

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER%
% INFORMATION OUT OF THAT SPREADSHEET

%[rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();
ratIDs=probe_types.ratID;
ignoreRats={'R0326','R0327','R0372','R0374','R0379','R0376','R0378','R0394','R0395','R0396','R0411','R0412','R0413','R0419',...
            'R0425','R0427','R0456','R0459'};%,'R0420','R0460','R0463','R0466','R0465','R0467','R0492','R0494','R0495','R0493',''
num_rats = length(ratIDs);


%% Input your parameters!!

acgBinSize=0.0001;
acgDuration=1;
plotACG=true;
kilosortVersion = 4; % if using kilosort4, you need to have this value kilosertVersion=4. Otherwise it does not matter. 
gain_to_uV = 0.195;
binSize=0.02; %Psth

regionOfinterest={'AHP','LH','Mt','Mt/VM','PLH','PaPo','PefLH','PefLH/LH','Rt','Rt/VA','Rt/ns','SubI',...
    'VA/VPL/VM','VM/VL','VM/VL/VPL','ZI/VM','ZI/SubI'};
behaviorA={'correct','cuedleft'};
behaviorAname='Correct Left';
behaviorB={'wrong','cuedleft'};
behaviorBname='All wrong left';
behaviorC={'cuedleft','slowmovement'};
behaviorCname='Slow move left';
behaviorD={'cuedleft','slowreaction'};
behaviorDname='Slow react left';
behaviorE={'correct','cuedright'};
behaviorEname='Correct Right';
behaviorF={'cuedleft','moveright'};
behaviorFname='Wrong move direction cue left';
behaviorG={'cuedright','wrong'};
behaviorGname='All wrong right';
outputTitle='Correct Left vs Wrong Left';
%include only this region- true: include overlap regions=false
regionSpecific=true;

%% Clear out unused behaviors
allFeatures={behaviorA,behaviorB,behaviorC,behaviorD,behaviorE,behaviorF,behaviorG};
allNames={behaviorAname,behaviorBname,behaviorCname,behaviorDname,behaviorEname,behaviorFname,behaviorGname};
trialfeatureList={};
trialName={};

for i = 1:length(allFeatures)
    if ~isempty(allFeatures{i})
        trialfeatureList{end+1} = allFeatures{i};
        trialName{end+1} = allNames{i};
    end
end


potentialeventNames={'cueOn','centerIn','tone','centerOut','houseLightOn','sideIn','wrong','sideOut','foodClick','foodRetrieval'};
curatedFiles={};
%% Loop through all rats and locate any ephys sessions with Kilosort data
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
    % if ~any(ismember(regionOfinterest,channelRegion(:,2)))
    %     fprintf('No electrodes from this rat contain a region of interest skipping... %s\n',ratID)
    %     continue
    % end
    probe_type = probe_types{probe_types.ratID == ratID, 2}; % changed probe_types.RatID to probe_types.ratID due to error
    processed_folder = find_data_folder(ratID, 'processed', parent_directory);
    rawdata_folder = find_data_folder(ratID, 'rawdata', parent_directory);
    session_dirs = dir(fullfile(rawdata_folder, strcat(ratID, '*')));
    num_sessions = length(session_dirs);
    psthRasterOutput=fullfile(rat_folder, strcat(ratID,'-PsthAndRastersPlots'));
    if ~exist(psthRasterOutput)
        mkdir(psthRasterOutput)
    end
    savePath = fullfile(psthRasterOutput,outputTitle);
    if ~exist(savePath)
        mkdir(savePath)
    end
    for i_session = 1 : num_sessions
        
        sessionName = session_dirs(i_session).name;
        
        cur_dir = fullfile(session_dirs(i_session).folder, sessionName);
        cd(cur_dir)

        phys_folder = find_physiology_data(cur_dir);
        ephysKilosortPath = fullfile(phys_folder, 'kilosort4');

        if isempty(phys_folder)
            sprintf('no physiology data found for %s', sessionName)
            continue
        end
        % if ~exist(ephysKilosortPath)
        %     keyboard
        % end
        if any(strcmp(sessionName, sessions_to_ignore)) % Jen added this in to ignore sessions as an attempt to debut "too many input arguments"
            continue;
        end
        if ~isfolder(fullfile(phys_folder,'kilosort4'))||~exist(fullfile(ephysKilosortPath,'params.py')) 
            continue
        end
        
        if ~isfolder(fullfile(ephysKilosortPath,'qMetrics'))
            keyboard
            continue %second catch to ignore ks4 that wasn't run
        end
        ephysRawFile = fullfile(phys_folder, 'amplifier.dat'); % path to your raw .bin or .dat data
        ephysMetaDir = ''; % path to your .meta or .oebin meta file
        
        

        %% Ignore sessions with missing behavior files
        if ~exist(fullfile(phys_folder,'info.rhd'))||~exist(fullfile(phys_folder,'digitalin.dat'))||~exist(fullfile(phys_folder,'analogin.dat'))...
                isempty(dir(fullfile(cur_dir,'*.log'))) || ~exist(fullfile(phys_folder,'auxillary.dat')) ||  ~exist(fullfile(phys_folder,'supply.dat')) || ~exist(fullfile(phys_folder,'time.dat'));
            sprintf('missing intan data for %s', sessionName)
            continue
        end
        ksFolder=fullfile(phys_folder,'kilosort4');
        if exist(fullfile(ksFolder,'cluster_info.tsv'))
            curatedFiles{end+1}=sessionName;
        else
           sprintf('session not currated continuing %s', sessionName)
           continue 
        end
    end
end
