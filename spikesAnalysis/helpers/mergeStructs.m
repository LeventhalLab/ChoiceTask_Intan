function out = mergeStructs(a, b)
    out = a;
    bFields = fieldnames(b);
    for i = 1:numel(bFields)
        out.(bFields{i}) = b.(bFields{i});
    end
end