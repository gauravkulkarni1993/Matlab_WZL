function Out = moving(func,Signal,windowSize,assignWindowSize)
% applies a function in a moving window
% 
% --- Syntax:
% Out = moving(func,Signal)
% Out = moving(func,Signal,windowSize)
% Out = moving(func,Signal,windowSize,assignWindowSize)
%
% --- Description:
% Out = moving(func,Signal)     evaluates the function 'func' - provided as
%       a function handle - on a moving section of the input signal 
%       'Signal'. The size of this window is per default
%       1/1e5*length(Signal).
% Out = moving(func,Signal,windowSize)  specifies the size of the moving
%       window.
% Out = moving(func,Signal,windowSize,assignWindowSize) specifies to how
%       many signal points the new function value should be assigned. Per
%       default this is 1, so that a new value is calculated for every
%       signal point. This is the major tuning parameter for speed.
% 
% ------------------------------------------------ Max Schwenzer 26.10.2016

%% check input:
if ~isa(func,'function_handle')
    error('moving:func:NotAFunctionHandle',...
        'The input ''func'' is not a function handle!');
end

if nargin < 3
    windowSize = ceil(length(Signal)/1e5);
end
if nargin < 4
    rSz = 1;
else
    assert(windowSize >= assignWindowSize);
    rSz = assignWindowSize;
end

assert(length(Signal) > rSz);
assert(length(Signal) > windowSize/2);
%% main function:

wSz2 = floor(windowSize/2);
rSz2 = floor(rSz/2);
Out = zeros( size(Signal) );

for i = 1:rSz:length(Signal)
    % i <= rSz2          ->  Out(i:end)         = func( Signal(1:i+wSz2) );
    % i <= wSz2          ->  Out(i-rSz2:i+rSz2) = func( Signal(1:i+wSz2) );
    % i >= length - rSz2 ->  Out(i-rSz2:end)    = func( Signal(i-wSz2:end) );
    % i >= length - wSz2 ->  Out(i-rSz2:i+rSz2) = func( Signal(i-wSz2:end) );
    % else               ->  Out(i-rSz2:i+rSz2) = func( Signal(i-wSz2:i+wSz2) );
    if i <= rSz2
        Out(i:i+rSz2)      = func( Signal(1:i+wSz2) );
    elseif i <= wSz2
        Out(i-rSz2:i+rSz2) = func( Signal(1:i+wSz2) );
    elseif i >= length(Signal) - rSz2
        Out(i-rSz2:end)    = func( Signal(i-wSz2:end) );
    elseif i >= length(Signal) - wSz2
        Out(i-rSz2:i+rSz2) = func( Signal(i-wSz2:end) );
    else
        Out(i-rSz2:i+rSz2) = func( Signal(i-wSz2:i+wSz2) );
    end
end
% for i = 1:rSz:length(Signal)
%     
%     if i > wSz2 && i < length(Signal) -wSz2
%         if i >= length(Signal) -rSz
%             Out(i:end) = func( Signal(i -wSz2:end) );
%         else
%             Out(i:i +rSz) = func( Signal(i -wSz2:i +wSz2) );
%         end
%     elseif i <= wSz2
%         Out(i:i +rSz) = func( Signal(1:i +wSz2) );
%     else % i >= length(Signal) -wSz/2
%         if i >= length(Signal) -rSz
%             Out(i:end) = func( Signal(i -wSz2:end) );
%         else
%             Out(i:i +rSz) = func( Signal(i -wSz2:end) );
%         end
%     end
% end
end