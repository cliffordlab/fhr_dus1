function [heartRate] = getFHR(audio_data, Fs, minPeriod, maxPeriod, Hd, cutFreq,ratioFirstPeak)

%   OVERVIEW:
%       Derive the fetal heart rate from a 1D-Doppler ultrasound.
%
%   %INPUTS:
%       audio_data: It is a 3.75 s of the raw audio data from the 1D-DUS recording
%       Fs: the sampling frequency of the audio recording
%       minPeriod: lower interval to start searching peaks in the AC function
%       maxPeriod: upper interval to start searching peaks in the AC function
%       Hd: Band-Pass filter used to extract frequency range of cardiac activity
%       cutFreq: low-pass filter used to extract the homomorphic envelope
%       ratioFirstPeak: Ratio used to compare peak amplitude within window search

%
%    OUTPUTS:
%       FHR: Fetal heart rate from the input 3.75 s Doppler ultrasound
%       segment
%
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% 25-600Hz 4th order Butterworth band pass
%25 to 600 was found to contain cardiac frequency for a
%transducer with 3.3 Mhz used in our work.

audio_data = filtfilt(Hd.Numerator,1,audio_data);

%% Spike removal from the original paper:
audio_data = schmidt_spike_removal(audio_data,Fs);

%% Find the homomorphic envelope
homomorphic_envelope = Homomorphic_Envelope_with_Hilbert(audio_data, Fs,cutFreq);

%% Find the autocorrelation:


%Finding autocorrelation for the homomorphic envelope
signal_autocorrelation = autocorr(homomorphic_envelope,length(homomorphic_envelope)-1, [] , 2);




%% Set the max and min search indices
% This sets the search for the highest peak in the autocorrelation to be
% between minPeriod and maxPeriod parameters

min_index = round(minPeriod*Fs); % turning minPeriod into samples
max_index = round(maxPeriod*Fs); % turning maxPeriod into samples

%Finding peaks in the search window defined by minPeriod and maxPeriod
%parametners.
[peaks, locs] = findpeaks(signal_autocorrelation(min_index:max_index),'MinPeakDistance',(1/3)*Fs);

%% Selecting the peak correspoding the period

%Validating there are peaks withing the window search
if ~isempty(locs)
    if length(peaks)>1
        
        
        
        %calculating ratio location on time between peaks
        perX = (min_index+locs(1)-1)/(min_index+locs(2)-1);
        
        if perX>=0.48 && perX<=.52
            %it is likely be an harmonic; therefore, the first peak is
            %taken
            index = locs(1);
        else
            %Otherwise, check the amplitude peak ratio between the 2 peaks
            
            %amplitude ratio between first and second peak
            perDif = peaks(1)/peaks(2);
            
            
            if perDif<0  % If ratio is lower than 0 is because one
                % of the peak amplitudes is negative.
                
                %Take the peak location whose amplitude is the biggest (the positive one).
                [~, idxMaxPk] = max(peaks);
                index = locs(idxMaxPk);
                
            else % If the amplitude of the peaks are postive
                % (or negative, which usually does not happened as Matlab
                %  findPeaks function takes the biggest peaks of the auto
                %  function, which at least has a positive amplitude peak for
                %  periodic signlas, such as Doppler ultrasound signals. )
                
                if perDif >= ratioFirstPeak % If the ratio is bigger than the
                    % threshold take the location of the first
                    % peak.
                    index = locs(1);
                else
                    index = locs(2);        % Otherwise, second peak location is taken.
                end
            end
        end
    else
        index = locs(1);                    % In case there is only one peak
        % in the window search,
        % the location of that peak is
        % taken.
    end
    
    
    true_index = index+min_index-1;         %Adding starting of the window search
    
    %Estimating automatic FRH as the reciprocal of the DUS periodicity
    %true_index variable is the period of the DUS singals in samples, it is
    %converted to seconds by dividing it with the sampling frequency.
    %60 divided intro the period gives the frequency of the DUS signal in Hz
    heartRate = 60/(true_index/Fs);
    
else
    
    %In case there is not peaks withing the window search, heartRate is set
    %to NaN. It usually occurs when signal has a poor quality.
    heartRate = nan;
end
