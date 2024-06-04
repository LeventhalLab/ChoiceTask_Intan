function TF = isbehavior_vi_folder(test_string)

string_parts = split(test_string, '_');

if strcmp(string_parts{3}, 'behaviorVIs')
    TF = true;
else
    TF = false;
end

return