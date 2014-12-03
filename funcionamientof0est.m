% Tested using Octave 3.0.0, Aug 2008

clear all;

f0 = 440;    % true fundamental frequency
n = 1:200;   % time in samples
fs = 10000;  % sampling rate

N = length(n);
fund = sin(2*pi*f0*n/fs); % sine at fundamental frequency
npartials = 7; 
sig = zeros(1,N);
for k=1:npartials
  ampk = 1 / k^2; % give a natural roll-off
  sig = sig + ampk * sin(2*pi*k*f0*n/fs);
end
%rmsnoise = 0.01;
rmsnoise = 0.0;
sig = sig + rmsnoise * randn(1,N); % add some noise for realism

framesize = N;
minlevel = -60; % Lowest relative partial amplitude to accept 
                % (-40 good with Hamming window family)
                % (-60 good with Blackman window family)
debug = 0;
f0 = f0est(sig,fs,framesize,npartials,minlevel,debug)
% Trick to leave all internal f0est variables defined 
% (comment-out first line of f0est.m declaring the function):
% nargin = 6; f0est;

% Notch out fundamental and repeat:
b1 = -2*cos(2*pi*f0/fs);
sig = filter([1 b1 1],1,sig);
f0 = f0est(sig,fs,framesize,npartials,minlevel,debug)

% Example output:
% f0 =  439.99
% f0 =  437.50