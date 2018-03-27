
function Data = readToolScopeCSV2(FilePath,varargin)
% Reads CSV-file of the data aquisition system 'ToolScope' of the company
% KOMET-Brinkhaus.
%
% --- Syntax:
% Data = readToolScopeCSV(FilePath)
%
% --- Description:
% Data = readToolScopeCSV(FilePath) read the CSV file in 'FilePath' and
%           creates the output struct 'Data'. Numeric values, binary values
%           char values are stored in seperate fields.
%
% --- Note 1:
% The CSV-file is not formated as a standard CSV-file. It has a bigger
% header and floating-point numbers are given in the German format (decimal
% delimiter = ','). These file can be very big and thus MATLAB native
% functions may run into trouble.
%
% --- Note 2:
% This function requires PERL, which is delivered with MATLAB. A local
% function "ConvertDecimalComma2Point.pl" is called to replace all decimal
% commas with a point and to count the number of lines in the file.
% ------------------------------------------------ Max Schwenzer 26.07.2016

% Example: 
% FilePath = 'D:\users\scw\tmp\SAP\Daten\007_Brinkhaus_Schruppen.csv';


% check input:
% existance
if exist(FilePath,'file') ~= 2
    error('readToolScopeCSV:FileExistance',...
            'The file in FilePath does not exist.');
end
% file format
[~,~,sExt] = fileparts(FilePath);
if ~strcmp(sExt, '.csv')
    error('readToolScopeCSV:FileFormat',...
            'The file FilePath is not a CSV-file.');
end
% perl function:
if exist('ConvertDecimalComma2Point.pl','file') ~= 2
    error('readToolScopeCSV:Local_PERL_function:ConvertDecimalComma2Point',...
            'The required PERL-function "ConvertDecimalComma2Point.pl" is missing.');
end


CAST2SINGLE = any( cellfun(@(x)ismember(x,{'Cast2Single','single'}),varargin) );
    

%% ---------------------- read header information ----------------------- %
fileID = fopen( FilePath ); % open file
% check if opend correctly
if fileID < 3
    error('readToolScopeCSV:fopen',...
        ['MATLAB was unable to open the file ',FilePath,' correctly.']);
end

% aquire all input:
% loop through all lines
OFFSET_Head = 8;
for i = 1:OFFSET_Head
    % read line
    line = fgets(fileID);
    
    % preallocate memory:
    if i == 1
        % split line at semicolon ';' (delimiter)
        line_split = strsplit(line,';','CollapseDelimiters',false);
        % preallocate memory
        Header = cell(OFFSET_Head, length(line_split));
        % store data in new data variable
        Header(i,:) = line_split;
    else
        % store data in new data variable
        Header(i,:) = strsplit(line,';','CollapseDelimiters',false);
    end
end
fclose(fileID); % close file again
% process header data:
for i = 1:OFFSET_Head
    Header{i,end} = Header{i,end}(1:end-2); % pop off the last 2 characters of the last element
end
% ----------------------- ----------------------- ----------------------- %


%% --------------------------- read data file --------------------------- %
% ----- build text pattern (=formatSpec) for textscan():
VarType = Header(6,:);
% C = textscan(fileID,formatSpec)
% formatSpec
% %f = double
% %s = string
% %D = datetime

formatSpec = char( zeros(1,length(VarType)*2) ); % preallocate memory
formatSpec(1:2) = '%f';
j = 2;
Num_double = 1;
for i = 2:length(VarType)
    switch VarType{i}
        case 'Double'
            str = '%f';
            Num_double = Num_double +1;
        case 'String32'
            str = '%s';
        otherwise
            error('readToolScopeCSV2:formatSpec:SwitchCase','');
    end
    formatSpec(j+1:j+2) = str;
    j = j +2;
end

% ----- process data file:
% use perl script to replace the decimal comma with a point, such that
% textscan() can recognize it as a number:
% tic;
str = perl('ConvertDecimalComma2Point.pl',FilePath);
tmp = strsplit(str);
tmpFileNm = tmp{1}; % name of the temporary file
NumLines = str2double( tmp{2} ); % number of lines in the file
% toc;

% ----- read actual values:
% use textscan() to read all data in a matlab-cell:
% tic;
fileID = fopen( tmpFileNm,'r' );
if fileID < 3
    error('readToolScopeCSV:fopen',...
        ['MATLAB was unable to open the file ',FilePath,' correctly.']);
end

D = textscan(fileID, formatSpec, NumLines,...
                    'headerlines',OFFSET_Head,'Delimiter',';');
fclose(fileID);
% toc;
% delete temporary file:
delete(tmpFileNm);
% ---------------------------- -------------- --------------------------- %


%% ----------------------- process imported data ------------------------ %

Var.Channel     = {'t',Header{2,2:end}}; % 2nd row
Var.Name        = Header(3,:); % 3rd row
Var.Unit        = Header(4,:); % 4th row
Var.Type        = VarType; % 6th row

try
Data.date = datetime([Header{1,1}(4:end),Header{2,1}(1:8)],...
                                'InputFormat','yyyy-MM-ddHH:mm:ss');
catch
    Data.date = {Header{1,1} Header{2,1}};
end
% preallocate memory
Data.num.sig     = zeros( NumLines -OFFSET_Head -1, Num_double );
Data.num.Channel = cell( 1,size(Data.num.sig,2) );
Data.num.Name    = cell( 1,size(Data.num.sig,2) );
Data.num.Unit    = cell( 1,size(Data.num.sig,2) );

Data.bin.sig     = false( NumLines -OFFSET_Head -1, Num_double );
Data.bin.Channel = cell( 1,size(Data.bin.sig,2) );
Data.bin.Name    = cell( 1,size(Data.bin.sig,2) );
Data.bin.Unit    = cell( 1,size(Data.bin.sig,2) );

Data.txt.sig     = cell( NumLines -OFFSET_Head -1, ceil(Num_double/5) );
Data.txt.Channel = cell( 1,size(Data.txt.sig,2) );
Data.txt.Name    = cell( 1,size(Data.txt.sig,2) );
Data.txt.Unit    = cell( 1,size(Data.txt.sig,2) );

i_num = 1; % control variable: numeric value
i_bin = 1; % control variable: binary/logical value
i_txt = 1; % control variable: text value
for i = 1:size(Header,2) % column
    
    if strcmpi(Var.Type(i),'Double') && ismember(Var.Unit{i},{'0/1','-'})% strcmpi(Var.Unit{i},'0/1')
        % binary/logical value
        Data.bin.sig(:,i_bin)       = logical(D{1,i}); % signal
        Data.bin.Channel(1,i_bin)   = Var.Channel(1,i); % channel
        Data.bin.Name(1,i_bin)      = Var.Name(1,i); % name
        Data.bin.Unit(1,i_bin)      = Var.Unit(1,i); % unit
        
        i_bin = i_bin +1;
    elseif strcmpi(Var.Type(i),'Double') || i==1
        % numeric value
        Data.num.sig(:,i_num)       = D{1,i}; % signal
        Data.num.Channel(1,i_num)   = Var.Channel(1,i); % channel
        Data.num.Name(1,i_num)      = Var.Name(1,i); % name
        Data.num.Unit(1,i_num)      = Var.Unit(1,i); % unit
        
        i_num = i_num +1;
    elseif strncmpi(Var.Type(i),'String',6)
        % text value
        Data.txt.sig(:,i_txt)      = D{1,i}; % signal
        Data.txt.Channel(1,i_txt)  = Var.Channel(1,i); % channel
        Data.txt.Name(1,i_txt)     = Var.Name(1,i); % name
        Data.txt.Unit(1,i_txt)     = Var.Unit(1,i); % unit
        
        i_txt = i_txt +1;
    end
end
% correct data length:

if CAST2SINGLE
    Data.num.sig        = single(Data.num.sig(:,1:i_num -1));
else
    Data.num.sig        = Data.num.sig(:,1:i_num -1);
end
Data.num.Channel    = Data.num.Channel(:,1:i_num -1);
Data.num.Name       = Data.num.Name(:,1:i_num -1);
Data.num.Unit       = Data.num.Unit(:,1:i_num -1);

Data.bin.sig        = Data.bin.sig(:,1:i_bin -1);
Data.bin.Channel    = Data.bin.Channel(:,1:i_bin -1);
Data.bin.Name       = Data.bin.Name(:,1:i_bin -1);
Data.bin.Unit       = Data.bin.Unit(:,1:i_bin -1);

Data.txt.sig        = Data.txt.sig(:,1:i_txt -1);
Data.txt.Channel    = Data.txt.Channel(:,1:i_txt -1);
Data.txt.Name       = Data.txt.Name(:,1:i_txt -1);
Data.txt.Unit       = Data.txt.Unit(:,1:i_txt -1);
end


% function NumLines = CountLines( FilePath )
% 
% if exist('CountLines.pl','file') == 2
%     use pearl script (very fast)
%     NumLines = str2double( perl('CountLines.pl', FilePath) );
% else
%     read only the first character of each line
%     fileID = fopen( FilePath );
%     NumLines = numel( cell2mat(textscan(fileID,'%1c%*[^\n]')) );
%     fclose(fileID);
% end
% end