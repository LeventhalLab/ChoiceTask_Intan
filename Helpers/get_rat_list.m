function [ratIDs, ratIDs_goodhisto] = get_rat_list(rats_to_analyze, parent_directory)
% list of rats to be analyzed from thalamic recordings
% update rat_nums (and hopefully not ratnums_with_bad_histo) to indicate
% which rats should be analyzed

% rat_nums = [326, 327, 372, 374, 376, 378, 379, 394, 395, 396, 411, 412, 413, 419, 420, 425];



ratnums_with_bad_histo = [374, 376, 396, 413];
n_rats_with_good_histo = 0;
if ischar(rats_to_analyze)
    if strcmpi(rats_to_analyze, 'all')
        % add code here to use all the folders if needed, but I think this
        % is an obsolete function
        rat_folders = get_rat_folders(parent_directory);
        n_rats = length(rat_folders);
        ratIDs = cell(n_rats, 1);
        for i_rat = 1 : length(rat_folders)
            [~, ratID, ~] = fileparts(rat_folders{i_rat});
            rat_num = str2num(ratID(2:end));
            ratIDs{i_rat} = ratID;
            if ~ismember(rat_num, ratnums_with_bad_histo)
                n_rats_with_good_histo = n_rats_with_good_histo + 1;
                ratIDs_goodhisto{n_rats_with_good_histo} = ratID;
            end
            % rat_nums(i_rat) = str2num(ratID(2:end));
        end
    end
end

n_rats_with_good_histo = 0;
for i_rat = 1 : length(rats_to_analyze)
    ratIDs{i_rat} = sprintf('R%04d', rats_to_analyze(i_rat));

    if ~ismember(rats_to_analyze(i_rat), ratnums_with_bad_histo)
        n_rats_with_good_histo = n_rats_with_good_histo + 1;

        ratIDs_goodhisto{n_rats_with_good_histo} = ratIDs{i_rat};
    end
    % rat_nums(i_rat) = str2num(ratIDs{i_rat}(2:end));
end

