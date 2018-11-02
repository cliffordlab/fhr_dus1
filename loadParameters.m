function FHRparams = loadParameters()
%
%   
%
%   OVERVIEW:   
%       This file stores settings and should be configured before
%       using the fetal heart estimation function
%
%   INPUT:      
%       None
%
%   OUTPUT:
%       FHR parameters 
%
%	REPO:       
%       https://github.com/gariclifford/fhr_dus1



%% 1. Path of recording

FHRparams.pathRecording = 'Recordings/';          %Path of the folder containing the One doppler ultrasound segments


%% 2. Bayesian optimization parameters results

FHRparams.minPeriod = 0.287308661149887;         % Lower interval to start searching peaks in the AC function (s)
FHRparams.maxPeriod = 0.839140444683137;         % Upper interval to start searching peaks in the AC function (s)
FHRparams.cutFreq =   14.794675954494590;        % Low-pass filter used to extract the homomorphic envelope (Hz)
FHRparams.ratioFirstPeak = 0.650124394601487;    % Ratio used to compare peak amplitude within window search

%%  3. Filter design for keeping cardiac activity in a 3.3 MHz transducer

%25 to 600 was found to contain cardiac frequency for a transducer with 3.3 Mhz used in our work.

FHRparams.Fs = 4000;                              % Sampling used for ultrasound recordings (Hz)
A_stop1 = 60;		                              % Attenuation in the first stopband (dB)
F_stop1 = 10;		                              % Edge of the stopband (kHz)
F_pass1 = 25;                                     % Edge of the passband 
F_pass2 = 600;                                    % Closing edge of the passband 
F_stop2 = 615;                                    % Edge of the second stopband 
A_stop2 = 60;		                              % Attenuation in the second stopband = 60 dB
A_pass = 1;                                       % Amount of ripple allowed in the passband = 1 dB

% Specifications are passed to the fdesign.bandpass method as parameters.
h = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', ...
		F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, ...
		A_stop2, FHRparams.Fs);
      
FHRparams.Hd = design(h,'equiripple');                 %Bandpass filter for keeping cardiac activity in a 3.3 MHz transducer 

end