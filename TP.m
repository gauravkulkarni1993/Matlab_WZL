function [sig_flt,a,b] = TP(sig,varargin)
% performs a 5th order (butterworth) low-pass filter 
%
% --- Syntax:
% sig_flt = TP(sig,f_nrm)
% sig_flt = TP(sig,f_interference, f_sampling)
% sig_flt = TP(sig,v_c,D,z,f_sampling)
% sig_flt = TP(...,'soft')
% [sig_flt,a,b] = TP(...)
% 
% --- Description:
% sig_flt = TP(sig,f_nrm) applies a low-pass filter witht the normalized
%       cut-off frequency f_nrm [0, 1].
% sig_flt = TP(sig,f_interference, f_sampling) calculates the normalized 
%       cut-off frequency by the input frequencies. The unit of both input 
%       frequencies must be the same.
% sig_flt = TP(sig,v_c,D,z,f_sampling) sets the normalized cut-off
%       frequency to the tooth passing frequency, which is determined by
%       the input. The input units are assumed as follows: v_c / m/min, 
%       D / mm, z / -, f_samling / Hz
% sig_flt = TP(...,'soft') if this flag is set, the cut-off frequency is
%       increased by 30%.
% [sig_flt,a,b] = TP(...) returns also the filter coefficients a and b.
%
% 
% ------------------------------------------------ Max Schwenzer 11.08.2017



%%
if any( strcmpi(varargin,'soft') )
    idx = find(strcmpi(varargin,'soft'));
    
    lg = true(size(varargin));
    lg(idx) = false;
    if length(varargin) > idx && isnumeric(varargin{idx+1})
        SOFT = varargin{idx+1};
        lg(idx+1) = false;
    else
        SOFT = 1.3;
    end
    varargin = varargin( lg );
else
    SOFT = 1;
end

switch length(varargin)
    case 1
        f_cut_nrm = varargin{1};
    case 2
        f_intfr = varargin{1};
        f_sampling = varargin{2};
        
        % edge frequency:
        f_cut_nrm = f_intfr*SOFT / (f_sampling/2);
    case 4
        v_c = varargin{1};
        D   = varargin{2};
        z   = varargin{3};
        f_sampling = varargin{4};
        
        % calculate interference frequency:
        n = (v_c/60) / (pi * D*1e-3);
        f_intfr = n *z;
        % edge frequency:
        f_cut_nrm = f_intfr*SOFT / (f_sampling/2); % normalized cutoff frequency
    otherwise
        error('TP:NumberOfInputs','Wrong number of input arguemnts!')
end


% determine filter coefficients:
[b,a] = butter(5, f_cut_nrm); 
% apply filter
sig_flt = filter(b,a, sig);


if (sum((sig-sig_flt)>1e10) / length(sig) ) > .01 % more than 1% of the data difference is close to Inf
     warning('TP:result:high',['Low-pass filter seems to have caused damage to your signal. ',...
         'A possible reason could be that the normalized cut-off frequency very low.']);
end


end