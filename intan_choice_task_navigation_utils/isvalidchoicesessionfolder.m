function TF = isvalidchoicesessionfolder(test_string)

% should be formatted as RXXXX_YYYYMMDDz, where z = a,b,c,etc.
name_parts = split(test_string, '_');

% test if first part of name is a valid ratID
if ~isvalidratfolder(name_parts{1})
    TF = false;
    return
end

% test if second part of name is a valid YYYYMMDD date
% first, is second part 9 characters long?
if length(name_parts{2}) ~= 9
    TF = false;
    return
end

test_datestring = name_parts{2}(1:8);
% must be 8 digits
if ~all(isstrprop(test_datestring, 'digit'))
    TF = false;
    return
end

test_year = str2double(test_datestring(1:4));
% must have valid month
test_month = str2double(test_datestring(5:6));
if test_month < 1 || test_month > 12
    TF = false;
    return
end

test_date = str2double(test_datestring(7:8));
if test_date < 1
    TF = false;
    return
end
switch test_month
    case {1, 3, 5, 7, 8, 10, 12}
        if test_date > 31
            TF = false;
            return
        end
    case {4, 6, 9, 11}
        if test_date > 30
            TF = false;
            return
        end
    case 2
        if round(test_year) == test_year / 4
            if test_date > 29
                TF = false;
                return
            elseif test_date > 28
                TF = false;
                return
            end
        end
end

TF = true;

end