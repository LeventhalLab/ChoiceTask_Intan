function [smoothDiffArray, sleepEpochs] = getFrameDiff(videoFileName)
% Function to get the diffArray for a rat video
% Input: 
%   videoFileName - rat video file to analyze
% Output: 
%   smoothDiffArray - array of differences between pixels
%`  sleepEpochs - 2 x n array of frame indexes, start and end points of
%                   periods of inactivity, determined by threshold

v = VideoReader(videoFileName);
framesInterval = 40;
diffArray = [];
ii = 1;
smoothFactor = .2;
sleepEpochStart = [];
sleepEpochEnd = [];
thresh = 390;

%Go through frames and find difference in pixels
hWait = waitbar(0,'Analyzing Frames');
for f = 1 : framesInterval : v.NumberOfFrames - framesInterval
    waitbar(f/v.NumberOfFrames,hWait);
    %Read one frame
    curFrame = read(v, f);
    %Convert to B&W
    curFrame = im2bw(curFrame, .5);
    %Read next frame
    nextFrame = read(v, f + framesInterval);
    %Convert to B&W
    nextFrame = im2bw(nextFrame, .5);
    d = nextFrame - curFrame;
    %Get number of pixels that are different
    d = sum(d(:));
    %Store difference in array
    diffArray(ii) = d;
    ii = ii + 1;
end
close(hWait); clear('hWait');

smoothDiffArray = smooth(abs(diffArray), smoothFactor);

for jj = 2:length(smoothDiffArray) - 1
    if smoothDiffArray(jj) >= thresh && smoothDiffArray(jj + 1) < thresh
        sleepEpochStart = [sleepEpochStart jj];
    elseif smoothDiffArray(jj) < thresh && smoothDiffArray(jj + 1) >= thresh
        sleepEpochEnd = [sleepEpochEnd jj];
    else
    end
end

if length(sleepEpochStart) > length(sleepEpochEnd)
    l = length(sleepEpochStart) - length(sleepEpochEnd);
    L = zeros(1, l);
    L = L + length(smoothDiffArray);
    sleepEpochEnd = [sleepEpochEnd L];
end
    
sleepEpochs = [sleepEpochStart; sleepEpochEnd];
%to get time stamps, multiply by framesInterval and then divide by
%frameRate

end