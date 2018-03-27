function TDMSstruct = readTDMS(FileName, SaveFile)
% This function reads in a TDMS-file with the help of the 3rd-party 
% function TDMS_getStruct() and returns a struct.
% 
% INPUT:
% FileName  (char) Name of the TDMS-file. Must have the file extension
%           '.tdms'. Can also contain the relative or absolute path to a
%           TDMS-file.
% SaveFile  (char) If specified, the read in TMDS-file is saved as a
%           MAT-file with this name. No need to specify the file extension.
%           Can also be a path.
% OUTPUT:
% TDMSstruct (struct) Contains the information out of the TDMS-file.
%           fields:
%               Props - (struct) containes the name of the original 
%               TDMS-file
%               Internal - (struct) containes the signal-channels
%
% ------------------------------------------------ Max Schwenzer 10.06.2016



% --- check 'FileName':
% check input of type char:
if( ~ischar(FileName) )
    % input variable 'FileName' is no char. Throw error:
    error('readTDMS:INPUT:FileName:noChar',...
          'Input variable ''FileName'' must be of type char.')
end
% check for TDMS file:
% get file extionsion:
[~,~,FileNameExt] = fileparts(FileName);
if( ~strcmp(FileNameExt, '.tdms') )
    % input variable 'FileName' is not TDMS-file. Throw error:
    error('readTDMS:INPUT:FileName:noTDMS',...
          'Input variable ''FileName'' must be the name of a TDMS-file.')
end


% --- check 'SaveFile':
if( nargin > 1 )
    if( ~ischar(SaveFile) )
        % input variable 'SaveFile' is no char. Throw error:
        error('readTDMS:INPUT:SaveFile:noChar',...
              'Input variable ''SaveFile'' must be of type char.')
    end
end

% check if the function TDMS_getStruct() is on the current working path:
look4TDMS_getStruct();

% ----- load file:
% read TDMS file:
TDMSstruct = TDMS_getStruct(FileName);

% ----- save file:
if( nargin > 1 )
    save( SaveFile, 'TDMSstruct' )
end

end % --- End of Function --- %



function look4TDMS_getStruct()
% ---------------- PREPARATION: ALL FUNCTIONS AVAILABLE? ---------------- %

% suppress warning that private folders cannot be added to the path.
warning('off','MATLAB:dispatcher:pathWarning');

% Does the function TDMS_getStruct() exist on the workpath?
if( exist('TDMS_getStruct','file') ~= 2 )
    % => function does not exist (yet?) 
    % look for folders 'Matlab_TDMS_reader' or 'tdms2mat':
    if( exist('Matlab_TDMS_reader','file') == 7 )
        % => folder exist.
        look4folder = 'Matlab_TDMS_reader';
    elseif( exist('tdms2mat','file') == 7 )
        % => folder exist.
        look4folder = 'tdms2mat';
    else
        % => folders do not exist. Therefore the function cannot be found.
        % Throw error:
        error('Function:FoldersNotFound:TDMS_getStruct:missing',...
                ['The function TDMS_getStruct() could not befound on ',...
                'your working path. Please add it and its corresponding',...
                ' functions to your current working path.'])
    end
    % one of the folders does exist.
    
    % add folder and subfolders to workpath:
    addpath_withSubfolders(look4folder);
    % check if the function TDMS_getStruct() now is on the path:
    if( exist('TDMS_getStruct','file') ~= 2 )
        % => function does not exist.
        % Throw error:
        error('Function:TDMS_getStruct:missing',...
                ['The function TDMS_getStruct() could not befound on ',...
                'your working path. Please add it and its corresponding',...
                ' functions to your current working path.'])
    end
end
% ----------------- ------------------------------------ ---------------- %
end % --- End of SubFunction --- %