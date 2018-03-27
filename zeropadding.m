function Sig_pad = zeropadding(Sig,SzTarget)
% fills signal with zeros to size SzTarget
% 
% --- Syntax:
% Sig_pad = zeropadding(Sig,SzTarget)

% 
% --- Description:
% Sig_pad = zeropadding(Sig,SzTarget) padds input 'Sig' with zeros so that
%       it has the desired size 'SzTarget'.
% 
% ------------------------------------------------ Max Schwenzer 12.07.2017



% allocate output matrix
if any(size(Sig) == 1) && any(size(SzTarget) == 1)
    % allocate vector
    Sig_pad = zeros(SzTarget,1);
else % allocate matrix
    Sig_pad = zeros(SzTarget);
end
% add input matrix
Sig_pad(1:size(Sig,1),1:size(Sig,2)) = Sig;

end

