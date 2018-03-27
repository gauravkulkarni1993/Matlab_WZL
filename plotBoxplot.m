function plotBoxplot(varargin)
% TODO: description
% plotbox Plots the quantile values (Q) of the Data
% Q exists of 5 values
% Q: Quantile-Vector Q = [5 25 50 75 95]
% specifies the quantils to be calculated plotted

% plots a boxplot with the quantiles 5% 25% 50% 75% 95%, no outliers
%
% --- Syntax:
% plotBoxplot(M)
% plotBoxplot(Q)
% plotBoxplot(x,M)
% plotBoxplot(ax,...)
% 
% --- Description:
% plotBoxplot(M)    if M is a value vector, the quantiles 5,25,50,75,95 are
%       determined and illustrated as boxplot. If M is a value matrix, the
%       quantiles are determined for every column n and illustrated as n
%       seperate boxplots.
% plotBoxplot(Q)    you can provide the quantiles directly. All vectors
%       or matrices with 5 columns are assumed to be quantiles if the 
%       values are ascending.
% plotBoxplot(x,M)    you can provide the position where the poxplot
%       should be placed on the x axis.
% plotBoxplot(ax,...)   takes the axis handle as input
% 
% ------------------------------------------------ Max Schwenzer 11.08.2017



%% process input

% get handle
if isa(varargin{1},'handle')
    axh = varargin{1};
    varargin = varargin(2:end);
else
    axh = gca; % get current axis handle
end


% get position
if length(varargin) >= 2 && (isnumeric(varargin{1}) && isnumeric(varargin{2}))
    % get coordinate
    pos = varargin{1};
    varargin = varargin(2:end);
else
    pos = [];
end

% get quantiles
% idx = find(strcmpi('Q',varargin),1);
% if ~isempty(idx) && length(varargin) > idx  && isnumeric(varargin{idx+1})
%     Q = varargin{idx+1};
%     lg = true(size(varargin));
%     lg(idx:idx+1) = false;
%     varargin = varargin(lg);
% else
    

    if isnumeric(varargin{1}) && size(varargin{1},1) == 5
        Q = varargin{1};
    elseif isnumeric(varargin{1}) && size(varargin{1},1) == 7
        Q_tmp = varargin{1};
        Q = [Q_tmp(2:6,:);Q_tmp(1,:); Q_tmp(7,:)];
    elseif isnumeric(varargin{1})
        Q = quantile(varargin{1},[0.05 0.25 0.5 0.75 0.95])';
        if size(varargin{1},1) < size(varargin{1},2)
            Q = Q';
        end
    else
        error('plotBoxplot:input:Q','Input is not a vector of quantiles nor a signal vector.')
    end
% end

if length(varargin) > 1
    varargin = varargin(2:end);
else
    varargin = [];
end


if isempty(pos)
    pos = 1:size(Q,2);
end


%%


Flag_holdOn = ishold(axh);
% call boxplot
for i = 1:length(pos)
    Flag_holdOn_tmp = true;
    if i == 1 || i == length(pos)
        Flag_holdOn_tmp = Flag_holdOn;
    end

    plotSingleBoxplot(axh,pos(i),Q(:,i),Flag_holdOn_tmp)
end


end


function plotSingleBoxplot(axh,pos,Q,Flag_holdOn,varargin)
% TODO: description
% plotbox Plots the quantile values (Q) of the Data
% Q exists of 5 values
% Q: Quantile-Vector Q = [5 25 50 75 95]
% specifies the quantils to be calculated plotted




%% process data
Mx = zeros(8,2);
My = zeros(8,2);
% 5% quantile line
Mx(1,:) = [pos-0.35 pos+0.35];
My(1,:) = [Q(1) Q(1)];

% 5% quantile to 25% quantile line
Mx(2,:) = [pos pos];
My(2,:) = [Q(1) Q(2)];

% 25% quantile  line
Mx(3,:) = [pos-0.35 pos+0.35];
My(3,:) = [Q(2) Q(2)];

% 25% quantile to 75% line
Mx(4,:) = [pos-0.35 pos-0.35];
My(4,:) = [Q(2) Q(4)];
Mx(5,:) = [pos+0.35 pos+0.35];
My(5,:) = [Q(2) Q(4)];

% 75% quantile  line
Mx(6,:) = [pos-0.35 pos+0.35];
My(6,:) = [Q(4) Q(4)];

% 75% quantile to 90% quantile line
Mx(7,:) = [pos pos];
My(7,:) = [Q(4) Q(5)];

% 90% quantile  line
Mx(8,:) = [pos-0.35 pos+0.35];
My(8,:) = [Q(5) Q(5)];
%% plot
if Flag_holdOn
    hold(axh,'on'); 
end
plot(axh,Mx',My','Color','k',varargin{:});
if ~Flag_holdOn
    hold(axh,'on'); 
end
% 50% quantile line or median
plot(axh,[pos-0.35 pos+0.35], [Q(3) Q(3)],'Color','r',varargin{:});
% outliers
if length(Q) >= 7
    plot(axh,[pos pos], [Q(6) Q(7)],'x','Color','r',varargin{:});
end
if ~Flag_holdOn
    hold(axh,'off');
end
end