function [num,str] = findNumInStr(str,StartWord,EndWord)
% TODO: description.

% output = 
% [] if no start/end string could be found
% double if work
% string if conversion did not work
% NaN if conversion did not work???

% ------------------------------------------------ Max Schwenzer 14.10.2016

%%
    % find start point:
    idxStart = strfind(str,StartWord);
    % find end point:
    if ~isempty(idxStart)
        idxStart = idxStart +length(StartWord);
        idxEnd   = regexp(str(idxStart:end),EndWord, 'ONCE');
        if isempty(idxEnd)
            idxEnd = length(str);
        else
            if idxEnd < 2
                idxEnd = [];
            else
                idxEnd = idxEnd  +idxStart -2;
            end
        end
    else
        idxEnd = [];
    end
    
    % output:
    if ~isempty(idxEnd)
        num      = str2double( str(idxStart:idxEnd) );
    else
        num = [];
    end
    
    if nargout > 1
       str = str(idxStart:idxEnd); % return string
    end
end