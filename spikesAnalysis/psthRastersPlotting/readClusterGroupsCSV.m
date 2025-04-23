

function [cids, cgs] = readClusterGroupsCSV(filename)
%function [cids, cgs] = readClusterGroupsCSV(filename)
% cids is length nClusters, the cluster ID numbers
% cgs is length nClusters, the "cluster group":
% - 0 = noise
% - 1 = mua
% - 2 = good
% - 3 = unsorted

fid = fopen(filename);
C = textscan(fid, '%s%s');
fclose(fid);

cids = cellfun(@str2num, C{1}(2:end), 'uni', false);
ise = cellfun(@isempty, cids);
cids = [cids{~ise}];

isNoise = cellfun(@(x)strcmp(x,'NOISE'),C{2}(2:end));
isNonSomatic = cellfun(@(x)strcmp(x,'NON-SOMA'),C{2}(2:end));
isMUA = cellfun(@(x)strcmp(x,'MUA'),C{2}(2:end));
isGood = cellfun(@(x)strcmp(x,'GOOD'),C{2}(2:end));
cgs = zeros(size(cids));

cgs(isGood) = 1;
cgs(isMUA) = 2;
cgs(isNonSomatic) = 3;