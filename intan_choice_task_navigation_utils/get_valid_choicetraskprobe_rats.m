function [rat_nums, ratIDs] = get_valid_choicetraskprobe_rats()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% hardcode in the rats with clean data
rat_nums = [420, 463, 465, 466, 467, 479, 492, 493, 494, 544, 545, 546, 572];

n_rats = length(rat_nums);
ratIDs = cell(n_rats, 1);
for i_rat = 1 : n_rats
    ratIDs{i_rat} = sprintf('R%04d', rat_nums(i_rat));
end
end