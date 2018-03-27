function Wrd = findExpInLst(List,KeyWords)
% finds expressions in a cell list
% 
% --- Syntax:
% Wrd = findExpInLst(List,KeyWords)
% 
% --- Description:
% Wrd = findExpInLst(List,KeyWords) looks for the expressions 'KeyWords' in
%       the cell-list 'List' and returns the full word. Patterns can be
%       used as keywords.
% 
% ------------------------------------------------ Max Schwenzer 10.10.2017


    idx = cellfun(@(x)regexpi(x,KeyWords,'ONCE'),List,'UniformOutput',false);
    lgLst = ~cellfun(@(x)isempty(x{1}),idx);
    if any(lgLst)
        lgKyw = ~cellfun(@isempty,idx{lgLst});
        Wrd = List(lgKyw);
    else
        Wrd = [];
    end
end
