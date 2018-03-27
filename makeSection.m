function Sct = makeSection(LG,MaxGap,MinConcat)
% creates sections of connected data
% 
% --- Syntax:
% Sec = makeSections(LG)
% Sec = makeSections(LG,MaxGap)
% Sec = makeSections(LG,MaxGap,MinConcat)
% 
% --- Description:
% Sec = makeSection(LG)    determines the start and end index of connected
%       data points in the logical input vector LG.
% Sec = makeSection(LG,MaxGap)  specifies the maximum allowed number of
%       points that can be missing so that the section is still considered 
%       as connected. Default: 1/1e5*length(Signal)
% Sec = makeSection(LG,MaxGap,MinConcat)  specifies the the minimum number
%       of concatenated data points. Default: 1/1e4*length(Signal)
% 
% ------------------------------------------------ Max Schwenzer 26.10.2016


% process input:
if nargin < 2 || isempty(MaxGap)
    MaxGap = ceil(length(LG)/1e5);
end
if nargin < 3 || isempty(MinConcat)
    MinConcat = ceil(length(LG)/1e4);
end


%% determine index/indices:
IDX = find(LG);
if isempty(IDX)
    Sct = [];
    return
end
idx_dff = find( diff(IDX) > MaxGap );


%% create intervals from results:
if isempty(idx_dff)
    Sct = [IDX(1), IDX(end)];
else
    if idx_dff(end) >= max(IDX)
        Sct = [IDX(idx_dff(1:end-1)) IDX(idx_dff(1:end-1)+1)];
    else
        Sct = [IDX(idx_dff) IDX(idx_dff+1)];
    end
    % invert section
    Sct = [[IDX(1); Sct(:,2)] [Sct(:,1); IDX(end)]];
    % make sure that the sections are long enough
    Sct = Sct(Sct(:,2)-Sct(:,1) >= MinConcat,:);
end

end