function [column_num,site_num] = get_shank_and_site_num(probe_type, row_idx)
%UNTITLED7 Summary of this function goes here
% INPUTS
%   row_idx = the index of the row in the ordered_lfp array. It should be
%       ordered such that we start at shank 1, most dorsal site, then go
%       down the shank to site 8 (most ventral sitefor an NN8x8), then 
%       shank 2 running from dorsal to ventral, etc. For a Cambridge probe,
%       it should start at the most dorsal site and go down 16 sites, with
%       4 columns of electrodes total
%  
% OUTPUTS
%   column_num - number of recording column - could be a single shank, or
%       there could be multiple columns of recording sites per shank
%   site_num - site going from dorsal to ventral along the column (note,
%       might not be a physical site for bipolar). e.g., site 1 is the most
%       dorsal, site 2 ventral to site 1, etc, then start over in the next
%       column

probe_parts = split(probe_type, '_');

% which style of probe was used?
switch lower(probe_parts{1})
    case 'nn8x8'
        % 8 shanks with 8 sites each
        sites_per_column = 8;
    
    case 'assy156'
        sites_per_column = 16;

    case 'assy236'
        sites_per_column = 16;

end

% monopolar vs bipolar
switch lower(probe_parts{2})

    case 'monopolar'
        signals_per_column = sites_per_column;

    case 'bipolar'
        signals_per_column = sites_per_column - 1;

end

column_num = ceil(row_idx / signals_per_column);
site_num = row_idx - (column_num-1) * signals_per_column;