function lfp_NNsite = probe_site_mapping(probe_type)

if strcmpi(probe_type, 'NN8x8')
    %lfp by shank number
    lfp_amplifier = lfp([49:56,...%shank1
        57:64,...%shank2
        33:35, 37:39, 41:42,...%shank3
        35,40,43:48,...%shank4
        17:22,26,30,...%shank5
        23:25, 27:29, 31:32,...%shank6
        1:8,...%shank7
        9:16],:); %shank8

    %Reorganize lfp by NNsite
    lfp_NNsite= lfp_amplifier([2,7,1,8,4,5,3,6,... %shank 1
        10,15,9,16,12,13,11,14,... %shank2
        17,24,18,23,19,22,20,21,...%shank3
        27,25,29,26,30,28,31,32,...%shank4
        40,37,39,35,38,36,34,33,...%shank5
        42,47,41,48,43,46,45,44,...%shank6
        49,56,50,55,51,54,52,53,...%shank7
        57,64,58,63,59,62,60,61],:);%shank8
end