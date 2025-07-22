function rawEphysData=loadUnitData(ephysKilosortPath,unique_clusters)


qMetricsPath=fullfile(ephysKilosortPath,'qMetrics');
unitWaveformsPath=fullfile(qMetricsPath,'RawWaveforms');
qMetricsTable=parquetread(fullfile(qMetricsPath,'templates._bc_qMetrics.parquet'));
%refractPeriodTable=parquetread(fullfile(qMetricsPath,'templates._bc_fractionRefractoryPeriodViolationsPerTauR.parquet'));
ephysPropTable=parquetread(fullfile(qMetricsPath,'_bc_parameters._bc_ephysProperties.parquet'));
acgTable=parquetread(fullfile(qMetricsPath,'templates._bc_acg.parquet'));

qMetricsTable = qMetricsTable(ismember(qMetricsTable.phy_clusterID, unique_clusters), :);
keepRows = false(height(acgTable), 1);

for i = 1:length(unique_clusters)
    idx = unique_clusters(i) + 1; % because cluster 0 is row 1, cluster 1 is row 2, etc.
    if idx <= height(acgTable)
        keepRows(idx) = true;
    end
end

% Keep only the rows that match
acgTable = acgTable(keepRows, :);
rawEphysData={};
rawEphysData.rawWaveformsPath=unitWaveformsPath;
rawEphysData.acgTable=acgTable;
rawEphysData.qMetrics=qMetricsTable;
%SrawEphysData.qmetrics=
end