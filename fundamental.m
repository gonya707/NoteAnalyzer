function r = fundamental(x, fs)
% function r = fundamental(x,fs)
%
% Guess the fundamental frequency of the input signal
%
% Input parameters:
%   x -> input signal
%   fs -> sampling frequency
%
% Output parameters: 
%   r -> Fundamental frequency
%   

    umbral = max([max(x) abs(min(x))]) / 2;
    x(abs(x) < umbral) = 0;
    x(x >= umbral) =x (x >= umbral) - umbral;
    x(x <= -umbral) =x (x <= -umbral) + umbral;
    a = find(x);
    x = x(1 : a(end));

    [S] = xcorr(x, 'coef'); %autocorrelate
    S(S < 0.2) = 0;
    
    [~, posiciones] = findpeaks(S);
    
    L = length(posiciones);
    resta = zeros(L, 1);
    
    for i = 2 : L
        resta(i) = posiciones(i) - posiciones(i - 1);
    end

    % bad values deletion
    resta = resta(resta > 40);
    resta = resta(resta < (mean(resta) * 1.5));
    
    r = fs / mean(resta);
end