%%
%OVERVIEW
%   This script tests if the functions in this repo run correctly 
%   using two sample recordings, test1.wav and test2.wav in the
%   subdirectory ../Recordings

%   REFERENCE: 
%   Camilo E. Valderrama, Lisa Stroux, Nasim Katebi, Elianna Paljug, 
%   Faezeh Marzbanrad, Gari D. Clifford. An open source autocorrelation-based 
%   method for fetal heart rate estimation from one-dimensional Doppler ultrasound, 
%   Physiological Measurement, 2019 (In Press).
%
%	REPO:       
%       https://github.com/cliffordlab/fhr_dus1
%
%   ORIGINAL SOURCE AND AUTHORS:     
%       Written by Camilo E. Valderrama (cvalder@emory.com) on Nov, 08/2018.
%       Dependent scripts written by various authors 
%       (see functions for details)       
%	
%   LICENSE:    
%   BSD 2-Clause License
% 
%   Copyright (c) 2018, gariclifford
%   All rights reserved.
% 
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are met:
% 
%   * Redistributions of source code must retain the above copyright notice, this
%     list of conditions and the following disclaimer.
% 
%   * Redistributions in binary form must reproduce the above copyright notice,
%     this list of conditions and the following disclaimer in the documentation
%     and/or other materials provided with the distribution.
% 
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
%   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
%   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

clc;clear; close all;


%% Load function parameters

FHRparams = loadParameters();


%% Estimate FHR from Ultrasound recordings

recordings = dir(strcat(FHRparams.pathRecording,'*wav'));   % Loading the wav files contained in the recording folder


totalRecordings = length(recordings); %Total number of recordings


windowLength = 3.75; %Size DusSegment
sliddingWindow = 3.75; %Sliding window

recordingsFHR = struct();

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
        
        %Store the FHR of the window of the recording
        recordingsFHR.(recordings(idxRecordings).name(1:end-4)).(strcat('w_',num2str(windowIdx))).('FHR') = fetalHeartRate(windowIdx);
        
        % Updating window index
        windowIdx = windowIdx+1;
    end
    
    
    
    
end


%% Loading files values

fid = fopen('gs_output.csv');
tline = fgetl(fid); %Discard first line scince it is headers.
tline = fgetl(fid); %Second line
while ischar(tline)
    
    atoms = strsplit(tline,','); %Getting each value of the line: 1) recording name 2)window idx 3) FHR
    
    nameRecording = strtrim(atoms{1});%Name of the recording
    nameRecording = nameRecording(1:end-4); %Removing file extension
    windowIdx  = str2double(atoms{2}); %Window of the recording
    FHR_gold  = str2double(atoms{3});%Gold standard comparison value
    
    FHR_local = recordingsFHR.(nameRecording).(strcat('w_',num2str(windowIdx))).FHR; %Local FHR
    
    %In case the window was able to be estimated, the difference between
    %gold standard and local FHR is calculated
    if  ~isnan(FHR_gold)
        if ~isnan(FHR_local)
            %In case FHR is not NaN - FHR_local was able to be estimated
            recordingsFHR.(nameRecording).(strcat('w_',num2str(windowIdx))).diff = abs(FHR_local -FHR_gold); %storing difference
        else
             %One was NaN and the other not --error
             recordingsFHR.(nameRecording).(strcat('w_',num2str(windowIdx))).diff = 10;
        end
    else
        if isnan(FHR_local)
            %If the gold standard was NaN, and the local FHR is also NaN, 
            %there is no difference 
            recordingsFHR.(nameRecording).(strcat('w_',num2str(windowIdx))).diff = 0;
        else
            %One was NaN and the other not --error
            recordingsFHR.(nameRecording).(strcat('w_',num2str(windowIdx))).diff = 10;
        end
    end
    
    tline = fgetl(fid); %Next line
end
fclose(fid);

%% Checking results

recordingsNames = fieldnames(recordingsFHR); %Obtaining names of the tested recordings

for iRecordings=1:length(recordingsNames)
    
    windowsRecording = fieldnames(recordingsFHR.(recordingsNames{iRecordings}));
    
    agreeVector = nan(length(windowsRecording),1); %Vector to store the difference between windows
    
    for iWindow=1:length(windowsRecording)
        %Storing if the window agreed
        agreeVector(iWindow)= recordingsFHR.(recordingsNames{iRecordings}).(windowsRecording{iWindow}).diff;
    end
    
    
    %Suming up window differences
    sumDifferences = sum(agreeVector);
    
    % If the differences are zero, output "exact match with gold standar output".
    %If the difference is less than 1bpm per minute of data analyzed, output is "Negligible difference with the gold standard (X BPM)"
    %If it's larger - "Caution - significant difference with gold standard output - please check data or code are correct".
    
    if sumDifferences<=eps
        score = "Exact match with gold standard output";
    elseif sumDifferences<=1
        score = strcat("Negligible difference with the gold standard (",num2str(sumDifferences)," BPM)");
    else
        score = "Caution - significant difference with gold standard output - please check data or code are correct and version of Matlab";
    end
    
    
    
    
    %Printing results for the recording
    fprintf("Name of recording: %s\n", recordingsNames{iRecordings} );
    fprintf("Total difference along all windows: %f bpm\n", sumDifferences);
    fprintf("Score comparison: %s\n", score);
    fprintf("******************************************\n\n");
    
end
