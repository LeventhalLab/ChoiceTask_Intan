function n_channels = n_channels_from_probetype(probe_type, lfp_type)
%UNTITLED7 Summary of this function goes here
% INPUTS
%   probe_type - 
%   lfp_type - 
%  
% OUTPUTS
%   column_num - number of recording column - could be a single shank, or
%       there could be multiple columns of recording sites per shank
%   site_num - site going from dorsal to ventral along the column (note,
%       might not be a physical site for bipolar). e.g., site 1 is the most
%       dorsal, site 2 ventral to site 1, etc, then start over in the next
%       column

% which style of probe was used?
switch lower(probe_type)
    case 'nn8x8'
        % 8 shanks with 8 sites each
        sites_per_column = 8;
        total_channels = 64;    % if add new probe types later
    
    case 'assy156'
        sites_per_column = 16;
        total_channels = 64;    % if add new probe types later

    case 'assy236'
        sites_per_column = 16;
        total_channels = 64;    % if add new probe types later

end

n_columns = total_channels / sites_per_column;

% monopolar vs bipolar
switch lower(lfp_type)

    case 'monopolar'
        signals_per_column = sites_per_column;

    case 'bipolar'
        signals_per_column = sites_per_column - 1;

end

n_channels = signals_per_column * n_columns;