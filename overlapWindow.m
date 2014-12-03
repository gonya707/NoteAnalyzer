function r = overlapWindow(x, w, overlap)
% function r = overlapWindow(x, w, overlap)
%
% cuts the signal to several overlapped windows
%
% Input parameters:
%   x -> input signal
%   w -> single window width
%   overlap -> overlap amount. Must be a number between 0 and 1
%
% Output parameters: 
%   r -> w*number of windows matrix
%   

    largo = length(x);
    n = floor( 1 /overlap * floor(largo / w)) - 2;

    r = zeros(w, n);

    for i = 1 : n - 1
        r(:, i) = x(round((1 + (i - 1) * w * overlap)) : round((1 + (i - 1) * w * overlap) + w - 1));
    end
end