% check data to verify accuracy of diff calculations
check_original_lfp55 = lfp(55, 1:1000) - lfp(50, 1:1000); % checking the diff between site 1 and site 8 in the original lfp file
check_lfp_NNsite_diff_55 = lfp_NNsite_order(2, 1:1000) - lfp_NNsite_order(1, 1:1000);
check_lfp_NNsite_diff_reported_values_55 = lfp_NNsite_diff(1, 1:1000);

check_original_lfp42 = lfp(42, 1:1000) - lfp(33, 1:1000); % checking the diff between site 1 and site 8 in the original lfp file
check_lfp_NNsite_diff_42 = lfp_NNsite_order(18, 1:1000) - lfp_NNsite_order(17, 1:1000);
check_lfp_NNsite_diff_reported_values_42 = lfp_NNsite_diff(15, 1:1000);