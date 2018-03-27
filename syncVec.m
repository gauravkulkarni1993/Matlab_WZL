function [idxSync, ValSync] = syncVec(T1,T2,epsilon,Method,T1_smth,dbg)
% synchronizes 2 vectors by the distance to each other
% 
% --- Syntax:
%  idxSync = syncVec(T1,T2)
%  idxSync = syncVec(T1,T2,epsilon)
%  idxSync = syncVec(T1,T2,epsilon,Method)
%  idxSync = syncVec(T1,T2,epsilon,Method,T1_smth)
%  [idxSync, ValSync] = syncVec(T1,T2,epsilon,Method,T1_smth)
%
% --- Description:
%  idxSync = syncVec(T1,T2) determines the points of T1 which have an 
%       (euclidean) distance to a point in T2 smaller than a default
%       threshold. (Threshold calculated randomly.) Returns the indices of
%       T1, which are the same as in T2.
%  idxSync = syncVec(T1,T2,epsilon) the threshold that determines if a
%       point of T1 is indeed the same as in T2. Threshold is also the
%       euclidean distance.
% [idxSync, ValSync] = syncVec(T1,T2,...) if you would like to have the
%       synchronized values returned, use the second output argument. Per
%       default, the exact value is returned.
% [idxSync, ValSync] = syncVec(T1,T2,epsilon,Method) You can provide a
%       method (min, max, mean, median) or a function handle how the
%       synchronized values should be calculated. (How the values of T1
%       should be reduced to one value) Per default, the exact value is
%       returned.
% [idxSync, ValSync] = syncVec(T1,T2,epsilon,Method,T1_smth) if the 5th
%       argument is provided, the Method to calculate the return value is
%       applied on this input. The input must be the same length as T1.
%
% --- Note:
% required additional (custom) functions: count(),
% reduceMultipleValuesToOne()
% required MATLAB Toolbox: Statistics and Machine Learning Toolbox
% 
% ------------------------------------------------ Max Schwenzer 30.03.2017

% change log:
% 2017-08-07 added dbg input



% FIXME: add output idxSyncT2 which guarantees that both synchronized
% vectors are the same length!


if nargin < 3
    % choos 10% of the points of the shorter vector randomly:
    idx = randperm(length(T2),ceil(0.1*length(T2)));
    % determine their nearest distance to other points:
    [~, d_min] = knnsearch(T1(idx),T2,'k',1);
    % take the median of the minimal distance as the threshold:
    epsilon = min(d_min) + 0.2*median(d_min);
end


% find nearest point:
[idx_min, d_min] = knnsearch(T1,T2,'k',1);

%% only consider points, which are nearer than the defined threshold
% distance smaller than threshold?
lg = d_min < epsilon;
% update values
d_min = d_min(lg);
idx_min = idx_min(lg);

%% make sure that the nearest points are unique:
uq_idx_min = unique(idx_min);
if length(uq_idx_min) < length(idx_min)
    % allocate memory: 
    idxSync = zeros(size(uq_idx_min));
    % count unique values
    counts = count(idx_min);
    
    % find minimum of not unique values:
    idx_counts = find(counts > 1);
    for i = 1:length(idx_counts)
        lg = idx_min == idx_counts(i);
        [~,idx_tmp] = min(d_min(lg));
        
        tmp = idx_min(lg);
        idxSync = tmp(idx_tmp);
    end
    % add unique values:
    idxSync(i:end) = idx_min(counts == 1);
    % sort:
    idxSync = sort(idxSync,'ascend');
else
    idxSync = idx_min;
end

disp(['idxSync (difference): mean  = ',num2str(mean(diff(idxSync))),', std = ',num2str(std(diff(idxSync)))])
%% output
if nargout == 2
    % exact value?
    if nargin > 4
        assert(length(T1) == length(T1_smth))
        ValSync = reduceMultipleValuesToOne(T1_smth,idxSync,Method);
    elseif nargin > 3
        ValSync = reduceMultipleValuesToOne(T1,idxSync,Method);
    else
        % extract exact value:
        ValSync = T1(idxSync);
    end
end



%% debugging
if nargin > 5 && dbg
    figure
    subplot(2,1,1)
    plot(T1,ones(size(T1)),'.-')
    hold on
    plot(T2,ones(size(T2)),'o')
    hold off
    xlabel('Points of input vector');
    legend({'T1','T2'})

    subplot(2,1,2)
    plot(d_min)
    hold on
    plot([1;length(T2)],[epsilon;epsilon])
    hold off
    ylabel('min Difference')
end
end






