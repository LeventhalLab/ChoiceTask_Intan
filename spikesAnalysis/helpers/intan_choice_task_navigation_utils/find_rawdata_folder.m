function session_path = find_rawdata_folder(input1, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

parent_directory = 'Z:\data\ChoiceTask';

if nargin > 1
    if strcmpi(varargin{1}, 'parent_directory')
        parent_directory = varargin{2};
    end
end
if nargin > 2
    if strcmpi(varargin{2}, 'parent_directory')
        parent_directory = varargin{3};
    end
end

if nargin == 1 || (nargin > 1 && strcmpi(varargin{1}, 'parent_directory'))
    % assume the full session name was given - i.e., 'RXXXX_YYYYMMDDz'

    str_parts = split(input1, '_');
    ratID = str_parts{1};

    rat_rd_folder = find_rat_rawdata_folder(parent_directory, ratID);

    if isfolder(fullfile(rat_rd_folder, input1))
        session_path = fullfile(rat_rd_folder, input1);
    else
        session_path = '';
    end

elseif nargin == 2
    % assume the first argument is the rat number or ratID, the second
    % argument is the date string or date (if date, assume it's session a)

    if isinteger(input1)
        ratID = sprintf('R%04d', input1);
    elseif ischar(input1)
        ratID = input1;
    end
    rat_rd_folder = find_rat_rawdata_folder(parent_directory, ratID);

    if ischar(varargin{1})
        session_name = strcat(ratID, '_', varargin{1});
    elseif isdatetime(varargin{1})
        date_string = datestr(varargin{1}, 'yyyymmdd');
        session_name = strcat(ratID, '_', date_string, 'a');
    end

    if isfolder(fullfile(rat_rd_folder, session_name))
        session_path = fullfile(rat_rd_folder, session_name);
    else
        session_path = '';
    end

end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rat_rd_folder = find_rat_rawdata_folder(parent_directory, ratID)

rat_folder = fullfile(parent_directory, ratID);
rat_rd_folder = fullfile(rat_folder, strcat(ratID, '-rawdata'));

end