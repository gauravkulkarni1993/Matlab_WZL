function [IDXStp,IntvlPStp] = findStepCenters(Sig,DBG)
% determines the center of a step in a signal
% 
% --- Syntax:
% IDXStp = findStepCenters(Sig)
% [IDXStp, IntvlPStp] = findStepCenters(Sig)
% 
% --- Description:
% IDXStp = findStepCenters(Sig) finds steps in a signal. Returns a struct
%          containing the indices of the center of the signal steps:
%          IDXStp.up - only upward steps
%          IDXStp.down - only downward steps
%          IDXStp.all - all steps in chronological order
% [IDXStp, IntvlPStp] = findStepCenters(Sig) returns a small interval where
%          the approximated gradient indicates a step in the singal.
%
% --- Note:
% required additional functions: makeSection()
% 
% ------------------------------------------------ Max Schwenzer 12.02.2017




%% find steps in command signal:
Diffcmd = diff(Sig);

% threshold for potential steps (PStp):
TH_PStp = 0.05 * range(abs(Diffcmd)); % 5% of the absolute range %FIXME: 10%!
% median(abs(Diffcmd(abs(Diffcmd) > 0.001)))
Lg = abs(Diffcmd) > TH_PStp;
MAX_GAP = 50; % TODO: make relative to signal length
MIN_CONCAT = 3; % TODO: make relative to signal length
IntvlPStp = makeSection(Lg,MAX_GAP,MIN_CONCAT); % NOTE: UserFunc
% determine center point of intervals
idxPStp = round( (IntvlPStp(:,2)-IntvlPStp(:,1))/2 ) + IntvlPStp(:,1);

% check if those are real steps
WINDOW_SIZE = 100; % TODO: make relative to signal length
TH_Stp = 0.2 * range(Sig);
Lg_StpUp = false(size(IntvlPStp,1),1);
Lg_StpDn = false(size(IntvlPStp,1),1);

for i = 1:size(IntvlPStp,1)
    % IDEA: compare mean values before and after potential step
    m1 = mean(Sig(IntvlPStp(i,1)-WINDOW_SIZE:IntvlPStp(i,1)));
    m2 = mean(Sig(IntvlPStp(i,2):IntvlPStp(i,2)+WINDOW_SIZE));
    
    if (m1 - m2) > TH_Stp
        % this is a step down
        Lg_StpDn(i) = true;
    elseif (m2 - m1) > TH_Stp
        % this is a step up
        Lg_StpUp(i) = true;
    end
end


%% assign output
IDXStp = struct();
IDXStp.up 	= idxPStp(Lg_StpUp);
IDXStp.down = idxPStp(Lg_StpDn);
IDXStp.all  = idxPStp(Lg_StpUp|Lg_StpDn);

IntvlPStp = IntvlPStp(Lg_StpUp|Lg_StpDn,:);




%% ------------------------------ DEBUGGING ------------------------------
%% plot for debugging
if nargin > 1 && islogical(DBG) && DBG
    fh.fig = figure;
    % --- plot signal
    fh.sub1 = subplot(2,1,1); % real signal
    smpls = 1:length(Sig); % numer of samples
    plot(smpls,Sig)
    hold(fh.sub1,'on')
    % potential step intervals
    for i = 1:size(IntvlPStp,1)
        sct = IntvlPStp(i,1):IntvlPStp(i,2);
        plot(smpls(sct),Sig(sct),'r-')
    end
    % potential step centers
    plot(smpls(idxPStp),Sig(idxPStp),'x','LineWidth',2,'Color','k')
    % step centers
    plot(smpls(IDXStp.all),Sig(IDXStp.all),'o','MarkerSize',10,'Color','k')
    hold off
    xlabel('Sample')
    legend({'signal','potential step interval','potential step center','step center'})
    title('findStepCenters()')
    
    % --- plot difference
    fh.sub2 = subplot(2,1,2);
    % difference:
    plot(smpls(1:end-1),[Diffcmd,abs(Diffcmd)], [1;smpls(end-1)],[TH_PStp;TH_PStp])
    hold(fh.sub2,'on')
    % potential step intervals
    for i = 1:size(IntvlPStp,1)
        plot(smpls(IntvlPStp(i,:)),[0 0],'r-','LineWidth',5)
    end
    % potential step centers
    plot(smpls(idxPStp),zeros(size(idxPStp)),'x','LineWidth',2,'Color','k')
    % step centers
    plot(smpls(IDXStp.all),zeros(size(IDXStp.all)),'o','Color','k')
    hold off
    xlabel('Sample')
    legend({'diff(signal)','abs(diff(signal))','threshold'})

    
    linkaxes([fh.sub1,fh.sub2],'x')
end
end