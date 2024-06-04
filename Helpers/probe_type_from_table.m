function probe_type = probe_type_from_table(rat_table, ratID)
%
% INPUTS:
%   rat_table - matlab table containing columns called 'ratID' and
%       'probe_type', which contain cells with strings that contain the
%       ratIDs and corresponding probe_types. There could be other columns,
%       but there must be at least those 2 columns for this to work
%
% OUTPUTS:
%   probe_type - string containing the probe type

% find the row with this ratID
row_bool = strcmpi(rat_table.ratID, ratID);

if ~any(row_bool)   % ratID isn't in the list
    probe_type = 'unknown';
    return
end

probe_type = rat_table.probe_type(row_bool);

probe_type = lower(probe_type{1});