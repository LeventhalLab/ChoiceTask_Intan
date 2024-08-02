function [channel_region_label,color] = getChannelRegionLabel(ratID, site_num)
ExcelFileName =   'X:\Neuro-Leventhal\data\ChoiceTask\Probe Histology Summary\ProbeSite_Mapping_MATLAB_RL.xlsx';  

% Define the channel region labels and corresponding colors
    channel_labels = {'VM', 'ZI', 'VPL', 'ml', 'VL', 'VPM', 'VA', ...
                      'LH', 'PC', 'SubI', 'PF', 'ZID', 'VA/VL', 'ZI/VM', ...
                      'VM/VL', 'Rt', 'PR/Border VM', 'RI', 'PR', 'SM', ...
                      'Po', 'SubD', 'MDL', 'SubV', 'ts', 'LDVL', 'fr', ...
                      'APT', 'DpMe', 'LDDM', 'VPPC', 'CL', 'OPC', 'ZIV'};
    num_labels = length(channel_labels);
    default_color = [0.5 0.5 0.5];  % Default color for labels not in the list
    
    % Define colors manually for each label
    % Example: (replace with your desired colors)
    label_colors = [
        0    0.4470    0.7410;       % APT - blue : VM
        0.8500    0.3250    0.0980;  % CL - orange : ZI
        0.9290    0.6940    0.1250;  % DpMe - yellow : VPL
        0.4940    0.1840    0.5560;  % eml - purple : ml
        0.4660    0.6740    0.1880;  % fr - green : VL
        0.3010    0.7450    0.9330;  % LDDM - light blue : VPM
        0.6350    0.0780    0.1840;  % LDVL - dark red : VA
        1.0000    0.6000    0.7840;  % LH - pink : LH
        0.5800    0.5800    0.5800;  % LPMR - gray : PC
        0.8900    0.4670    0.7610;  % MDL - light purple : SubI
        0.8706    0.4902    0.0941;  % ml - brown : PF
        0.7370    0.7410    0.1330;  % OPC - olive : ZID
        0.6350    0.0780    0.1840;  % PC - dark red : VA/VL
        0.8500    0.3250    0.0980;  % PF - orange : ZI/VM
        0.4660    0.6740    0.1880;  % Po - green : VM/VL
        0.4940    0.1840    0.5560;  % SubD - purple
        0.9290    0.6940    0.1250;  %  yellow 
        0.3010    0.7450    0.9330;  %  light blue 
        0.6350    0.0780    0.1840;  %  - dark red
        0.4660    0.6740    0.1880;  % - green
        0.8500    0.3250    0.0980;  %  - orange
        0.8900    0.4670    0.7610;  %  - light purple
        0.8706    0.4902    0.0941;  %  - brown
        0.7370    0.7410    0.1330;  %  - olive
        0.5800    0.5800    0.5800;  %  - gray
        0.3010    0.7450    0.9330;  %  - light blue
        1.0000    0.6000    0.7840;  %  - pink
        0.6350    0.0780    0.1840;  %  - dark red
        0.8706    0.4902    0.0941;  %  - brown
        0.8900    0.4670    0.7610;  %  - light purple
        0.4660    0.6740    0.1880;  %  - green
        0.9290    0.6940    0.1250;  %  - yellow
        0.4940    0.1840    0.5560;  %  - purple
        0.5800    0.5800    0.5800   %  - gray
        default_color  % Default color
    ];

% Get all sheet names from the Excel file
    sheets = sheetnames(ExcelFileName);

    % Find the sheet that starts with ratID_
    matchedSheet = "";
    for i = 1:length(sheets)
        if startsWith(sheets{i}, [ratID '_'])
            matchedSheet = sheets{i};
            break;
        end
    end

    if isempty(matchedSheet)
        error('No sheet found matching the pattern %s_', ratID);
    end

% Read the Excel file into a table
    excelTable = readtable(ExcelFileName, 'Sheet', matchedSheet);

    %{
    % Find the column name that ends with the specified suffix
    siteNumberColumn = "";
    columns = excelTable.Properties.VariableNames;
    
    columnSuffix = 'Site_Number';
    for i = 1:length(columns)
        if endsWith(columns{i}, ['_' columnSuffix])
            siteNumberColumn = columns{i};
            break;
        end
    end

    if isempty(siteNumberColumn)
        error('No column found ending with %s', ['_' columnSuffix]);
    end
    %}

    % shift from 1 scaled to 0 scaled because the excel intan values are 0
    % scaled
    if isstring(site_num)
    % If site_num is a string
        site_num0 = str2num(site_num) - 1;
    else
    % If site_num is a numeric value
        site_num0 = site_num - 1;
    end


    % Find the row index where SiteNumber matches site_num
    rowIndex = find(excelTable.Intan_Site_Number == site_num0, 1);
    

    %error message, can probably delete later
    if isempty(rowIndex)
        error('Site number %d not found in the Excel sheet.', site_num);
    end
    
    % Retrieve the channel region label from the 'Region' column
    if iscell(excelTable.Region)
        channel_region_label = excelTable.Region{rowIndex};
    else
        channel_region_label = excelTable.Region(rowIndex);
    end

     % Find the index of the channel label in the predefined list
    label_index = find(strcmp(channel_labels, channel_region_label));
    
    % Assign color based on label index
    if ~isempty(label_index)
        color = label_colors(label_index, :);
    else
        color = default_color;  % Assign default color for any other label
    end


    end