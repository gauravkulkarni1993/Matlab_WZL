function CW = weeknum(Date)
% Determines the calender week number.
%
% --- Syntax:
% CW = weeknum()
% CW = weeknum(Date)
%
% --- Description:
% CW = weeknum()    returns the current calender week of the year.
% CW = weeknum(Date)    returns the calender week of the date provided as
%                   input. The input can be of typ 'datetime' or
%                   'datenum'.
%
% ------------------------------------------------ Max Schwenzer 13.07.2016

if nargin < 1
    Date = datetime('now');
end

if isa(Date,'datetime')
    % datetime
elseif isa(Date,'double')
    % datenum
    Date = datetime(datevec( Date ));
else
    error('weeknum:InputType','The input must be of type datetime or datenum!');
end

CW = ceil( days(Date - datetime(year(Date),1,1)) /7 );

