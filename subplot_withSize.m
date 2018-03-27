function fh = subplot_withSize(NumRow,NumCol,hRow,wCol)
% creates subplots with user-specified row/column sizes
% 
% --- Syntax:
% fh = subplot_withSize(NumRow,NumCol,hRow,wCol)
% 
% --- Description:
% fh = subplot_withSize(NumRow,NumCol,hRow,wCol) takes the total number of
%       rows and colums as input just as the Matlab-nativ subplot command.
%       Additionally, you can specify the heights of the rows (hRow) and
%       the width of the columns (wCol) as a value between 0 and 1. If you
%       like to have differnet sizes for different rows/columns, you can
%       provide an array. If it is shorter than NumRow/NumCol, the last
%       entry will be used for the missing sizes.
% 
% ------------------------------------------------ Max Schwenzer 17.10.2017


% NumRow = 3;
% NumCol = 2;
% wCol = [0.2 0.5];
% hRow = [0.3];

%% process input
% height (hRow)
if length(hRow) > NumRow
    warning('subplot_withSize:INPUT:hRow','The length if hRow exceeds the specified numer of rows.')
elseif isempty(hRow) || any(hRow < 0)
    error('subplot_withSize:INPUT:hRow','The input hRow must be a positive number.')
end

hTotal = sum(hRow) + hRow(end)*(NumRow-length(hRow));
if hTotal > 1
    error('subplot_withSize:INPUT:hRow','The total height exceeds 1. Make sure that sum(hRow) < 1.')
end


% width (wCol)
if length(wCol) > NumCol
    warning('subplot_withSize:INPUT:wCol','The length if wCol exceeds the specified numer of colums.')
elseif isempty(wCol) || any(wCol < 0)
    error('subplot_withSize:INPUT:wCol','The input wCol must be a positive number.')
end

wTotal = sum(wCol) + wCol(end)*(NumCol-length(wCol));
if wTotal > 1
    error('subplot_withSize:INPUT:wCol','The total width exceeds 1. Make sure that sum(wCol) < 1.')
end

%% main

fh.fig = figure;
fh.sub = cell(NumRow*NumCol,1);
k = 1;

% vertical gap:
vGap = min([hTotal/(NumRow+1), 0.1]);
% horizontal gap:
hGap = min([wTotal/(NumCol+1), 0.1]);

% xPos = vGap;
yPos = 1-hRow(1)-vGap/2;
for r = 1:NumRow%max( [length(hRow),NumRow] )
    % get hight for the current row
    if r > length(hRow)
        hRow_tmp = hRow(end);
    else
        hRow_tmp = hRow(r);
    end
    
    xPos = vGap;
    for c = 1:NumCol%max( [length(wCol),NumCol] )
        % get width of the current column
        if c > length(wCol)
            wCol_tmp = wCol(end);
        else
            wCol_tmp = wCol(c);
        end
        
        % create subplot
        fh.sub{k} = subplot('Position',[xPos yPos wCol_tmp hRow_tmp]);
        k = k +1;
        % update position
        xPos = xPos + (wCol_tmp + hGap);
    end
    yPos = yPos - (hRow_tmp + vGap);
end

end