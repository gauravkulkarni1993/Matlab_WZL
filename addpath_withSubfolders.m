function addpath_withSubfolders(foldername)
% This function adds a folder 'foldername' and all its subfolders to the
% current working path.
% The folder 'foldername' must be either on the current working path or
% specified to it.
%
% ------------------------------------------------ Max Schwenzer 10.06.2016

% check input variable:
if( ~ischar(foldername) )
    error('addpath_withSubfolders:INPUT:noChar',...
          'Input variable must be of type char.')
end

% get list of all folder content:
ListDirectoryContent = dir(foldername);
% process requiredinformation: form a vector.
AllIsDir = [ListDirectoryContent.isdir];
AllNames = {ListDirectoryContent.name};

% the first 2 elements are always '.' and '..' which correspond to the
% current folder and the parent folder.
% get rid of those by logical test:
LT = ~ismember(AllNames,{'.','..'});
AllNames = AllNames(LT);
AllIsDir = AllIsDir(LT);

% only keep directory names/paths:
DirNames = AllNames(AllIsDir);

if( ~isempty(DirNames) )
    % add directories to working path:
    for i = 1:length(DirNames)
        foldername_NEW = fullfile(foldername, DirNames{i});
        addpath( foldername_NEW );
        % call function recursive:
        addpath_withSubfolders( foldername_NEW );    
    end
end
end