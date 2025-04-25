function loadUnitData(ephysKilosortPath,clusID)


qMetricsPath=fullfile(ephysKilosortPath,'qMetrics');
unitWaveformsPath=fullfile(qMetricsPath,'RawWaveforms');
qMetricsTable=parquetread(fullfile(qMetricsPath,'templates._bc_qMetrics.parquet'));
refractPeriodTable=parquetread(fullfile(qMetricsPath,'templates._bc_fractionRefractoryPeriodViolationsPerTauR.parquet'));
ephysPropTable=parquetread(fullfile(qMetricsPath,'_bc_parameters._bc_ephysProperties.parquet'));
acgTable=parquetread(fullfile(qMetricsPath,'templates._bc_acg.parquet'));
for u = 1:length(unique_clusters)
    clusterID = unique_clusters(u);
    clusterTables{u} = qMetricsTable(qMetricsTable.phy_clusterID == clusterID, :);
end