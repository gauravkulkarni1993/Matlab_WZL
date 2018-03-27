function [x_m,y_m] = mirror(x,y,ax,varargin)
% mirrors points on an axis
%
% --- Syntax:
% [x_m,y_m] = mirror(x,y,'x')
% [x_m,y_m] = mirror(x,y,'y')
% [x_m,y_m] = mirror(x,y,ax)
% 
% --- Description:
% [x_m,y_m] = mirror(x,y,'x') mirrors the provided 2D signal (x,y) on the
%       x-axis. Returns the mirrored points (x_m,y_m)
% [x_m,y_m] = mirror(x,y,'y') mirrors the provided 2D signal (x,y) on the
%       y-axis.
% [x_m,y_m] = mirror(x,y,ax) mirrors the provided 2D signal (x,y) on the
%       provided axis/line vector. [x_ax,y_ax]
%
% ------------------------------------------------ Max Schwenzer 12.01.2018




%% process user input
if ischar(ax) && strcmpi(ax,'x')
    % mirror on X-axis
    x_m = x;
    y_m = -y;
elseif ischar(ax) && strcmpi(ax,'y')
    % mirror on Y-axis
    x_m = -x;
    y_m = y;
elseif isnumeric(ax) && size(ax,1) >= 2 && size(ax,2) == 2
    % mirror on provided line
    
    %% ensure equal length
    x_max = max(x);
    x_min = min(x);
    
    % ensure that the smalles X-value is the first of the array
    if ax(1,1) > ax(end,1)
        ax = flip(ax);
    end
    
    if ax(1,1) > x_min
        % extrapolate linearly
        ax = [  x_min extrapolateLinearly(ax(2,1:2), ax(1,1:2), x_min)
                ax];
    end
    if ax(end,1) < x_max
        % extrapolate linearly
        ax = [  ax
                x_max extrapolateLinearly(ax(end-1,1:2), ax(end,1:2), x_max)];
    end    
    %% mirror
    % get corresponding y values of the line/axis:
    y_ax = interp1(ax(:,1),ax(:,2),x);
    y_m = y_ax - (y - y_ax);
    % get corresponding x values of the line/axis:
    x_ax = interp1(ax(:,2),ax(:,1),y);
    x_m = x_ax - (x - x_ax);
    
     if contains(varargin,{'only y','only Y'})
         x_m = x;
     elseif contains(varargin,{'only x','only X'})
         y_m = y;
     end
    
    
end


end

function y = extrapolateLinearly(xy1, xy2, x_new)
    y = xy1(2) + (xy2(2)-xy1(2))/(xy2(1)-xy1(1))*(x_new - xy1(1));
end

