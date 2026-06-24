function unit_table_updated = clean_units_table(unit_table)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% todo: add peak recording site and x,y,z

arguments (Input)
    unit_table
end

unit_table_updated = unit_table;

% get ratIDs from the unit table
n_units = size(unit_table, 1);
rat_nums = zeros(size(unit_table, 1), 1);

for i_unit = 1 : n_units
    rat_nums(i_unit) = str2num(cell2mat(extractBetween(unit_table.unitID{i_unit}, 'R0', '_')));
end

unit_table_updated.rat_nums = rat_nums;

% extract brain regions
brain_region = cell(n_units, 1);

for i_unit = 1 : n_units
    if strcmpi(unit_table.region{i_unit}, 'otherregions') ||  contains(lower(unit_table.region{i_unit}), 'cbrecipient')
        % unit is located before the underscore in the unit ID
        brain_region{i_unit} = extractBefore(unit_table.unitID{i_unit}, '_R');
    else
        brain_region{i_unit} = unit_table.region{i_unit};
    end
end
unit_table_updated.region = brain_region;

unit_table_updated = sortrows(unit_table_updated, 'rat_nums');


end