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




%% 1. Path of recordings wav files

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
