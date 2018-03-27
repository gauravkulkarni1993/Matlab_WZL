function [m, n, Sig_cor] = LinearDrift(Sig, RefineResult, DoPlot)
% corrects linear drift in signal
% 
% REQUIRES REVISION!!!!
%
% --- Syntax:
% [m, n] = determineDrift(Sig)
% [m, n] = determineDrift(Sig,RefineResult)
% [m, n, Sig_corr] = determineDrift(Sig)
% 
% --- Description:
% [m, n] = determineDrift(Sig)  fits line coefficients m, n (y = m*x +n) to 
%       the idle signal. 
% [m, n] = determineDrift(Sig,RefineResult) logical specifying if the
%       estimation should be refined ignoring outliers. Default: false
% [m, n, Sig_corr] = determineDrift(Sig) returns the corrected signal
% 
% ------------------------------------------------ Max Schwenzer 25.10.2016

% FIXME: check input
assert(size(Sig,1) >= size(Sig,2)) % Row-Vector
assert(size(Sig,2) == 1) % Vector
% TODO: speed up calculation by downsampling?

%% determine idle signal:
% Sz = ceil(length(Sig)/500);
% % strong smoothing:
% Sig_flt = smooth(Sig, Sz );
% t = (0:length(Sig)-1)';
% 
% Sig_dif = diff(Sig_flt);
% idx_std = smooth(abs(Sig_dif),Sz) < std(Sig_dif);
% 
% Sig_std = Sig(idx_std);
% t_std = t(idx_std);
% 
% % ignore outliers:
% idx_outl = abs(Sig_std - mean(Sig_std)) < 1.5*std(abs(Sig_std));
% Sig_cut  = Sig_std(idx_outl);
% t_cut    = t_std(idx_outl);

[~,~,SecIDX] = IdleTime(Sig);

Sig_cut = Sig(SecIDX);
t       = (0:length(Sig)-1)';
t_cut   = t(SecIDX);



%% fit line:
% determine initial guess:
Num = ceil(length(Sig_cut) / 10);
y1 = median(Sig_cut(1:Num));
y2 = median(Sig_cut(end-Num:end));
% estimate gradient:
m = (y2-y1)/(t_cut(end)-t_cut(1));
n = m*t_cut(end) -y2;

[mn,fval] = fminsearch(@(mn) fitLine(t_cut,Sig_cut,mn),double([m n]));

% refine result:
if nargin > 1 && RefineResult
    y_ub = mn(1)*t_cut +mn(2);
    y_lb = y_ub - 3*std(Sig_cut);
    y_ub = y_ub + 3*std(Sig_cut);
    % plot(t_cut,[Sig_cut,y_ub,y_lb]) % DEBUGGING

    SecIDX_ref  = Sig_cut < y_ub & Sig_cut > y_lb;
    Sig_cut     = Sig_cut(SecIDX_ref);
    t_cut       = t_cut(SecIDX_ref);
    % hold on; plot(t_cut,Sig_cut)

    [mn,fval2] = fminsearch(@(mn) fitLine(t_cut,Sig_cut,mn),double([m n]));
end

%% output
m = mn(1);
n = mn(2);

if nargout > 2 || DoPlot
    Lg = true(length(Sig),1);
    Lg(SecIDX) = false;
    Sig_cor = Sig;
    Sig_cor(Lg) = Sig(Lg)-m.*(t(Lg)- t(find(Lg,1)))+n;
end

%% plot
if nargin > 2 && DoPlot
    fh = struct();
    fh.fig = figure;
    fh.sub1 = subplot(2,1,1);
    fh.sub2 = subplot(2,1,2);
    
    Sig_flt = smooth(Sig,ceil(length(Sig)/500));
    plot(fh.sub1, t,[Sig,Sig_flt], t_cut,Sig_cut)
    xlabel(fh.sub1, 'Sample')
    ylabel(fh.sub1, 'Signal')
    legend(fh.sub1, {'Original Signal', 'Smoothed Signal','Idle Signal'})
    
    plot(fh.sub2, t,Sig_cor)
    xlabel(fh.sub2, 'sample')
    ylabel(fh.sub2, 'Signal')
    legend(fh.sub2, {'Corrected Signal'})
end
end



%% LOCAL FUNCTION
function [err] = fitLine(x,y,mn)

y_sim = mn(1).*x + mn(2);

err = sum( (y - y_sim).^2 );

end