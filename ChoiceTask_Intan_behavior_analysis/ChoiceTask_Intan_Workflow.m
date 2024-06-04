%% Have 'Intan Data Folder' open in 'Current Folder'
tic;
intan_data = read_Intan_RHD2000_file_DL('info.rhd');
%   location -  GitHub\ intan_fileio

digital_data = readIntanDigitalFile('digitalin.dat');
% location – GitHub\ intan_fileio
% Must have the path in the ‘current folder’ to run function or an error (line 29) will occur

nexData = intan2nex('digitalin.dat', 'analogin.dat', intan_data); 
% location -GitHub\ChoiceTask_Intan\ChoiceTask_Intan_behavior_analysis
% Dependencies: read_Intan_RDH2000_file_DL; digital_data and analog_data are written into the function lines 127/128 (but it’s convenient to have the digital_data in the workspace)

check_nexData(nexData); % uses the ‘nexData’ function as a dependency and provides on/off information. Location of file: Github\LeventhalWorkflow
%Don't necessarily need the check_nexData line but its useful information
toc;
%% Separated - have 'behavior data' folder open in 'current folder' (change 'fname' to relevant filename)
logData = readLogData('R0326_20200226_08-54-14.log'); 
% location -  Github\LeventhalWorkflow\ChoiceRTBehavior

%% Have 'Intan Data Folder' open
trials = createTrialsStruct_simpleChoice_Intan(logData, nexData)
% location – GitHub\ChoiceTask_Intan\ChoiceTask_Intan_behavior_analysis
% Dependencies: readLogData, intan2nex, read_Intan_RHD2000_file_DL
%% Patch for trialData.timestamps.sideIn = sideInAfterCue(1); % Session ends mid-trial
if ~nose_out_event && logTrial.Time >= logTrial.maxTime   % there was no nose-in event or nose-out event; this must have been the last trial and it wasn't completed
    return;
end
% So in line 447 - its hiccuping because the nexData file recorded the ==5
% response when it shouldn't have.

% Trial 162 sideOut happens AFTER maxTime (3600) AND is wrong ( == 5) 
%but counted as correct becuase the Foodport sensor activated at the end of the session.
%% Locate in the trials structure any trials that have conflicts (use find_isConflict code; no current ‘function’ as of 4/16/2020; JM is working on turning it into a function)
logConflict = vertcat(trials.logConflict);
isConflict = vertcat(logConflict.isConflict); %returns isConflict in a logical array of isConflict fields
isConflictOnly = find(isConflict); %pulls out actual fields with error
boxLogConflict =  vertcat(logConflict.boxLogConflicts); % returns boxConflict in workspace with fields for outcome, RT, MT, pretone, centerNP sideNP
