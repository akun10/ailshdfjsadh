function [Hd,b] = hp100(varargin)
%HP100 返回离散时间滤波器对象。

% MATLAB Code
% Generated by MATLAB(R) 9.11 and Signal Processing Toolbox 8.7.
% Generated on: 28-Apr-2023 15:55:06

% Equiripple Highpass filter designed using the FIRPM function.

% All frequency values are in Hz.
if nargin == 1
    Fs = varargin{1};  % Sampling Frequency
else
    Fs = 1000;
end


Fstop = 100;             % Stopband Frequency
Fpass = 150;             % Passband Frequency
Dstop = 0.0001;          % Stopband Attenuation
Dpass = 0.057501127785;  % Passband Ripple
dens  = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fstop, Fpass]/(Fs/2), [0 1], [Dstop, Dpass]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);

% [EOF]
