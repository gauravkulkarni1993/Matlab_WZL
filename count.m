function [counts, uq] = count(IN)
% This function counts the values in the input
%
% --- Syntax:
% counts = count(IN)
% 
% --- Description:
% counts = count(IN) counts the numer of unique values in the input vector
%           or matrix (matrix row-wise).
%
% ------------------------------------------------ Max Schwenzer 15.03.2017


% allocate memory:
uq = unique(IN);
counts = zeros(size(uq));
for i = 1:size(IN,2)
    counts(:,i) = arrayfun( @(x)sum(IN(:,i)==x), unique(IN(:,i)) );
end


end