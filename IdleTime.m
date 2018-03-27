function [SecIdle, SigIdle, cut] = IdleTime(Sig,DoPlot)
% determines the start and end index of idle time in the signal
%
% --- Syntax:
% [SecIdle] = IdleTime(Sig)
% [SecIdle, SigIdle] = IdleTime(Sig)
% [SecIdle, SigIdle, cut] = IdleTime(Sig)
%
% --- Description:
% [SecIdle] = IdleTime(Sig) determines the start end end indices of the
%       idle time of a signal based on the change in amplitude and standard
%       deviation.
% [SecIdle, SigIdle] = IdleTime(Sig)    returns also the cropped idle
%       signal.
% [SecIdle, SigIdle, cut] = IdleTime(Sig)   returns a logical vector of the
%       same size as the input signal, indicating whether the corresponding
%       signal point belongs to the idle time or not.
%
% ------------------------------------------------ Max Schwenzer 26.10.2016

% What characterizes idle time?
% low signal value (relative)
% low deviation (relative)
% low standard deviation

% What characterizes signals (compared to idle signals)?
% high amplitudes

% TODO: add optional edge frequency for TP filter!


% FIXME: check input
assert(size(Sig,1) >= size(Sig,2)) % Row-Vector
assert(size(Sig,2) == 1) % Vector
% TODO: speed up calculation by downsampling?


%% 
Sz = ceil(length(Sig)/500);
%% potential signal time:
Sig_flt = smooth(Sig, Sz );
Sig_mStd = moving(@(x) mean(x)+3*std(x),Sig,Sz*15,Sz);

dSig = abs(Sig_flt - Sig_mStd);
% normalize:
dSig = dSig./range(dSig);

% Threshold:
TH_Sig = 0.15;
cut_Sig = dSig < TH_Sig;
% dSig_flt = smooth(dSig,Sz*100);

t = (0:length(Sig)-1)';
% plot(  fh.sub2, t,[dSig], t(cut),dSig(cut))

%% potential idle time:

Sig_std = moving(@std,Sig,Sz,ceil(Sz/3));

% --- Threshold (ignore outlier):
% Note: only smaller, since std is always positive, and a low std-value is
%       low in idle time.
TH_std = mean( Sig_std(Sig_std < mean(Sig_std)+2.0*std(Sig_std)) );
% cut
cut_std = Sig_std < TH_std;

% --- refine result:
% if a Gaussian distribution is assumed 99.9% of all values are < mean+3*std 
TH_std = mean( Sig_std(cut_std) ) +3.0*std( Sig_std(cut_std) );
% cut
cut_std = Sig_std < TH_std;


%% determine idle signal (output):
cut = cut_Sig & cut_std;

SecIdle = makeSection(cut,ceil(Sz/100),ceil(Sz/50));


if nargout > 1
    SigIdle = Sig(cut);
end

%% plot % DEBUGGING
if nargin > 1 && DoPlot
    fh = struct();
    fh.fig = figure;
    fh.sub1 = subplot(3,1,1);
    fh.sub2 = subplot(3,1,2);
    fh.sub3 = subplot(3,1,3);
    
    plot(  fh.sub1, t,[Sig,Sig_flt], t(cut),Sig(cut))
    xlabel(fh.sub1, 'Sample')
    ylabel(fh.sub1, 'Signal')
    legend(fh.sub1, {'Original Signal', 'Smoothed Signal','Idle Signal'})
    
    plot(  fh.sub2, t,[dSig], [t(1);t(end)],[TH_Sig;TH_Sig])
    xlabel(fh.sub2, 'Sample')
    ylabel(fh.sub2, 'Delta Signal / -')
    legend(fh.sub2, {'Smoothed Sig - moving Std(Sig)' ['Threshold = ',num2str(TH_Sig)]})

    plot(  fh.sub3, t,Sig_std, t(cut_std),Sig_std(cut_std))
    xlabel(fh.sub3, 'Sample')
    ylabel(fh.sub3, 'Std Signal / -')
    legend(fh.sub3, {'Std Signal MAV' 'Std Idle Signal MAV'})
    
    linkaxes([fh.sub1 fh.sub2 fh.sub3])
end

end


