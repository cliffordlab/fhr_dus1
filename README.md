# fhr_dus1
Fetal Heart Rate (FHR) Estimation from 3.3 MHz 1D Doppler Transducer written in Matlab,

Written by David Springer, Lisa Stroux and Camilo E. Valderrama 
under the supervision of Gari Clifford

Please reference:

Camilo E. Valderrama, Lisa Stroux, Nasim Katebi, Elianna Paljug, Faezeh Marzbanrad, Gari D. Clifford. An open source autocorrelation-based method for fetal heart rate estimation from one-dimensional Doppler ultrasound, Physiological Measurement, 2019 (In Press)


To test if the files give the expected result please, first run the script:

 demo_fhr_us.m 

You should see:

Name of recording: test1
Total difference along all windows: 0.000000 bpm
Score comparison: Exact match with gold standard output
******************************************

Name of recording: test2
Total difference along all windows: 0.000000 bpm
Score comparison: Exact match with gold standard output
******************************************

There may be a small difference, but no more than a fraction of one BPM.


To estimate FHR from test signals located in ../Recording folder. run script:

 estimatingFHR.m 

The FHR estimation function is called: 
 getFRH.m

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------


Toolboxes required (using "license('inuse')"):
 econometrics_toolbox
 signal_blocks
 signal_toolbox

Tested with:
------------------------------------------------------------------------------------------
MATLAB Version: 9.3.0.867777 (R2017b) Update 7
Operating System: Mac OS X  Version: 10.14 Build: 18A391 
Java Version: Java 1.8.0_144-b01 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
------------------------------------------------------------------------------------------
MATLAB                                                Version 9.3         (R2017b)
Simulink                                              Version 9.0         (R2017b)
Audio System Toolbox                                  Version 1.3         (R2017b)
Bioinformatics Toolbox                                Version 4.9         (R2017b)
Communications System Toolbox                         Version 6.5         (R2017b)
Computer Vision System Toolbox                        Version 8.0         (R2017b)
Control System Toolbox                                Version 10.3        (R2017b)
Curve Fitting Toolbox                                 Version 3.5.6       (R2017b)
DSP System Toolbox                                    Version 9.5         (R2017b)
Database Toolbox                                      Version 8.0         (R2017b)
Datafeed Toolbox                                      Version 5.6         (R2017b)
Econometrics Toolbox                                  Version 4.1         (R2017b)
Embedded Coder                                        Version 6.13        (R2017b)
Financial Instruments Toolbox                         Version 2.6         (R2017b)
Financial Toolbox                                     Version 5.10        (R2017b)
Fixed-Point Designer                                  Version 6.0         (R2017b)
Fuzzy Logic Toolbox                                   Version 2.3         (R2017b)
Global Optimization Toolbox                           Version 3.4.3       (R2017b)
HDL Coder                                             Version 3.11        (R2017b)
Image Acquisition Toolbox                             Version 5.3         (R2017b)
Image Processing Toolbox                              Version 10.1        (R2017b)
Instrument Control Toolbox                            Version 3.12        (R2017b)
LTE System Toolbox                                    Version 2.5         (R2017b)
MATLAB Coder                                          Version 3.4         (R2017b)
MATLAB Compiler                                       Version 6.5         (R2017b)
MATLAB Compiler SDK                                   Version 6.4         (R2017b)
Mapping Toolbox                                       Version 4.5.1       (R2017b)
Neural Network Toolbox                                Version 11.0        (R2017b)
Optimization Toolbox                                  Version 8.0         (R2017b)
Parallel Computing Toolbox                            Version 6.11        (R2017b)
Partial Differential Equation Toolbox                 Version 2.5         (R2017b)
Phased Array System Toolbox                           Version 3.5         (R2017b)
Risk Management Toolbox                               Version 1.2         (R2017b)
Robotics System Toolbox                               Version 1.5         (R2017b)
Signal Processing Toolbox                             Version 7.5         (R2017b)
SimBiology                                            Version 5.7         (R2017b)
Simscape                                              Version 4.3         (R2017b)
Simscape Multibody                                    Version 5.1         (R2017b)
Simulink Coder                                        Version 8.13        (R2017b)
Simulink Control Design                               Version 5.0         (R2017b)
Stateflow                                             Version 9.0         (R2017b)
Statistics and Machine Learning Toolbox               Version 11.2        (R2017b)
Symbolic Math Toolbox                                 Version 8.0         (R2017b)
System Identification Toolbox                         Version 9.7         (R2017b)
Tracking and Sensor Fusion Toolbox                    Version 1.0         (R2017b)
Trading Toolbox                                       Version 3.3         (R2017b)
Wavelet Toolbox                                       Version 4.19        (R2017b)