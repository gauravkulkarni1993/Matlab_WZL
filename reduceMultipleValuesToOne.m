function ValSync = reduceMultipleValuesToOne(Vec,idxSyncVec,Method)
% reduces a vector
%
% --- Syntax:
% ValSync = reduceMultipleValuesToOne(Vec,idxSyncVec)
% ValSync = reduceMultipleValuesToOne(Vec,idxSyncVec,Method)
% 
% --- Description:
% ValSync = reduceMultipleValuesToOne(Vec,idxSyncVec) uses the vector Vec
%       to calculate a vector of the size idxSyncVec, calculating the
%       values by averaging the supernumerous values between the indices of
%       idxSyncVec.
% ValSync = reduceMultipleValuesToOne(Vec,idxSyncVec,Method) you can
%       provide a method, how the reduced value should be calculated.
%       methods: mean, median, max, min. You can also provide a function
%       handle, such as @sum or a custom function.
%
% ------------------------------------------------ Max Schwenzer 30.03.2017

if nargin < 3
    Method = @mean;
end

%% create function:
if isa(Method,'function_handle')
    fnc = Method;
else
    switch Method
        case 'mean'
            fnc = @mean;
        case 'median'
            fnc = @median;
        case 'max'
            fnc = @max;
        case 'min'
            fnc = @min;
        otherwise
            warning('syncVec:reduceMultipleValueToOne:Method',...
                'No proper reduction method defined. The default method is used: mean.');
            fnc = @mean;
    end
end

%% reduce data
% allocate memory:
ValSync = zeros(length(idxSyncVec),1);
% determine range:
delta = median(diff(idxSyncVec));
delta = ceil(delta/2); %FIXME:

% 1st value
if idxSyncVec(1) - delta < 1
    ValSync(1) = fnc( Vec(1:idxSyncVec(1)+delta) );
else
    ValSync(1) = fnc( Vec(idxSyncVec(1)-delta:idxSyncVec(1)+delta) );
end
% middle values
for i = 2:length(idxSyncVec)-1
    ValSync(i) = fnc( Vec(idxSyncVec(i)-delta:idxSyncVec(i)+delta) );
end % TODO: make efficient by vectorwise processing?
% last value
if idxSyncVec(end) + delta >= length(Vec)
    ValSync(end) = fnc( Vec(idxSyncVec(end)-delta:length(Vec)) );
else
    ValSync(end) = fnc( Vec(idxSyncVec(end)-delta:idxSyncVec(end)+delta) );
end



end