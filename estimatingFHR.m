%
%   OVERVIEW:
%       This script calculates the FHR from a test Doppler Ultrasound using
%       the function getFRH


clc;clear; close all;


%% Loading function parameters

FHRparams = loadParameters();


%% Estimating FHR from Ultrasound recordings

recordings = dir(strcat(FHRparams.pathRecording,'*wav'));   % Loading the wav files contained in the recording folder


totalRecordings = length(recordings); %Total number of recordings


windowLength = 3.75; %Size DusSegment
sliddingWindow = 0.25; %Sliding window - DUS devices calculates FHR every 25 ms

for idxRecordings=1:totalRecordings
    
    %Loading the DUS recording
    [dusRecoding,samplingFrequency] = audioread(strcat(FHRparams.pathRecording,recordings(idxRecordings).name));
    
    
    % Checking the DUS recording has a sampling frequency of 4000 Hz
    % In case, the sampling is different, the recording is downsampled
    if samplingFrequency~=FHRparams.Fs
        dusSignal =  resample(dusRecoding,FHRparams.Fs,samplingFrequency);
    else
        dusSignal = dusRecoding;
    end
    
    
    % The FHR is calculated using a segment of 3.75 seconds every 0.25
    % seconds
    
    dusSegmentSize = windowLength*FHRparams.Fs;  % DUS window to estimate FHR
    shiftWindow = sliddingWindow*FHRparams.Fs;     % Slidding window
    
    %Number of windows contained in the DUS recording
    numberWindows = floor((length(dusSignal)-dusSegmentSize)/shiftWindow);
    numberWindows = numberWindows+1; %Adding last window
    
    %Array to store FHR of each window
    fetalHeartRate = nan(numberWindows,1);
    
    
    %Iterating over DUS recording
    endSegment = dusSegmentSize;
    startSegment = endSegment-dusSegmentSize+1;
    windowIdx=1;
    while windowIdx <= numberWindows
        % Extracting current segment of 3.75 s
        dusSegment = dusSignal( startSegment:endSegment );
        
        % Call FHR estimation function
        fetalHeartRate(windowIdx)= getFHR(dusSegment, FHRparams.Fs, ...
            FHRparams.minPeriod, FHRparams.maxPeriod, FHRparams.Hd, FHRparams.cutFreq,...
            FHRparams.ratioFirstPeak);
        
        % Updating indexes for next segments
        endSegment = endSegment+shiftWindow;
        startSegment = endSegment-dusSegmentSize+1;
        
  
        % Updating window index
        windowIdx = windowIdx+1;
    end
    
    
    % printing information of the DUS signal
    fprintf("Info recording %i\n", idxRecordings);
    fprintf("Name recording: %s\n", recordings(idxRecordings).name);
    fprintf("Duration recording: %f seconds.  \n", length(dusSignal)/FHRparams.Fs );
    fprintf("Number of 3.75 s segments: %i windows.  \n", numberWindows);
    fprintf("Median FHR of the segment: %f Hz\n", nanmedian(fetalHeartRate));
    fprintf("******************************************\n\n");
    
    
end


