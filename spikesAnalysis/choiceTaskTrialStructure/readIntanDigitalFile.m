function digital_data = readIntanDigitalFile(fname, varargin)
%
% function to read in a digital IO Intan file ('digitalIn' or 'digitalOut')
% if Varargins are not specified, assume user wants to read the entire file
%
% INPUTS
%   fname - filename of the Intan digital file to read
%
% VARARGS
%   sample_start - first sample to read from the digital_in file (in
%       samples, NOT in bytes)
%   samples_to_read - number of samples to read in. Again, this is in
%       samples, NOT in bytes
%
%   frequency - sample_rate(in Hz, default = 20kHz aka 20000Hz)
% 
% OUTPUTS
%   digital_data - vector of uint16's containing bit-wise values of each
%      digital line from the Intan system

if nargin > 1
    sample_start = varargin{1};
    samples_to_read = varargin{2};
    
    start_byte = sample_start * 2; 
else
    fileinfo = dir(fname);
    start_byte = 0;
    samples_to_read = fileinfo.bytes/2; % uint16 = 2 bytes
end

fid = fopen(fname, 'r');

fseek(fid, start_byte, 'bof');
digital_data = fread(fid, samples_to_read, 'uint16');

fclose(fid);

% Individual digital inputs can be isolated using the bitand function in MATLAB:
% digital_input_ch = (bitand(digital_data, 2^ch) > 0); % ch has a value of 0-15 here