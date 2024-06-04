function nexData = intan2nex_from_fnames(dig_fname,analog_fname,intan_info,varargin)
%
% usage: nexData = intan2nex(dig_fname,analog_fname,intan_info,varargin)
%
% function to read in timestamps from intan digital and analog in lines and
% convert to a .nex file with events for the choice task
%
% INPUTS:
%   dig_fname - name of digital input file recorded with the intan system.
%       These are generally digital lines from the NI boards running the
%       choice task.
%   analog_fname - name of analog input file recorded with the intan system.
%       These are generally digital lines from the NI boards running the
%       choice task, plugged into analog lines if we run out of digital 
%       lines. Note that as of 3/26/2020, the line names are hard-coded in
%       the dig_linenames = ... and analog_linenames = ... lines below.
%   intan_info - data structure containing info read in from the rhd file
%       .XXX - 
%   TO ADD HERE: DESCRIPTION OF THE INFORMATION IN THE INTAN_INFO FILE,
%   WHICH I THINK IS WHAT'S READ IN FROM THE .RHD FILE
%
% VARARGS:
%   'writefile' - whether or not to write the nex formatted data to a new
%       file; default filename is the original filename with .nex appended
%       - that is, should be "XXXX.box.nex" where XXXX is the original base
%       filename. NOT SURE IF WE STILL NEED THIS
%
% OUTPUTS:
%   nexData - nex data structure
%   nexData.version - file version
%   nexData.comment - file comment
%   nexData.tbeg - beginning of recording session (in seconds)
%   nexData.tend - end of resording session (in seconds)
%
%   nexData.neurons - array of neuron structures
%           neurons.name - name of a neuron variable
%           neurons.timestamps - array of neuron timestamps (in seconds)
%               to access timestamps for neuron 2 use {n} notation:
%               nexData.neurons{2}.timestamps
%
%   nexData.events - array of event structures
%           event.name - name of neuron variable
%           event.timestamps - array of event timestamps (in seconds)
%               to access timestamps for event 3 use {n} notation:
%               nexData.events{3}.timestamps
%
%   nexData.intervals - array of interval structures
%           interval.name - name of neuron variable
%           interval.intStarts - array of interval starts (in seconds)
%           interval.intEnds - array of interval ends (in seconds)
%
%   nexData.waves - array of wave structures
%           wave.name - name of neuron variable
%           wave.NPointsWave - number of data points in each wave
%           wave.WFrequency - A/D frequency for wave data points
%           wave.timestamps - array of wave timestamps (in seconds)
%           wave.waveforms - matrix of waveforms (in milliVolts), each
%                             waveform is a vector 
%
%   nexData.contvars - array of contvar structures
%           contvar.name - name of neuron variable
%           contvar.ADFrequency - A/D frequency for data points
%
%           continuous (a/d) data come in fragments. Each fragment has a timestamp
%           and an index of the a/d data points in data array. The timestamp corresponds to
%           the time of recording of the first a/d value in this fragment.
%
%           contvar.timestamps - array of timestamps (fragments start times in seconds)
%           contvar.fragmentStarts - array of start indexes for fragments in contvar.data array
%           contvar.data - array of data points (in milliVolts)
%
%   nexData.markers - array of marker structures
%           marker.name - name of marker variable
%           marker.timestamps - array of marker timestamps (in seconds)
%           marker.values - array of marker value structures
%           	marker.value.name - name of marker value 
%           	marker.value.strings - array of marker value strings
%
%
% make it optional to supply a file or list of files; if none supplied,
% then use uigetfile
%
% change log:
%   8/1/12: found that sometimes you get "pops" from high to low to high,
%       but can also get them low to high to low. Added code to take
%       account of this possibility.
%   03/25/2020 - this may not be necessasry anymore

analog_thresh = 2;    % volts

writeFile = true;

% names of what each digital line represents. I think this is correct as of
% 3/25/2020. -DL
dig_linenames = {'', 'foodport', 'food', 'nose5', 'houselight', 'nose4', ...
             'cue5', 'nose3', 'cue4', 'nose2', 'cue3', 'nose1', ...
             'cue2', 'gotrial', 'cue1', 'camframe'};
% names of what each analog line represents. I think this is correct as of
% 3/25/2020. -DL
analog_linenames = {'tone1','tone2','whitenoise'};

% concatenate the linenames so we have a full list
all_linenames = [dig_linenames,analog_linenames];

for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'writefile'
            writeFile = varargin{iarg + 1};
        case 'analog_thresh'
            analog_thresh = varargin{iarg + 1};
    end
end
	
num_dig_lines = length(dig_linenames);
% num_analog_lines = length(analog_linenames);

dig_in = readIntanDigitalFile(dig_fname);

% 	numLines = 16;             % 16 digital in lines on the intan system. doesn't count the analog in lines being used as digital lines
numBytesPerSample = 2;     % assume uint16's
totalBytes = length(dig_in) * numBytesPerSample;

% pull in the sample rate from the intan_info structure
nSampleRate = max(intan_info.frequency_parameters.board_adc_sample_rate,...
    intan_info.frequency_parameters.board_dig_in_sample_rate);   % these should always be the same
maxNumEvents = 20000; % will choke if there are more than this many events on a line

% Set up the NEX file data structure
nexData.version = 100;
nexData.comment = 'Converted by intan2nex.m. Dan Leventhal and Jen Magnusson, 2020';
nexData.freq = nSampleRate;
nexData.tbeg = 0;
nexData.tend = totalBytes/(numBytesPerSample*nSampleRate);
nexData.events = {};
on.events = {};
off.events = {};

nSamples = length(dig_in);

dataOffset = 0;

usedLines = [];
numUsedLines = 0;
num_usedDigLines = 0;
numLines = length(all_linenames);
for i=1:numLines
    if strcmp(all_linenames{i}, ''); continue; end
    numUsedLines = numUsedLines + 1;
    if i <= num_dig_lines
        num_usedDigLines = num_usedDigLines + 1;
    end
    usedLines(end+1) = i;

    % create nexData.events for each time a line goes "high" or "low". Note
    % that transitions from high to low are actually lights turning on,
    % nose ports becoming occupied, etc.
    
    % COMMENTS BELOW NOT RELEVANT RIGHT NOW (3/25/2020) BECAUSE WE'RE NOT USING
    % OPTOGENETICS IN THESE EXPERIMENTS...
    % this chunk of code will name the events differently for laser
    % and shutter lines. 'On' events are generally going from high
    % to low (ie, nose-pokes, lighting cue lights, etc) because the
    % relays to the MedAssociates boxes are inverted. Laser "on"
    % events, however, are indicated by low to high transitions.
    % The laser shutter opens on a high value and closes on a low
    % value. -DL 02/03/2012
    if contains(lower(all_linenames{i}), 'laser')
        % this is a laser line
        nexData.events{end+1}.name = [all_linenames{i} 'Off'];
        nexData.events{end}.timestamps = {};

        nexData.events{end+1}.name = [all_linenames{i} 'On'];
        nexData.events{end}.timestamps = {};

    elseif contains(lower(all_linenames{i}), 'video')
        % this is a video trigger line
        nexData.events{end+1}.name = [all_linenames{i} 'Off'];
        nexData.events{end}.timestamps = {};

        nexData.events{end+1}.name = [all_linenames{i} 'On'];
        nexData.events{end}.timestamps = {};

    elseif contains(lower(all_linenames{i}), 'shutter')
        % this is a shutter line
        nexData.events{end+1}.name = [all_linenames{i} 'Closed'];
        nexData.events{end}.timestamps = {};

        nexData.events{end+1}.name = [all_linenames{i} 'Open'];
        nexData.events{end}.timestamps = {};

    elseif contains(lower(all_linenames{i}), 'nose')
        % this is a nose in/out line
        nexData.events{end + 1}.name = [all_linenames{i} 'In'];
        nexData.events{end}.timestamps = {};

        nexData.events{end + 1}.name = [all_linenames{i} 'Out'];
        nexData.events{end}.timestamps = {};

    else
        % all other channels            
        nexData.events{end+1}.name = [all_linenames{i} 'On'];
        nexData.events{end}.timestamps = {};

        nexData.events{end+1}.name = [all_linenames{i} 'Off'];
        nexData.events{end}.timestamps = {};
    end

end

allLines = false(numUsedLines, nSamples);
allOnEvents = zeros(numUsedLines, maxNumEvents); % maximum 20000 events or so
allOffEvents = zeros(numUsedLines, maxNumEvents);
onEventIdx = ones(numUsedLines,1);
offEventIdx = ones(numUsedLines,1);

analog_in = readIntanAnalogFile(analog_fname, intan_info.board_adc_channels);

% Collect line values from every line we care about
for i=1:numUsedLines
    if i <= num_usedDigLines
        allLines(i,:) = bitget(dig_in, usedLines(i));
    else
        analog_idx = i - num_usedDigLines;
        try
        allLines(i,:) = (analog_in(analog_idx,:) > analog_thresh);
        catch
            keyboard
        end
    end
end        

    % Sometimes all the lines are low at the same time
    % This is incorrect, and we're going to fix it right here
    % in software.
    % NOTE: this doesn't explicitly detect "pops", where 
    % the lines go low then high again, but instead
    % just detects whether all lines are low. Should be fine, I _think_...
    % above is from AW.

    % this needs to be changed because it's not always true that
    % ALL lines "pop" simultaneously. Rewrite the algorithm to
    % detect transitions to "low" and then immediately back to
    % "high". This happens one SOME but not all lines every time a
    % digital port read is initiated in LV. Fucking annoying. There
    % may be a way to fix this with a clever combination of
    % resistors, but I think this software work-around will be OK.
    
    % hopefully, this isn't a problem in the Intan system, so I commented it
    % out - DL, 12/2019
            
%     for iLine = 1 : numLines
%         highIdx = find([lastSamp(iLine), allLines(iLine,:)] == 1);
%         % compute spacing between high values along each line
%         if isempty(highIdx); continue; end;
% 
%         highDiff = diff(highIdx);
%         popIdx = (highDiff == 2);   % find indices of events where line went from high to low to high in 3 samples
% 
%         % 8/1/12 DL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         lowIdx  = find([lastSamp(iLine), allLines(iLine,:)] == 0);
%         lowDiff = diff(lowIdx);    
%         inversePopIdx = (lowDiff == 2);    % find indices of events where line went from low to high to low in 3 samples
%         % 8/1/12 DL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%         allLines(iLine, highIdx(popIdx)) = 1;
%         allLines(iLine, lowIdx(inversePopIdx)) = 0;  % 8/1/12 DL
%     end
% 
%             % below is left-over from when a line pop was considered when
%             % ALL lines go low simultaneously
% % 			for i=1:length(idx)
% %                 
% % 				allLines(:,idx(i)) = allLines(:,idx(i)-1);
% % 			end
% 		
% Now we'll extract on and off times
for i=1:numUsedLines
    % A channel is considered to have flipped "on" when it goes from 1 to 0
    % A channel is considered to have flipped "off" when it goes from 0 to 1

    % added lastSamp into the calculation below to account for
    % the possibility that a transition takes place exactly
    % where a new block of values is loaded. -DL 20110627
    onTimes  = find( diff(allLines(i,:)) == -1 )/nSampleRate;
    offTimes = find( diff(allLines(i,:)) ==  1 )/nSampleRate;
    numOn = length(onTimes);
    numOff = length(offTimes);
    allOnEvents(i,onEventIdx(i):onEventIdx(i)+numOn-1) = onTimes;
    allOffEvents(i,offEventIdx(i):offEventIdx(i)+numOff-1) = offTimes;
    onEventIdx(i) = onEventIdx(i) + numOn;
    offEventIdx(i) = offEventIdx(i) + numOff;
end

% lastSamp = allLines(:, end);
%             

	
% Stick in the events
for i=1:numUsedLines
    nexData.events{i*2-1}.timestamps  = unique(allOnEvents(i,1:onEventIdx(i)-1)');
    nexData.events{i*2}.timestamps	  = unique(allOffEvents(i,1:offEventIdx(i)-1)');
end
nexData.events = nexData.events';

% Make intervals
nexData.intervals = {};
for i=1:numUsedLines		

    intStarts = nexData.events{i*2-1}.timestamps;
    intEnds   = nexData.events{i*2}.timestamps;

    if isempty(intEnds) || isempty(intStarts); continue; end

    intEnds = intEnds( intEnds > intStarts(1) );

    if isempty(intEnds); continue; end
    intStarts = intStarts( intStarts < intEnds(end) );

    nexData.intervals{end+1}.name = all_linenames{usedLines(i)};
    nexData.intervals{end}.intStarts = intStarts; % notice we used end+1 above. that created the entry, and now we can just refer to it as "end"
    nexData.intervals{end}.intEnds = intEnds;
end
nexData.intervals = nexData.intervals'; % stupid, STUPID requirement for writeNexFile...

%     if writeFile
%         writeNexFile(nexData, [filename '.nex']);
%     end

