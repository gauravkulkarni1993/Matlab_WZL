function [lg, details] = parseString(str,CodeWord)
% looks for code words in a string
%
% --- Syntax:
% [lg] = parseString(str,CodeWord)
% [lg, details] = parseString(str,CodeWord)
%
% --- Description:
% [lg] = parseString(str,CodeWord)  returns a logical vector of size
%       CodeWord indicating if the corresponding CodeWord is in the string.
%       The code word can include patterns as * or ?. # is considered as a
%       special character indicating that a number has to follow the
%       command. The code word can include any combination of the patterns.
% [lg, details] = parseString(str,CodeWord) additionally returns
%
% 
% ------------------------------------------------ Max Schwenzer 11.08.2017


%% process input
if ischar(str)
    str = cellstr(str);
end
if ischar(CodeWord)
    str = cellstr(CodeWord);
end

%% preprocess code words
flag =  regexp(CodeWord,'#');
flag = ~cellfun(@isempty,flag);
ExpNum = struct(); % allocate memory
n = 0;
for i = 1:length(flag)
    if flag(i)
        n = n+1;
        ExpNum.(['CW',num2str(n)]) = strsplit(CodeWord{i},'#');
    end
end
% sort CodeWord
CodeWord = [CodeWord(~flag),CodeWord(flag)];


len = size(str,1) +10;
lg = false(len,1);
details = table(zeros(len,1),zeros(len,1),zeros(len,1),cell(len,1),...
                            'VariableNames',{'line','idxStart','idxEnd','CodeWord'});
k = 1;
% loop through written input
for i = 1:size(str,1)
    line = str(i,:);
    
    % allocate memory
    idxStart = cell(1, length(CodeWord)+n-1);
    idxEnd = idxStart;
    % loop through commands/code words
    for j = 1:length(CodeWord)-n
        idxStart(j) = regexp(line,CodeWord(j));
        idxEnd{j} = idxStart{j}+length(CodeWord{j});
    end
    % loop through code words expecting numbers
    for j = length(CodeWord)-n+1:length(CodeWord)    
        [idxStart{j},idxEnd{j}] = checkHash(line,ExpNum.(['CW',num2str(j-(length(CodeWord)-n))]));
    end
    
    % process idx
    if ~isempty(idxStart)
        lg(i) = true;
    end
    if nargout > 1
        for j = 1:length(CodeWord)
            if ~isempty(idxStart{j})
                for l = 1:length(idxStart{j})
                    details.line(k)     = i; 
                    details.idxStart(k)      = idxStart{j}(l);
                    details.idxEnd(k)        = idxEnd{j}(l);
                    if j <= length(CodeWord)
                        details.CodeWord(k) = CodeWord(j);
                    end
                    k = k+1;

                    % check if memory is used up:
                    if k > height(details)
                        details = [details, table(zeros(len,1),zeros(len,1),zeros(len,1),cell(len,1),...
                                'VariableNames',{'line','idxStart','idxEnd','CodeWord'})]; %#ok<AGROW>
                        lg = logical([lg,false(len,1)]);
                    end


                end
            end
        end
    end
end
% adjust output table:
details = details(1:k-1,:);
lg = lg(1:k);

end


%% -------------------------- LOCAL FUNCTIONS -------------------------- %%

function [idxStart,idxEnd] = checkHash(line,CW)
    if iscell(line)
        line = line{:};
    end
    % check if first value after the code word is a number:
    cand = strfind(line,CW{1});
    lg = false(length(cand),1);
    for i = 1:length(cand)
        if cand(i) < length(line)
            lg(i) = ~isnan(str2double(line(cand(i)+length(CW{1}))));
        end
    end
    cand = cand(lg);
    idxEnd = zeros(size(cand));
    
    % check if the pattern after a hash is still true
    lg = false(length(cand),1);
    for i = 1:length(cand)% loop through all (checked) candidates
        
        for c = 2:length(CW)
            pattern = CW{c};
            if isempty(pattern)
                % no pattern after hash #
                lg(i) = true;
                idxEnd(i) = findEndOfNumber(line,cand(lg),CW{1});
            else
                for j = cand(i)+1:length(line)
                    if isnan(str2double(line(j)))
                        idxStart = strfind(line(j:length(line)),pattern);
                        %TODO idxEnd!
                        if idxStart == 1
                            lg(i) = true;
                            % continue
                        else
                            break
                        end
                    end
                end
            end
        end
    end
    idxStart = cand(lg);
    idxEnd = idxEnd(lg);
end

function idxEnd = findEndOfNumber(line,idxStart,CW)
if iscell(line)
    line = line{:};
end

EndOfLine = true;
for i = idxStart+length(CW):length(line)
    if isnan(str2double(line(i)))
        EndOfLine = false;
        break;
    end
end

if EndOfLine
    idxEnd = i;
else
    idxEnd = i-1;
end

end