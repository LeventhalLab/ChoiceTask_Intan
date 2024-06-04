function ratIDs = get_rats2process(choicetask_xls_summary)
% return list of rats to be analyzed from thalamic recordings
% update rat_nums (and hopefully not ratnums_with_bad_histo) to indicate
% which rats should be analyzed
%
% INPUTS
%   choicetask_xls_summary
%
% OUTPUTS
%   ratIDs - string array containing IDs of rats that are included in the
%       excel file choicetask_xls_summary

sheets = sheetnames(choicetask_xls_summary);
n_sheets = size(sheets, 1);

% find ratIDs included in the excel document
rat_search_pattern = "R" + digitsPattern(4) + "_";
rat_sheets = contains(sheets, rat_search_pattern);

ratID_pattern = "R" + digitsPattern(4);
ratIDs = extract(sheets(rat_sheets, :), ratID_pattern);