function TF = isvalidratfolder(test_string)

if test_string(1) == 'R' && all(isstrprop(test_string(2:end), 'digit'))
    TF = true;
else
    TF = false;
end