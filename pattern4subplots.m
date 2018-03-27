function [NumRows,NumCols,fh] = pattern4subplots(Num,upright,varargin)
% organizes a certain number of subfigures
%
% --- Syntax:
% [NumRows,NumCols] = pattern4subplots(Num)
% [NumRows,NumCols,fh] = pattern4subplots(Num)
% 
% --- Description:
% [NumRows,NumCols] = pattern4subplots(Num) determines how many
%       rows/columns should there be for a certain number of subplots Num.
%       Assuming a wide screen, it is hold NumRows < NumColums
% [NumRows,NumCols,fh] = pattern4subplots(Num) opens a figure with all
%       subplots and returns the figure handle.
% 
% ------------------------------------------------ Max Schwenzer 11.08.2017

% Change log
% 19.01.2018    Max Schwenzer
%               change output structure from fh.sub1, fh.sub2,... to
%               fh.sub{1}, fh.sub{2},...
% 22.01.2018    Max Schwenzer
%               add 'no TickLabel' flag

%% determie pattern for plots
FLAG_DINA4 = false; % default
if any(strcmpi(varargin,'DIN A 4')) || any(strcmpi(varargin,'DINA4')) % flag
    FLAG_DINA4 = true;
end

if FLAG_DINA4
    NumCols = 3;
    NumRows = ceil(Num/NumCols);
elseif nargin > 1 && upright
    NumRows = 3;
    NumCols = ceil(Num/NumRows);
    
    while NumCols+2 > NumRows
        NumRows = NumRows+1;
        NumCols = ceil(Num/NumRows);
    end
else
    NumCols = 2;
    NumRows = ceil(Num/NumCols);

    while NumRows > NumCols
        NumCols = NumCols+1;
        NumRows = ceil(Num/NumCols);
    end
    NumCols = NumCols-1;
    NumRows = ceil(Num/NumCols);
end


FLAG_NO_TICKLABEL = false; % default
if any(strcmpi(varargin,'no TickLabel')) % flag
    FLAG_NO_TICKLABEL = true;
end
    
%% open figure if handle is requested
if nargout > 2
    % open figure & all handles
    fh = struct();
    fh.fig = figure;
    fh.sub = cell(Num,1);
    for i = 1:Num
        fh.sub{i} = subplot(NumRows,NumCols,i);
        
        if FLAG_NO_TICKLABEL
            set(    fh.sub{i},'yTickLabel',{})
            set(    fh.sub{i},'xTickLabel',{})
        end
    end
    
    fh.rows = NumRows;
    fh.cols = NumCols;
end
end