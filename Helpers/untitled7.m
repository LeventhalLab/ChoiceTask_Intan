function [outputArg1,outputArg2] = get_shank_and_site_num(probe_type, )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
outputArg1 = inputArg1;
outputArg2 = inputArg2;

switch lower(probe_type)
    case 'nn8x8_monopolar'
        % 8 shanks with 8 sites each
    case 'nn8x8_bipolar'
        % 8 shanks with 7 sites each (bipolar configuration for adjacent
        % sites)
end