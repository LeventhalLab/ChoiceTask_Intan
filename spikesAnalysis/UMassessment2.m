function [goodMatches, MatchTable]=UMassessment2(MatchTable)

% Function to find and create an abbreviated table containing good matches
% and add a logical column to MatchTable for indexing

% Step 1: Initial match logic — same UID1 and UID2
sameUID = (MatchTable.UID1 == MatchTable.UID2);

% Step 2: Exclude self-matches (same unit/session)
isSelfMatch = (MatchTable.ID1 == MatchTable.ID2) & ...
              (MatchTable.RecSes1 == MatchTable.RecSes2);

% Step 3: Good match = same UID and not a self-match
goodMatchIdx = sameUID & ~isSelfMatch;

% Step 4: Add column to original MatchTable
MatchTable.MatchIdx = goodMatchIdx;

% Step 5: Create goodMatches subtable
goodMatches = MatchTable(goodMatchIdx, :);

end


