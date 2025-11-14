function sessionSummary = Compile_choiceRTlogDataDaily(ratID, session, cur_dir)
%
% USAGE: sessionSummary = analyze_choiceRTlogDataDaily(ratID, implantSide)
%
% INPUTS:
%   ratID - string containing the rat ID (e.g., 'R0001'). Should have 5
%       characters
%   implantSide - use 'left' to indicate left implant. Anything else
%       assumed to be right. 'left' should be used as default (i.e., prior
%       to implantation)
%
% VARARGS:
%   'recordingdirectory' - 
%   'hostIP' - IP address of the sql DB host server

%   'user' - user name to login to the sql DB
%   'password' - password to login to the sql DB
%   'dbname' - name of the sql DB
%   'sqljava_version' - version of the sql-java interface
%   'toplevldir' - top level data directory - if applied, overrides query
%       of sql database to find the data storage directory
% OUTPUTS:
%   sessionSummary - structure containing session summary information from
%       the last .log file checked. This is mainly useful for
%       troubleshooting the software
%
% CHOICE RT DIFFICULTY LEVELS:
%   0 - Poke Any: rat pokes any port, as soon as it pokes a pellet is
%       delivered
%   1 - Very Easy: single port is lit, pellet delivered as soon as the port
%       is poked
%   2 - Easy: 
%   3 - Standard:  
%   4 - Advanced: 
%   5 - Choice VE: 
%   6 - Choice Easy: 
%   7 - Choice Standard: 
%   8 - Choice Advanced: 
%   9 - Testing: 
%
% UPDATE LOG:
% 08/27/2014 - don't have to navigate to the parent folder first, requires
%   user to specify the rat ID as an input argument

choiceRTdifficulty = cell(1, 10);
choiceRTdifficulty{1}  = 'poke any';
choiceRTdifficulty{2}  = 'very easy';
choiceRTdifficulty{3}  = 'easy';
choiceRTdifficulty{4}  = 'standard';
choiceRTdifficulty{5}  = 'advanced';
choiceRTdifficulty{6}  = 'choice VE';
choiceRTdifficulty{7}  = 'choice easy';
choiceRTdifficulty{8}  = 'choice standard';
choiceRTdifficulty{9}  = 'choice advanced';
choiceRTdifficulty{10} = 'testing';





%paper dimensions # centimeters units
% X = 21.0;                  %# A3 paper size
% Y = 29.7;                  %# A3 paper size
% xMargin = 1;               %# left ht margins from page borders
% yMargin = 1;               %# bottom/top margins from page borders
% xSize = X - 2*xMargin;     %# figure size on paper (width)
% ySize = Y - 2*yMargin;     %# figure size on paper (height)

%font
fontTitle=25;
fontFigure=18;

% numFolders = length(direct) - 3;

sessionSummary = initSessionSummary();

cd(cur_dir)




    RTbins = 0.05 : 0.05 : 0.95;
    MTbins = 0.05 : 0.05 : 0.95;

    dirs=dir(fullfile(pwd,'*.log'));
    numLogs = length(dirs);
    for iLog = 1 : length(dirs)
        if isempty(strfind(dirs(iLog).name, 'old'))
            validLogIdx = iLog;
            break;
        end
    end


    logData = readLogData(dirs(validLogIdx).name);
    taskLevel=choiceRTdifficulty{logData.taskLevel+1};
    sessionSummary.taskLevel=taskLevel;
        
        sessionSummary.correct      = (logData.outcome == 0);
        sessionSummary.wrongMove    = (logData.outcome == 5);
        sessionSummary.complete     = sessionSummary.correct | sessionSummary.wrongMove;
        sessionSummary.falseStart   = (logData.outcome == 1);
        sessionSummary.wrongStart   = (logData.outcome == 3);
        sessionSummary.targetRight  = (logData.Target > logData.Center);
        sessionSummary.moveRight    = (logData.SideNP > logData.Center);
        sessionSummary.ftr          = (logData.outcome == 4 | logData.outcome == 6);
        sessionSummary.LHviol       = (logData.outcome == 4);
        sessionSummary.MHviol       = (logData.outcome == 6);

            sessionSummary.targetContra = ~sessionSummary.targetRight;
            sessionSummary.targetIpsi   = sessionSummary.targetRight;

            sessionSummary.moveContra   = ~sessionSummary.moveRight & logData.SideNP > 0;
            sessionSummary.moveIpsi     = sessionSummary.moveRight;
        
        correctTargetContra = sessionSummary.correct & sessionSummary.targetContra;
        correctTargetIpsi   = sessionSummary.correct & sessionSummary.targetIpsi;

        completeTargetContra = sessionSummary.complete & sessionSummary.targetContra;
        completeTargetIpsi   = sessionSummary.complete & sessionSummary.targetIpsi;

        sessionSummary.acc(1) = sum(correctTargetIpsi) / sum(completeTargetIpsi);
        sessionSummary.acc(2) = sum(correctTargetContra) / sum(completeTargetContra);
        sessionSummary.acc(3) = sum(sessionSummary.correct) / sum(sessionSummary.complete);

        %center accuracy
        correctCenter2   = sessionSummary.correct & logData.Center == 2;
        correctCenter3   = sessionSummary.correct & logData.Center == 4;
        correctCenter4   = sessionSummary.correct & logData.Center == 8;

        completeTargetCenter2 = sessionSummary.complete & logData.Center == 2;
        completeTargetCenter3   = sessionSummary.complete & logData.Center == 4;
        completeTargetCenter4   = sessionSummary.complete & logData.Center == 8;
        sessionSummaryCenter.acc(1) = sum(correctCenter2) / sum(completeTargetCenter2);
        sessionSummaryCenter.acc(2) = sum(correctCenter3) / sum(completeTargetCenter3);
        sessionSummaryCenter.acc(3) = sum(correctCenter4) / sum(completeTargetCenter4);

        plotMatrix = [zeros(3, 3)];
        % ipsi, contra, all number of attempts
        
        
        
        
        
        
        sessionSummary.ipsiRT   = logData.RT(completeTargetIpsi);
        sessionSummary.contraRT = logData.RT(completeTargetContra);
        sessionSummary.allRT    = logData.RT(sessionSummary.complete);

       
        
        
       
        sessionSummary.ipsiMT   = logData.MT(completeTargetIpsi);
        sessionSummary.contraMT = logData.MT(completeTargetContra);
        sessionSummary.allMT    = logData.MT(sessionSummary.complete);

        

     
        sessionSummary.ipsiRTMT   = logData.MT(completeTargetIpsi) + logData.RT(completeTargetIpsi);
        sessionSummary.contraRTMT = logData.MT(completeTargetContra) + logData.RT(completeTargetContra);
        sessionSummary.allRTMT    = logData.MT(sessionSummary.complete) + logData.RT(sessionSummary.complete);

       
 end
