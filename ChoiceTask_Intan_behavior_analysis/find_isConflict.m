<<<<<<< HEAD
% Is this the easiest way to perform this?? Maybe write these lines as an
% actual function so each line doesn't need to be called. (Looking into
% this JM 4/16/20)

logConflict = vertcat(trials.logConflict);
isConflict = vertcat(logConflict.isConflict);
    % returns isConflict logical array of isConflict fields
isConflictOnly = find(isConflict);
    % pulls out actual fields with error
boxLogConflict = vertcat(logConflict.boxLogConflicts); 
    % returns boxConflict in workspace with fields for outcome, RT, MT, pretone, centerNP sideNP

%% Code Practice for Patch
boxLogConflicts.MT = ~(abs(logTrial.MT - trialData.timing.movementTime) < timingTolerance);

trialData.movementTooLong = 0;
trialData.falseStart = 0;



%% These next few lines are for reference purposes based on logConflict data
% from R0326_20200228a
logData.outcome(37)
% ans = 6
isOutcome6 = find(logData.outcome == 6); % Finds other trials in the LogData structure with value == 6
%Note not all outcome == 6 have the same reasoning for the isConflict error. Patch
%out only the necessary trials. This line can be manipulated for any trial
%error.
z = trials(isLogConflictOnly) % creates a structure of 37, 120, and 175 ...
%(logConflict (with movement time to sideNP outcome recorded as zero))

%But why is isConflict.outcome == 0
z(3).timing.reactionTime + z(3).timing.movementTime % this equation calcuates movement hold
% if value is > 1, boxLogConflicts is recorded as 0 but the system does
% record the sideNP that rat poked (is a correct trial, but outcome =
% isConflict. Write patch to fix.

y = trials(isOutcome6) % creates a 1x13 structure of all trials that had an ... 
% outcome = 6 (useful in comparing where the actual issue lies)
y(3).timing.reactionTime + y(3).timing.movementTime % equation is irrelevant as rat did not poke sideNP
% this issue is different than rats that DID poke sideNP but sideNP wasn't
% recorded.

=======
% Is this the easiest way to perform this?? Maybe write these lines as an
% actual function so each line doesn't need to be called. (Looking into
% this JM 4/16/20)

logConflict = vertcat(trials.logConflict);
isConflict = vertcat(logConflict.isConflict);
    % returns isConflict logical array of isConflict fields
isConflictOnly = find(isConflict);
    % pulls out actual fields with error
boxLogConflict = vertcat(logConflict.boxLogConflicts); 
    % returns boxConflict in workspace with fields for outcome, RT, MT, pretone, centerNP sideNP

%% Code Practice for Patch
boxLogConflicts.MT = ~(abs(logTrial.MT - trialData.timing.movementTime) < timingTolerance);

trialData.movementTooLong = 0;
trialData.falseStart = 0;



%% These next few lines are for reference purposes based on logConflict data
% from R0326_20200228a
logData.outcome(37)
% ans = 6
isOutcome6 = find(logData.outcome == 6); % Finds other trials in the LogData structure with value == 6
%Note not all outcome == 6 have the same reasoning for the isConflict error. Patch
%out only the necessary trials. This line can be manipulated for any trial
%error.
z = trials(isLogConflictOnly) % creates a structure of 37, 120, and 175 ...
%(logConflict (with movement time to sideNP outcome recorded as zero))

%But why is isConflict.outcome == 0
z(3).timing.reactionTime + z(3).timing.movementTime % this equation calcuates movement hold
% if value is > 1, boxLogConflicts is recorded as 0 but the system does
% record the sideNP that rat poked (is a correct trial, but outcome =
% isConflict. Write patch to fix.

y = trials(isOutcome6) % creates a 1x13 structure of all trials that had an ... 
% outcome = 6 (useful in comparing where the actual issue lies)
y(3).timing.reactionTime + y(3).timing.movementTime % equation is irrelevant as rat did not poke sideNP
% this issue is different than rats that DID poke sideNP but sideNP wasn't
% recorded.

>>>>>>> 8d0d652ac5e71a1aa58337014169463ffbcb21d7
