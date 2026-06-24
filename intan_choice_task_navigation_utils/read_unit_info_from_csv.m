function unit_table = read_unit_info_from_csv(unit_summary_name)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    unit_summary_name
end

unit_table = readtable(unit_summary_name);

end