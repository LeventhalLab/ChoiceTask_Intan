% ZHH
% script 1/2 for making heatmaps
% creates a table for each rat containing session name, channels involved,
% frequency bins, shank number, and values for area under the bipolar power
% curve within the frequency bin
% script 2 (makeHeatmaps) uses this table to make desired heatmaps for
% each rat

%{
quick information:
location:
X:\Neuro-Leventhal\data\ChoiceTask\GitHub\ChoiceTask_Intan\LFPs\Analysis_code_JM\plots
functions called:
find_processed_folders
load_channel_information
probe_site_map_all
intan_and_channel_site_order

files used:
_diffpower.mat files in processed folders
channels_qc_final.xlsx (Excel file for color coding bad channels)

Outputs save to:
output_folder =  fullfile(intan_choicetask_parent, 'heatmap tables');
Where intan choice task parent is
intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';
last updated 7/08/24.
%}


% Define Probe Type Lists
NN8x8 = ["R0326", "R0327", "R0372", "R0379", "R0374", "R0376", "R0378", "R0394", "R0395", "R0396", "R0412", "R0413"];
ASSY156 = ["R0411", "R0419"];
ASSY236 = ["R0420", "R0425", "R0427", "R0456", "R0457", "R0463", "R0465", "R0477", "R0460", "R0466", "R0467", "R0479", "R0492", "R0493", "R0494", "R0495"];

% Create a mapping from ratID to probe_type
probeTypeMap = containers.Map();
for i = 1:length(NN8x8)
    probeTypeMap(NN8x8(i)) = 'NN8x8';
end
for i = 1:length(ASSY156)
    probeTypeMap(ASSY156(i)) = 'ASSY156';
end
for i = 1:length(ASSY236)
    probeTypeMap(ASSY236(i)) = 'ASSY236';
end

%define parameters
intan_choicetask_parent = 'X:\Neuro-Leventhal\data\ChoiceTask';

% loop through all the processed data folders here, load the lfp file
valid_rat_folders = find_processed_folders(intan_choicetask_parent);
% rats_with_intan_sessions = find_rawdata_folders(intan_choicetask_parent);


%%

% excel file that identifies channels as good or bad based on visual
% neuroscope inspection
fname = 'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\channels_qc_final.xlsx';

frequencyBins = [1, 4; 4, 8; 8, 13; 13, 30; 30, 70; 70, 200]; % Define your frequency bins



%% 


% input or work into for loop
%loop
% go through all sessions for all rats

for i_ratfolder = 1 : length(valid_rat_folders)
    % Create new table with column headers :
    % Session, channel, freq bin, shank num, value
    % Initialize results table for this rat
    heatmapTable = table();
    heatmapTable.Session = {};
    heatmapTable.Channel = {};
    heatmapTable.FreqBin = {};
    heatmapTable.ShankNum = {};
    heatmapTable.RowNum = {};
    heatmapTable.GoodBad = {};
    heatmapTable.Value = zeros(0);

    session_processed_folders = valid_rat_folders(i_ratfolder).processed_folders;
    currentRat=valid_rat_folders(i_ratfolder).name(36:end);

       
       % R0328 has no actual ephys; using these lines to skip unneeded data. R0327 Can't create trials struct; R0420 I haven't added lines for
        % these skips are from a previous author, so im not sure how necessary they are or why we skip 411 - ZH
        if  strcmp(currentRat, 'R0328') || strcmp(currentRat, 'R0374')|| strcmp(currentRat, 'R0411') 
             continue; 
        end


    for i_sessionfolder = 1 : length(session_processed_folders)
    % extract the ratID and session name from the LFP file
        session_path = session_processed_folders{i_sessionfolder};
        pd_processed_data = parse_processed_folder(session_path);
        ratID = pd_processed_data.ratID;
        session_name = pd_processed_data.session_name;
        


% check that the ratID of the current rat table matches the ratID in the session name, 
% if it doesnt match, skip this session (dont add it to the table)       
        disp(currentRat);
        disp(session_name(1:5));
        if strcmp(currentRat,session_name(1:5))
            %dont do anything, thats what we want
        else
            disp('ratID mismatch 2, skipping this session');
            continue;
        end

        % if any sessions pop up from rats we should be ignoring, skip them
         if  strcmp(session_name(1:5), 'R0328') || strcmp(session_name(1:5), 'R0374')|| strcmp(session_name(1:5), 'R0411') 
             continue; 
         end

        sessions_to_ignore = {'R0327_20191111a','R0376_20210115a', 'R0378_20210507a', 'R0326_20191107a', 'R0425_20220728a', 'R0425_20220816b', 'R0427_20220920a','R0419_20220317a',...
   'R0419_20220321a','R0419_20220321b','R0419_20220321c','R0420_20220707a','R0420_20220708a','R0372_20201116a','R0394_20210115a','R0420_20220703a',...
   'R0420_20220707a','R0420_20220708a','R0420_20220710a','R0420_20220714a','R0420_20220919a','R0425_20220816a','R0425_20220816b','R0427_20220908a','R0456_20221121a','R0456_20221128a','R0460_20230110a','R0460_20230110b','R0327_20191015a'};

        % skip sessions that we said should be ignored
        if any(strcmp(session_name, sessions_to_ignore)) 
            continue;
        end
     
%establish probe type based on ratID (update as more rats are added) 
        % Determine probe_type based on ratID
        if isKey(probeTypeMap, ratID)
            probe_type = probeTypeMap(ratID);
        else
            warning('Unknown ratID: %s, please add to probe type lists', ratID);
            continue;
        end


        %channel_information
        sheetname = ratID;
        probe_channel_info = load_channel_information(fname, sheetname);
        [channel_information, intan_site_order, site_order] =probe_site_map_all(probe_channel_info, probe_type);
        %power_lfps_diff_fname, 
        power_lfps_diff_file = dir(fullfile(session_path, '**', '*_diffpower.mat'));
        power_lfps_diff_fname = fullfile(power_lfps_diff_file.folder, power_lfps_diff_file.name); 
        
        % valid_sites_reordered
        session_name_adj=['x',session_name(7:end)];
        valid_sites_reordered = channel_information.(session_name_adj);
        
        
        power_lfps_diff = load(power_lfps_diff_fname);
        f = power_lfps_diff.f;
        Fs = power_lfps_diff.Fs;
        power_lfps_diff = power_lfps_diff.power_lfps_diff;
        
        
           %num rows depends on the probe type (should be 56 for assy probes)
           num_rows = size(power_lfps_diff, 1);  
        for i_row = 1 : num_rows 
        
                    % Initialize results for this channel
                    channel_results = table();
                    channel_results.Session = {session_name};
               
                    % shank number 
                    % adjusts to accomodate diff probe types
                    if strcmp(probe_type, 'ASSY156') || strcmp(probe_type, 'ASSY236')
                        LFPs_per_shank = num_rows / 4; 
                    elseif strcmp(probe_type, 'NN8x8')
                        LFPs_per_shank = num_rows / 8;
                    else
                        disp('invalid probe type');
                    end
                    plot_col = ceil(i_row / LFPs_per_shank); 
                    channel_results.ShankNum = {plot_col};
                    plot_row = i_row - LFPs_per_shank * (plot_col-1);
                    channel_results.RowNum = {plot_row};
                    
                    % are the channels involved good or bad
                    %converts the row numbers for the diff power back to standard row
                    %values that make sense with the excel file
                    i_row_adj= i_row + plot_col - 1;
                    %if both channels involved are good --> black
                    if valid_sites_reordered(i_row_adj)==2 && valid_sites_reordered(i_row_adj+1)==2
                        channel_results.GoodBad = 'good';
                        %if the top channel is bad --> pink
                    elseif valid_sites_reordered(i_row_adj)==1
                        channel_results.GoodBad = 'bad';
                %if the bottom channel is bad --> pink
                    elseif valid_sites_reordered(i_row_adj+1)==1
                        channel_results.GoodBad = 'bad';
                %anything else --> blue
                    else
                        channel_results.GoodBad = 'other';
                    end
                    
                    
           % channels involved
           [intan_num, channel_num] = intan_and_channel_site_order(probe_type);
           channelName=  sprintf('in:%d-%d(1)',intan_num(i_row_adj),intan_num(i_row_adj+1));
           channel_results.Channel = {channelName};  % Assuming channel info is stored in a cell array
                   
        
            %plot_bipolar=plot(f, 10*log10(power_lfps_diff(i_row, :)),
            log_spectrum = log10(power_lfps_diff(i_row, :));
           
            %{
            this is only needed if using flattened bipolar plots
            log_f = log10(f);
            
            % Fit a linear model to estimate the 1/f trend
            p = polyfit(log_f, log_spectrum, 1);
            trend = polyval(p, log_f);
            
            % Subtract the trend to flatten the spectrum
            flattened_log_spectrum = log_spectrum - trend;
            flattened_spectrum = 10 .^ flattened_log_spectrum;
        
            % Plot the flattened spectrum (log scale)
           % plot_bipolar=plot(f, 10*log10(flattened_spectrum), 'LineWidth', 1.5);
            %}
        
        
            % Calculate area under curve for each frequency bin
                    for j = 1:size(frequencyBins, 1)
                        switch j
                            case 1
                                freqBinName = 'Delta';
                            case 2
                                freqBinName = 'Theta';
                            case 3
                                freqBinName = 'Alpha';
                            case 4
                                freqBinName = 'Beta';
                            case 5
                                freqBinName = 'L Gamma';
                            case 6
                                freqBinName = 'H Gamma';
                            otherwise
                                freqBinName = '';
                        end
                        idx1 = find(f >= frequencyBins(j, 1), 1);
                        idx2 = find(f >= frequencyBins(j, 2), 1);
                        if ~isempty(idx1) && ~isempty(idx2)
                            area_value = trapz(f(idx1:idx2), 10*log10(power_lfps_diff(i_row, idx1:idx2)));
                            
                            % Add this frequency bin and area to results
                            channel_results.FreqBin = {freqBinName};
                            channel_results.Value = area_value;
                            
                            % Append to main results table
                            heatmapTable = [heatmapTable; channel_results];
                        end
                    end
        end

    end
    % Save results table for this rat
    outputFolder = fullfile(intan_choicetask_parent, 'heatmap tables', currentRat);
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    saveFileName = fullfile(outputFolder, sprintf('heatmapTable_%s.mat', currentRat));
    save(saveFileName, 'heatmapTable');
    %clear session processed folders between rats to only include the
    %folders for the current rat
    clear session_processed_folders;
    % Clear heatmapTable to prepare for next rat's data
    clear heatmapTable;
    disp('table cleared')
end


