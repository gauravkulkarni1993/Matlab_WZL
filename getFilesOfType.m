function DirLstFile = getFilesOfType(Path, Ext_des, Pattern)
% Gets a list of files of a defined type.
%
% --- Syntax:
% DirLstFile = getFilesOfType(Path, Ext_des)
% DirLstFile = getFilesOfType(Path, Ext_des, Pattern)
%
% --- Description:
% DirLstFile = getFilesOfType(Path, Ext_des) gets list of file names of all
%               files matching the provided file extension.
% DirLstFile = getFilesOfType(Path, Ext_des, Pattern) matches the file
%               names with the provides name pattern.
%
% ------------------------------------------------ Max Schwenzer 19.07.2016

% change log:
% 09.11.2016 scw: extension needs to be exact match (still case 
%                 insensitive)


if nargin < 3
    Pattern = '\w*';
end
if ~ischar(Ext_des)
    error('getFilesOfType:Input:Ext_desIsNoChar',...
        'Input Ext_des must be of type char.');
end


DirLst = dir(Path);
DirLst = DirLst( ~ismember({DirLst.name},{'.','..'}) );
DirLstFile = cell(length(DirLst),1); % allocate memory
k = 1;
for i = 1:length(DirLst)
    [~,sName,sExt] = fileparts(DirLst(i).name);
%     if ~isempty( regexpi(sExt, Ext_des,'ONCE') ) &&...
    if any( strcmpi(sExt,{Ext_des,['.',Ext_des]}) ) &&...
            ~isempty( regexp(sName, Pattern,'ONCE') )
        DirLstFile{k} = DirLst(i).name;
        k = k +1;
    end
end

DirLstFile = DirLstFile(1:k -1); % correct cell length
end