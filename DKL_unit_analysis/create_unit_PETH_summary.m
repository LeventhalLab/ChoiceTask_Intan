function create_unit_PETH_summary(unit_struct, unit_name)

name_parts = split(unit_name, '_');
ratID = name_parts{1};
session_name = name_parts{2};
unit_num = str2num(name_parts{4});
expt_group = name_parts{6};

ts = unit_struct.unitMetrics.clusterSpikes(~isnan(unit_struct.unitMetrics.clusterSpikes));

% unit_struct.unitMetrics.ephysProperties.maxChannels is the channel with
% the maximum waveform amplitude, based on XXX numbering
[h_fig, t] = create_PETHs_layout(8, 7);

% create header strip
ax = nexttile([1 2]);
axis off
text_str = sprintf('%s, %s, unit %d', ratID, session_name, unit_num);
text(0.1, 0.9, text_str, 'units', 'normalized')

autocorr = autocorrelogram(ts, 0.01, [-0.1, 0.1]);

end