function NC = parseISOGCode(ISOG,Commands)
% parses ISO-G-Code
%
% --- Syntax:
% NC = parseISOGCode(ISOG)
% NC = parseISOGCode(ISOG,Commands)
%
% --- Description:
% NC = parseISOGCode(ISOG)      loops through the ISO-G-Code prvided as a
%       cell and looks for the commands G94, G95, F#. Output is a table
%       witht the row number ('RowNum'), the position of the first
%       character of the found command in this row ('RowIdx'), the
%       corresponding command ('Command') and the complete row content
%       ('RowContent').
% NC = parseISOGCode(ISOG,Commands) the commands must be specifies as a
%       cell of chars. Optionally a '#' can be placed after the command to
%       indicate that a number is required after the command. A '?' can be
%       written to indicate that the command is only provided partially and
%       therefore no whitespace is expected afterwards.
%
% ------------------------------------------------ Max Schwenzer 15.11.2016
%
% FIXME: cannot find 'MCALL L' <= space!

% parseISOGCode(raw(:,8),{'G94','G95','TS_ON?','TS_OFF','F#'});

% parse ISO-G-Code
% ;         comment
% F         feed rate
% G94       v_f in absolut (mm/min)
% G95       v_f in relative (mm/rev)
if nargin < 2
    Commands = {'G94','G95','F#'};
end

%% process input commands:
cmd     = cell(size(Commands));
cmdNum  = false(size(Commands)); % expects number after command
cmdDlm  = true(size(Commands));  % expects delimiter after command

for i = 1:length(Commands)
    % #
    idxEnd = regexp(Commands{i},'#','ONCE');
    
    if isempty(idxEnd)
        cmd(i) = Commands(i);
    else
        % after the command is a number expected
        idx = true(length(Commands{i}),1);
        idx(idxEnd) = false;
        
        cmd{i} = Commands{i}(idx);
        cmdNum(i) = true;
    end
    
    % ?
    idxEnd = regexp(cmd{i},'?','ONCE');
    
    if ~isempty(idxEnd)
        % after the command no delimiter is expected
        idx = true(length(cmd{i}),1);
        idx(idxEnd) = false;
        
        cmd{i} = cmd{i}(idx);
        cmdDlm(i) = false;
    end
end

%%
comment = ';';
delimiter = ' ';
message = 'MSG("';

% number of rows for preallocation:
len = round( length(ISOG) *0.5 ); %

NC = table(zeros(len,1),zeros(len,1),cell(len,1),cell(len,1),...
    'VariableNames',{'RowNum','RowIdx','Command','RowContent'});


k = 1; % control variable
for r = 1:length(ISOG) % loop through each row: r
    row = ISOG{r,1}; % type char!
    
    % look for comment character:
    idxCmt = strfind(row,comment);
    % chrop:
    if ~isempty(idxCmt)
        if idxCmt == 1 % if row is only comment
            continue
        else % chrop row
            row = row(1:idxCmt-1);
        end
    end
    
    % look for messages:
    idxMrk1 = strfind(row,message);
    % chrop:
    if ~isempty(idxMrk1)
        % chrop row
        idxMrk2 = regexp(row(idxMrk1+length(message):end),'"','ONCE');
        if idxMrk1 > 1
            if isempty(idxMrk2)
                warning('Message command ''MSG("")'' was not found completly!')
                row = row(1:idxMrk1-1);
            else
                row = row([1:idxMrk1-1,idxMrk2:end]);
            end
        else
            if isempty(idxMrk2)
                warning('Message command ''MSG("")'' was not found completly!')
                continue
            else
                row = row(idxMrk2:end);
            end
        end
    end
    
    %% loop through each command:
    % look for specified charaters:
    for i = 1:length(cmd) % loop through each command: i
        isCmd = false;
        % find command candidates:
        cnd = strfind(row,cmd{i});
        %% loop through each candicate:
        for c = 1:length(cnd)
            idxStart = cnd(c); % command was found
            idxEnd = idxStart+ length(cmd{i})-1;
            
            % #
            % number is expected after this command
            if cmdNum(i) 
                % check if the command is followed by a number:
                if idxEnd == length(row)
                    continue
                elseif ~isnan( str2double(row(idxEnd+1)) ) || ((idxEnd+1 < length(row)) && ~isnan( str2double(row(idxEnd+1:idxEnd+2)) ))

                    % find the complete numer after the command:
                    idxEnd_new = regexp(row(idxEnd:end), delimiter, 'ONCE');
                    if isempty(idxEnd_new)
                        idxEnd = length(row);
                    else
                        idxEnd = idxEnd + idxEnd_new(1)-2;
                    end
                end
            end
            
            % check if it stands alone: whitespace (before & after)
            if (idxStart == 1 || strcmp( row(idxStart-1), delimiter )) &&...
                    (~cmdDlm(i) || idxEnd == length(row) || strcmp( row(idxEnd+1), delimiter ))
                isCmd = true;
            end
            
            
            
            % store information:
            if isCmd
                NC.RowNum(k) = r;
                NC.RowIdx(k) = idxStart(1);
                NC.Command{k} = row(idxStart:idxEnd);
                NC.RowContent{k} = ISOG{r,1};
                k = k+1;
                
                %% extend preallocation:
                if ~mod(k,len)
                    % TODO: allocate new memory
                    NC = table([NC.RowNum; zeros(len,1)],[NC.RowIdx; zeros(len,1)],...
                        [NC.Command; cell(len,1)],[NC.RowContent; cell(len,1)],...
                        'VariableNames',{'RowNum','RowIdx','Command','RowContent'});
                end
                
            end
        end
    end
    

end

%% output:
% adjust output size:
if k == 1
    NC = [];
else
    NC = NC(1:k-1,:);
end

end