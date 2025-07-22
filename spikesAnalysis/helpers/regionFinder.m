function [uniqueRegions]=regionFinder(rats)
%% Set up parent directories and ignore rat ids not interested in
parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
summary_xls = 'ProbeSite_Mapping_MATLAB_RL2.xlsx';
summary_xls_dir = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary';
summary_xls = fullfile(summary_xls_dir, summary_xls);
sessions_to_ignore = {'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a','R0427_20220919a','R0479_20230601a','R0572_20240918a' }; % R0425_20220728a debugging because the intan side was left on for 15 hours;

probe_type_sheet = 'probe_type';
probe_types = read_Jen_xls_summary(summary_xls, probe_type_sheet);
% NOTE - UPDATE FUNCTION read_Jen_xls_summary WHEN WE NEED OTHER%
% INFORMATION OUT OF THAT SPREADSHEET

%[rat_nums, ratIDs, ratIDs_goodhisto] = get_rat_list();
ratIDs=probe_types.ratID;
ignoreRats={'R0326','R0327','R0372','R0374','R0379','R0376','R0378','R0394','R0395','R0396','R0411','R0412','R0413','R0419',...
            'R0425','R0427','R0456','R0459'};%,'R0420','R0460','R0463','R0466','R0465','R0467','R0479','R0492','R0493'};
num_rats = length(ratIDs);

allRegions=[];
%% Loop through all rats and locate any ephys sessions with Kilosort data
for i_rat = 1 : num_rats
    ratID = ratIDs{i_rat};
    
    rat_folder = fullfile(parent_directory, ratID);
    if any(strcmp(ratID,ignoreRats))
        continue
    end
    if ~any(strcmp(ratID,rats))
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
    regions=histo_data.Region;
    strrep(regions,'/','-');

    % channelRegion=[histo_data.Intan_Site_Number,histo_data.Region];
    % channelRegion(:, 1) = cellfun(@(x) num2str(str2double(x)), channelRegion(:, 1), 'UniformOutput', false); %changed back to zero scale 4/15
    % strrep(regionOfinterest,'/','-')%Matlab doesnt like slashes
    % strrep(channelRegion,'/','-')
    allRegions = [allRegions; regions];
end
uniqueRegions={};
uniqueRegions=unique(allRegions);
end