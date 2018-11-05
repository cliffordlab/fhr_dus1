%%
%OVERVIEW
%   This script test if the functions have been properly downloaded and
%   set up

clc;clear; close all;


%% Loading function parameters

FHRparams = loadParameters();


%% Estimating FHR from Ultrasound recordings

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
    %gold standard and local FHR is calcualted
    if  ~isnan(FHR_gold)
        recordingsFHR.(nameRecording).(strcat('w_',num2str(windowIdx))).diff = abs(FHR_gold -FHR_gold); %storing difference
    else
        %If the gold standard was NaN, the window is not used for comparison
        recordingsFHR.(nameRecording).(strcat('w_',num2str(windowIdx))).diff = 0;
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
    
    % If the difference are zero, output "exact match with gold standar output".
    %If the difference is less than 1bpm per minute of data analyzed, output is "Negligible difference with the gold standard (X BPM)"
    %If it's larger - "Caution - significant difference with gold standard output - please check data or code are correct".
    
    if sumDifferences==0
        score = "Exact match with gold standar output";
    elseif sumDifferences<=1
        score = strcat("Negligible difference with the gold standard (",num2str(sumDifferences)," BPM)");
    else
        score = "Caution - significant difference with gold standard output - please check data or code are correct";
    end
       
    
    
    
    %Printing results for the recording
    fprintf("Name recording: %s\n", recordingsNames{iRecordings} );
    fprintf("Total difference along windows: %f bpm\n", sumDifferences);
    fprintf("Score comparison: %s Hz\n", score);
    fprintf("******************************************\n\n");
    
end
