function goodMatches=UMassessment(MatchTable)
%Function to find and create an abreviated table containing good matches
MatchIdx=(MatchTable.UID1==MatchTable.UID2);
%MatchIdx finds cases where UID1=UID2 which should signify (if UM is
%correct) whether or not the units are the same or not
goodMatches=MatchTable(MatchIdx,:);
%Since this will create a table including a bunch of the same exact units, these
%need to be removed
selfMatchIdx = (goodMatches.ID1 == goodMatches.ID2) & ...
               (goodMatches.RecSes1 == goodMatches.RecSes2);
goodMatches(selfMatchIdx, :) = [];




