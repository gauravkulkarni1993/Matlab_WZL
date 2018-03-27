function [M, MinMax] = ScaleMatrix(Mat,varargin)
% This function scales a matrix onto a specified interval.
%
% --- Syntax:
% M = ScaleMatrix(Mat)
% [M, MinMax] = ScaleMatrix(Mat)
% M = ScaleMatrix(Mat,'Interval',Interval)
% M = ScaleMatrix(Mat,'dim','row')
% M = ScaleMatrix(Mat,'MinMax',MinMax)
% M = ScaleMatrix(Mat,'ExcludeOutliers',true)
% M = ScaleMatrix(Mat,'NoOffset',true)
% M = ScaleMatrix(Mat,'ReScale',true)
%
% --- Description:
% M = ScaleMatrix(Mat)  scales each column of the matrix 'Mat' onto the
% interval [0 1].
% [M, MinMax] = ScaleMatrix(Mat) returns the minimum and maximum value of
% the input matrix, which are scaled to new values.
% M = ScaleMatrix(Mat,'Interval',Interval)  scales each column of the 
% matrix 'Mat' onto the interval specified in the 2-element array Interval.
% M = ScaleMatrix(Mat,'dim','row')  scales each row of the matrix Mat.
% M = ScaleMatrix(Mat,'MinMax',MinMax) provides the minimum and maximum
% values, which are scaled the the new interval.
% M = ScaleMatrix(Mat,'ExcludeOutliers',true) the function ignores all
% values, which are greater mean +/- 3*std to determine the scaling range.
% Therfore, the output MinMax may not match the provided target interval
% (input) 'MinMax'
% M = ScaleMatrix(Mat,'NoOffset',true) scales the input symmetrically.
% MinMax = [-MAX MAX]?????
% M = ScaleMatrix(Mat,'ReScale',true) this flag exchanges the exchanges the
% target interval (MinMax) and the current interval (Intvl). The parameter
% is just for convenience.
%
% ------------------------------------------------ Max Schwenzer 07.07.2016

% CHANGE LOG
% 28.07.2016 scw: add optional parameter 'MinMax'
% 30.07.2016 scw: add optional parameters 'ExcludeOutliers', 'NoOffset'
% 04.08.2017 scw: add optional parameter 'ReScale'

%% -------------------------- input processing -------------------------- %
IN = inputParser;
addParameter(IN,'Interval',[0 1],...
    @(x)validateattributes(x,{'numeric'},{}));
addParameter(IN,'dim','col',...
    @(x)validateattributes(x,{'char'},{}));
addParameter(IN,'MinMax',[],...
    @(x)validateattributes(x,{'numeric'},{}));
addParameter(IN,'ExcludeOutliers',false,@islogical);
addParameter(IN,'NoOffset',false,@islogical);
addParameter(IN,'ReScale',false,@islogical);


parse(IN,varargin{:}) % parse input
% validate string input:
validatestring(IN.Results.dim,{'col','row','column'});

if ~isempty(IN.Results.MinMax)
    for i = 1:size(IN.Results.MinMax,1)
        if IN.Results.MinMax(i,1) >= IN.Results.MinMax(i,2)
            error('The value of ''MinMax'' is invalid. Expected input to be increasing valued.')
        end
    end
%     MinMaxGiven = IN.Results.MinMax;
end


% ReScale exchanges the target interval (MinMax) and the current interval
% (Intvl) 
if IN.Results.ReScale
    Intvl = IN.Results.MinMax;
    MinMaxGiven = IN.Results.Interval;
else
    Intvl = IN.Results.Interval;
    MinMaxGiven = IN.Results.MinMax;
end






%% ------------------------- main functionality ------------------------- %
if size(Mat,1) == 1
    Mat = Mat';
end
M = Mat;

if strcmp(IN.Results.dim,'row')
    % scale every row
    % determine new inverval:
    if isempty(MinMaxGiven)
        idx = true(1,size(Mat,2));
        % exclude statistical outliers:
        if IN.Results.ExcludeOutliers
            TH = median(Mat,2) + 3*std(Mat,[],2);
            idx = abs(Mat) > repmat(TH,size(Mat,1),1);
            if ~any(idx)
               idx = true(size(Mat,2),1);
            end
        end

        
        MinMax = zeros(size(Mat,1),2);
        MinMax(:,1) = min(Mat(:,idx),[],2);
        MinMax(:,2) = max(Mat(:,idx),[],2);
    elseif size(MinMaxGiven,1) > 1
        % use given interval
        MinMax = MinMaxGiven;
    elseif size(MinMaxGiven,1) == 1
        % expand given interval
        MinMax = repmat(MinMaxGiven,size(Mat,1),1);
    end
    
    if IN.Results.NoOffset
        MAX = max(abs(MinMax),[],2);
        MinMax = [-MAX MAX];
    end
    
    % scale:
    for i = 1:size(Mat,1)
        Scl = (Intvl(2)-Intvl(1))/(MinMax(i,2)-MinMax(i,1));
        M(i,:) = (Mat(i,:) -MinMax(i,1))*Scl +Intvl(1);
    end
else % colum!
    % scale every colum
    % determine new inverval:
    if isempty(MinMaxGiven)
        idx = true(size(Mat,1),1);
        % exclude statistical outliers:
        if IN.Results.ExcludeOutliers
            TH = median(Mat,1) + 3*std(Mat,[],1);
            idx = abs(Mat) > repmat(TH,1,size(Mat,2));
            if ~any(idx)
               idx = true(size(Mat,1),1);
            end
        end
        
        
        MinMax = zeros(size(Mat,2),2);
        MinMax(:,1) = min(Mat(idx,:));
        MinMax(:,2) = max(Mat(idx,:));
    elseif size(MinMaxGiven,1) > 1
        % use given interval
        MinMax = MinMaxGiven;
    elseif size(MinMaxGiven,1) == 1
        % expand given interval:
        MinMax = repmat(MinMaxGiven,size(Mat,2),1);
    end

    if IN.Results.NoOffset
        MAX = max(abs(MinMax),[],2);
        MinMax = [-MAX MAX];
    end
    
    % scale:
    for i = 1:size(Mat,2)
        Scl = (Intvl(2)-Intvl(1))/(MinMax(i,2)-MinMax(i,1));
        M(:,i) = (Mat(:,i) -MinMax(i,1))*Scl +Intvl(1);
    end
end
end