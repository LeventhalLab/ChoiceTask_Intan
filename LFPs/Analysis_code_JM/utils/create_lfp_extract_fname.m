function lfp_extract_fname = create_lfp_extract_fname(rd_processed_data)

lfp_extract_fname = strcat(rd_processed_data.ratID, '_', rd_processed_data.session_name(7:end), '_MatAnalysis.mat');