function StpAct = findSteps(cmd,act,DBG)
% determines the interval of steps in a signal
% 
% --- Syntax:
% StpAct = findSteps(cmd)
% StpAct = findSteps(cmd,act)
% 
% --- Description:
% StpAct = findSteps(cmd) determines the indices of all steps of the input
%          signal.
% StpAct = findSteps(cmd,act) determines the indices of all steps of a
%          signal based on the commanded and corresponding actual signal.
%          The actual signal is used to refine the results optained based
%          just on the commanded signal
%
% --- Note:
% required additional functions: findStepCenters(), makeSection()
% 
% ------------------------------------------------ Max Schwenzer 13.02.2017

%% input processing
if nargin < 3 || ~islogical(DBG)
    DBG = false;
end

if isa(cmd,'timeseries')
    cmd = cmd.data;
end


%% find steps
[~,IntvlStpCmd] = findStepCenters(cmd,DBG);

StpCmd = zeros(size(IntvlStpCmd));
% determine excat start & end poit of commanded step:
for i = 1:size(IntvlStpCmd,1)
    StpCmd(i,1) = runingWindow(cmd,IntvlStpCmd(i,1),false);
    StpCmd(i,2) = runingWindow(cmd,IntvlStpCmd(i,2),true);
end

if nargin > 1 && ~isempty(act)
    if isa(act,'timeseries')
        act = act.data;
    end
    
    % determine how long the actual step is:
    StpAct = StpCmd;
    for i = 1:size(StpCmd,1)
        StpAct(i,2) = runingWindow(act,StpCmd(i,2),true);
    end
else
    StpAct = StpCmd;
end




%% ------------------------------ DEBUGGING ------------------------------
%% plot for debugging
if DBG
    % --- plot signal
    fh.sub1 = subplot(2,1,1);
    hold(fh.sub1,'on')
    % plot commanded step start & end points:
    plot(fh.sub1,StpCmd(:),cmd(StpCmd(:)),'*','Color','b');
    % plot actual step start & end points:
    plot(fh.sub1,StpAct(:),cmd(StpAct(:)),'*','Color','k');
    hold(fh.sub1,'off')
    
    % --- plot difference
    fh.sub2 = subplot(2,1,2);
    hold(fh.sub2,'on')
    % plot commanded step start & end points:
    plot(fh.sub2,StpCmd(:),zeros(size(StpCmd(:))),'*');
    % plot actual step start & end points:
    plot(fh.sub2,StpAct(:),zeros(size(StpAct(:))),'*');
    hold(fh.sub2,'off')
    
    fh2.fig = figure;
    plot([cmd,act]);
    hold on
    plot(StpAct(:),act(StpAct(:)),'*','Color','k');
    for i = 1:size(StpAct,1);
        sct = StpAct(i,1):StpAct(i,2);
        plot(sct,act(sct),'Color','r','LineWidth',2);
    end
    hold off
    xlabel('Sample')
    title('findSteps()')
    
end
end

function idx = runingWindow(sig,idxStrt,GoRight)
% follows a signal until it reaches a stable value

    % stopping chriterion
    TH = (range(sig)-abs(median(sig)))/1000;% 1e-3; % TODO: make relative
    NUM_CONSECUTIVE_MEAN_VALS = 15; % length(sig)/300 % TODO: make relative/optional
    WINDOW_SIZE = 20; % TODO: make relative
    % allocate memory
    m = (1:NUM_CONSECUTIVE_MEAN_VALS)';
    
    % determine end of for loop
    if GoRight
        End = length(sig)-idxStrt-1-WINDOW_SIZE;
    else
        End = idxStrt-1-WINDOW_SIZE;
    end
    
    % loop through signal
    k = 1; % control variable
    for i = 0:End
        % determine if it
        if GoRight
            sct = idxStrt+i : idxStrt+i+WINDOW_SIZE;
        else
            sct = idxStrt-i-WINDOW_SIZE : idxStrt-i;
        end
        
        m(k) = mean(sig(sct));
        % stop criterion:
        if all( abs(m -m(1)) < TH )
            break;
        end
        
        % update control variable:
        k = k+1;
        if k > NUM_CONSECUTIVE_MEAN_VALS
            k = 1;
        end
    end
    
    % assign output
    if GoRight
        idx = idxStrt+i;
    else
        idx = idxStrt-i;
    end
end

% subplot(2,1,1)
% hold on
% plot(idxStrt-i,sig(idxStrt-i),'*')