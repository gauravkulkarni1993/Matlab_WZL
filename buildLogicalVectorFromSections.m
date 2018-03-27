function lg = buildLogicalVectorFromSections(sct,len)
% builds a logical vector
% 
% --- Syntax:
% lg = createLogicalVectorFromSections(sct,len)
%
% --- Description:
% lg = createLogicalVectorFromSections(sct,len) builds a logical vector of
%       the length len. Indices within the sections sct are set to true,
%       the rest is false.
% 
% ------------------------------------------------ Max Schwenzer 11.10.2017

%%
lg = false(len,1);
for i = 1:size(sct,1)
    lg(sct(i,1):sct(i,2)) = true;
end

end