function rawEphysData=loadUnitData(ephysKilosortPath,unique_clusters)


qMetricsPath=fullfile(ephysKilosortPath,'qMetrics');
unitWaveformsPath=fullfile(qMetricsPath,'RawWaveforms');
qMetricsTable=parquetread(fullfile(qMetricsPath,'templates._bc_qMetrics.parquet'));
%refractPeriodTable=parquetread(fullfile(qMetricsPath,'templates._bc_fractionRefractoryPeriodViolationsPerTauR.parquet'));
ephysPropTable=parquetread(fullfile(qMetricsPath,'_bc_parameters._bc_ephysProperties.parquet'));
acgTable=parquetread(fullfile(qMetricsPath,'templates._bc_acg.parquet'));
ephysProperties=parquetread(fullfile(qMetricsPath,'templates._bc_ephysProperties.parquet'));
keepRows = ismember(qMetricsTable.phy_clusterID, unique_clusters);
qMetricsTable = qMetricsTable(ismember(qMetricsTable.phy_clusterID, unique_clusters), :);
ephysProperties = ephysProperties(ismember(ephysProperties.phy_clusterID, unique_clusters), :);

% Keep only the rows that match
acgTable = acgTable(keepRows, :);
rawEphysData={};
rawEphysData.rawWaveformsPath=unitWaveformsPath;
rawEphysData.acgTable=acgTable;
rawEphysData.qMetrics=qMetricsTable;
rawEphysData.ephysProperties=ephysProperties;
%SrawEphysData.qmetrics=
end