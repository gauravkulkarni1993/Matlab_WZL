function [idxSig1,idxSig2,lag] = CrossCorrelation(Sig1,Sig2,dbg)
% cross-correlates two signals (not mirrored)
%
% --- Syntax:
% Sig_new = CrossCorrelation(Sig1,Sig2)
% [Sig_new,idx_shift] = CrossCorrelation(Sig1,Sig2)
% 
% --- Description:
% Sig_new = CrossCorrelation(Sig1,Sig2)     performes a cross correlation
%       on the provided signals. Signal 1 (Sig1) must be smaller than
%       signal 2 (Sig2). The minimal overlap size is half of signal 1. The
%       function returns the croped signal 1.
% [Sig_new,idx_shift] = CrossCorrelation(Sig1,Sig2)     the second return
%       value is the number of points that signal 1 is shifted. 
% 
% ------------------------------------------------ Max Schwenzer 19.04.2017

% TODO: Exact same size! length(Sig_new) == length(Sig2)
%     Sig1 = Modell
%     Sig2 = Daten
if size(Sig1,1) < size(Sig1,2) %array vector
    Sig1 = Sig1';
end
if size(Sig2,1) < size(Sig2,2) %array vector
    Sig2 = Sig2';
end


len_Sig1 = length(Sig1);
len_Sig2 = length(Sig2);
% assert(len_Sig1 <= len_Sig2) % Signal 2 > Signal 1

minOverlap = min([len_Sig1,len_Sig2])/3;


% use MATLAB-native cross correlation (estimate):
[corr,lags] = xcorr(Sig1,Sig2);
% extract local peaks (index):
[~,idx] = findpeaks(corr);
% only consider peaks which are sufficiently high:
TH = median(corr) + std(corr);
idx = idx(corr(idx) > TH);
[~,idx_max] = max(corr); % no mirrored signals!

%% processing
% consider lags:
idx = idx(idx ~= idx_max);
[~,srt] = sort(abs(lags(idx)));
if length(srt) > 1000
    srt = srt(1:1000);
end
idx = idx(srt);
idx_cand = [idx_max;idx];

idx_cand = idx_cand( ~(lags(idx_cand) < minOverlap-len_Sig1) ); % shifted too much left 
idx_cand = idx_cand( ~(lags(idx_cand) > len_Sig2-minOverlap) ); % shifted too much right


% fallback:
lag = 0;
idxSig1 = [1 len_Sig1];
idxSig2 = [1 len_Sig1];

FitArea_min = Inf;
for i = 1:length(idx_cand)
    lag_tmp = -lags(idx_cand(i)); % idx_cand(i);%
    
    % get indices:
    idxSig1_tmp = [1 len_Sig1]-lag_tmp-1;
    idxSig2_tmp = [1 len_Sig1];
    if idxSig1_tmp(1) > 1 % shift Sig1 left
        idxSig1_tmp(2) = len_Sig1;
        idxSig2_tmp(2) = idxSig1_tmp(2)-idxSig1_tmp(1)+1;
    elseif idxSig1_tmp(1) < 1 % shift Sig1 right
        idxSig2_tmp = [1 len_Sig1] -idxSig1_tmp(1)+1;
        idxSig1_tmp = [1 len_Sig1];
    end
    
    if idxSig2_tmp(2) > len_Sig2
        idxSig2_tmp(2) = len_Sig2;
        idxSig1_tmp(2) = idxSig1_tmp(1) + (idxSig2_tmp(2)-idxSig2_tmp(1));
    end
    
    % calc area:
    Sig2_cut = Sig2(idxSig2_tmp(1):idxSig2_tmp(2));
    Sig1_cut = Sig1(idxSig1_tmp(1):idxSig1_tmp(2));
    FitArea =  sum( (Sig2_cut - Sig1_cut).^2 )/length(Sig2_cut)^2;
    if FitArea < 0.95*FitArea_min
        lag = lag_tmp;
        idxSig1 = idxSig1_tmp;
        idxSig2 = idxSig2_tmp;
        FitArea_min = FitArea;
    end
end
% plot([Sig2(idxSig2(1):idxSig2(2)),Sig1(idxSig1(1):idxSig1(2))])


% output:





%% debugging
if nargin > 2 && dbg
    fh.fig = figure;
    % plot original signals
    fh.sub1 = subplot(3,1,1);
    plot(fh.sub1, (1:len_Sig1)',Sig1, (1:len_Sig2)',Sig2);

    title(fh.sub1, 'original signals');
    legend(fh.sub1, {'Signal 1', 'Signal 2'});


    % plot correlation
    fh.sub2 = subplot(3,1,2);
    plot(fh.sub2, corr)
    hold(fh.sub2, 'on');
    plot(fh.sub2, idx_cand,corr(idx_cand),'o','Color','r');
    hold off

    title(fh.sub2, 'correlation & peaks');
    legend(fh.sub2, {'correlation', 'peak(s)'});


    % plot (shifted) signals:
    fh.sub3 = subplot(3,1,3);
    plot(fh.sub3, Sig2)
    hold(fh.sub3, 'on');
    for i = 1:length(idx)
        plot(fh.sub3, (1:len_Sig1)'-lags(idx(i))+1,Sig1,'k')
    end
    plot(fh.sub3, (1:len_Sig1)'-lags(idx_max)+1,Sig1,'r')
    hold off

    title(fh.sub3, 'shifted signal(s)');
    legend(fh.sub3, {'Signal 2', 'shifted signal(s)'});% red signal: highest correlation value
end
end % -- EoF -- %