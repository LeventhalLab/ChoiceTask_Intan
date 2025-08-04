parent_directory = 'X:\Neuro-Leventhal\data\ChoiceTask';
ratID = 'R0460';
    
rat_folder = fullfile(parent_directory, ratID);

%% find session dirs
if ~exist(fullfile(rat_folder,'MatchingUnits/UnitMatch'))
    keyboard
end
UMSaveDir = fullfile(rat_folder,'MatchingUnits/UnitMatch'); 


%% -- Evaluating the output -- (optional)

%% If you want, you can run additional scripts to evaluate the results:

% Within session cross-validation
EvaluatingUnitMatch(UMSaveDir); 

% Evaluating the matching using functional scores (only works when having access to Kilosort output, e.g. spike times etc. )
ComputeFunctionalScores(UMSaveDir)


%% You can also visualize the units on the probe:
load(fullfile(UMSaveDir,'UnitMatch.mat'))
load(fullfile(UMSaveDir,'UnitMatchModel.mat'))
load(fullfile(UMSaveDir,'MatchingScores.mat'))
load(fullfile(UMSaveDir,'AUC.mat'))
%PlotUnitsOnProbe(clusinfo,UMparam,UniqueIDConversion,WaveformInfo)
[goodMatches,MatchTable]=UMassessment2(MatchTable);
goodTbl = Tbl(MatchTable.MatchIdx, :);
uncuratedMatchTable=MatchTable;
% uncuratedTbl=Tbl;
% 
% % Save uncuratedMatchTable to UnitMatch.mat
% save(fullfile(UMSaveDir, 'UnitMatch.mat'), 'uncuratedMatchTable', '-append');
% 
% % Save uncuratedTbl to MatchingScores.mat
% save(fullfile(UMSaveDir, 'MatchingScores.mat'), 'uncuratedTbl', '-append');
% 
% Tbl=goodTbl;
% MatchTable=goodMatches;
%% Curation:
if UMparam.MakePlotsOfPairs
    DrawPairsUnitMatch(UMparam.SaveDir);
    if UMparam.GUI
        FigureFlick(UMparam.SaveDir)
        pause
    end
end

%% If using bombcell

% Evaluating how much quality metrics predict "matchability" (only works in combination with bombcell)
QualityMetricsROCs(UMparam.SaveDir); 

%% The following scripts work with several animals and plot summaries of the matching evaluation.

UMFiles = {fullfile(UMparam.SaveDir,'UnitMatch.mat')}; % cell containing a list of all the UnitMatch outputs you want to combine -- let's use one for now.
groupvec = 1; % How do you want to group these outputs? E.g., group all the outputs from the same animal into one

% Plots a summary of the functional metrics results
summaryFunctionalPlots(UMFiles, 'Corr', groupvec); 

% Plots a summary of the matching probability
summaryMatchingPlots(UMFiles); 
