%Flat line at 0 remover
%takes input of [signal, tolerance] and gives output of [output signal].
%signal is the input signal one wishes to remove the flat lines at zero
%from, and the tolerance is an integer on how many zeros in a row must be
%detected to be removed (e.g. tolerance of 3 means a segment of [0 0 0] in
%the signal will be marked for removal, but [0 0] won't be).

function [output] = eeg_lr(sig, tol)
    
    %default tolerance variable to 3.
    if ~exist('tol', 'var')
        tol = 3;
    end
    
    
    %temp array used for computation, dudarray is array of elements to be
    %removed.
    temparray = nan([1, tol]);
    dudarray = zeros([1, (3*length(sig))]);
    
    
    %loop that checks for sequences of zeros in signal
    for k = 1:(length(sig) - tol)
%         temparray = sig(k:(k+tol));
        
        if ~any(sig(k:(k+tol)))
            for j = k:(k+tol)
                dudarray(j) = j;
            end
            k = k + tol;
%             dudarray( = [dudarray,(k:(k+tol))];
        end
        
    end
    
    dudarray(dudarray == 0) = [];
    output = sig;
    output(dudarray) = [];
    
    
end