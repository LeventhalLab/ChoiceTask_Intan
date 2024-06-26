% NNsite_order = [1,8,2,7,3,6,4,5,...%shank1
%             9,16,10,15,11,14,12,13,...%shank2
%             17,24,18,23,19,22,20,21,...%shank3
%             25,32,26,31,27,30,28,29,...%shank4
%             33,40,34,39,35,38,36,37, ...%shank5
%             41,48,42,47,43,46,44,45,...%shank6
%             49,56,50,55,51,54,52,53,...%shank7
%             57,64,58,63,59,62,60,61]; %shank8
% reverse the order to go ventral to dorsal
% 
NNsite_order = [5,4,6,3,7,2,8,1,...%shank1  -- USE THIS FOR MONOPOLAR
            13,12,14,11,15,10,16,9,...%shank2
            21,20,22,19,23,18,24,17,...%shank3
            19,28,30,27,31,26,32,25,...%shank4
            37,36,38,35,39,34,40,33, ...%shank5
            45,44,46,43,47,42,48,41,...%shank6
            53,52,54,51,55,50,56,49,...%shank7
            61,60,62,59,63,58,64,57]; %shank8
        
ASSY156_order = [12,53,4,14,51,3,15,1,...
    31,49,6,57,58,62,7,11,...
    16,2,52,13,56,54,8,61,...
    63,10,59,55,5,9,60,64,...
    26,35,33,24,37,28,41,39,...
    27,40,29,50,47,32,19,44,...
    23,36,38,25,34,21,22,43,...
    30,20,45,17,48,18,46,42];

ASSY236_order = [34,18,54,23,7,38,22,40,...
    56,8,52,5,17,3,51,50,...
    41,55,20,36,6,39,49,19,...
    1,35,4,21,53,33,37,2,...
    64,48,16,61,13,60,29,12,...
    59,32,42,24,9,57,44,45,...
    47,14,31,62,15,63,46,30,...
    58,27,10,26,25,43,28,11];

