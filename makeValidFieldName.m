function Name = makeValidFieldName(str)
% creates a valid field name for a matlab structure
% 
% --- Syntax:
% Name = makeValidFieldName(str)
% 
% --- Description:
% Name = makeValidFieldName(str) replaces all points (.) and scores (-) 
% 		with an underscore (_) and deletes all characters, which are not an
%		English character or a number.
% 
% ------------------------------------------------ Max Schwenzer 12.10.2017

%% main
% replace . and - with _
newStr = strrep(str,'.','_');
newStr   = strrep(newStr,'-','_');

% Remove characters using regexprep
Name = regexprep(newStr,'[^a-zA-Z0-9_]','');      
%%

% no leading number
if ~isnan( str2double(Name(1)) )
    Name = ['F',Name];
end

end