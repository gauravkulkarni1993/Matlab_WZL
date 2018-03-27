function lg = expandIDX(idx,len,Sz)
% expands the index vector
%
% --- Syntax:
% lg = expandIDX(idx,len,Sz)
% 
% --- Description:
% lg = expandIDX(idx,len,Sz) creates a logical vector lg of the length len,
%       which is false except for the indices idx and the region idx+/-Sz
%
% 
% ------------------------------------------------ Max Schwenzer 11.08.2017

%%

lg = false(len,1);
for i = 1:length(idx)
    strt = idx(i)-Sz;
    ende = idx(i)+Sz;
    
    % check start & end values
    if strt < 1
        strt = 1;
    end
    
    if ende > len
        ende = len;
    end
    % assign to logical vector:
    lg(strt:ende) = true;
end



end

