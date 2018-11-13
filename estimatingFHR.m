%
%   OVERVIEW:
%       This script calculates the FHR from a test Doppler Ultrasound using
%       the function getFRH
%
%   REFERENCE: 
%   Camilo E. Valderrama, Lisa Stroux, Nasim Katebi, Elianna Paljug, 
%   Faezeh Marzbanrad, Gari D. Clifford. An open source autocorrelation-based 
%   method for fetal heart rate estimation from one-dimensional Doppler ultrasound, 
%   Physiological Measurement, 2019 (In Press).
%
%	REPO:       
%       https://github.com/cliffordlab/fhr_dus1
%   ORIGINAL SOURCE AND AUTHORS:     
%       Written by Camilo E. Valderrama (cvalder@emory.com) on Nov, 08/2018.
%       Dependent scripts written by various authors 
%       (see functions for details)       
%	
%   LICENSE:    
%   
%   Copyright (c) 2018, CliffordLab
%   All rights reserved.
% 
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are met:
% 
%   1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%   2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
% 
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
%   ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
%   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 
%   The views and conclusions contained in the software and documentation are those
%   of the authors and should not be interpreted as representing official policies,
%   either expressed or implied, of the FHR estimation project.


clc;clear; close all;


%% Loading function parameters

FHRparams = loadParameters();


%% Estimating FHR from Ultrasound recordings

recordings = dir(strcat(FHRparams.pathRecording,'*wav'));   % Loading the wav files contained in the recording folder


totalRecordings = length(recordings); %Total number of recordings


windowLength = 3.75; %Size DusSegment in seconds
sliddingWindow = 0.25; %Sliding window - DUS devices calculate FHR every 250 ms

for idxRecordings=1:totalRecordings
    
    %Loading the DUS recording
    [dusRecoding,samplingFrequency] = audioread(strcat(FHRparams.pathRecording,recordings(idxRecordings).name));
    
    
    % Checking the DUS recording has a sampling frequency of 4000 Hz
    % In this case, the sampling is different, the recording is downsampled
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


