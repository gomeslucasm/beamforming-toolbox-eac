function  [DRpsf, DRl, DRc, DR_psf] = DRevalPSF(PSF,ScaleFactor,PkSel,dbRef)
% Estimate the Dynamic Range from a beamforming PSF
%
%   Prof. William D'andrea Fonseca, Dr. Eng. - Acoustical Engineering
%
%   Last change: 13/06/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Input and check

if nargin < 2
  ScaleFactor = 2; PkSel = 0.000040; %  PkSel = 0.0040;
end

if nargin < 3; PkSel = 0.000040; end

if nargin < 4; dbRef=20E-6; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Paref = 20*(log10(1/(20E-6)));

 [DR,~,~] = mtxexpand(4,PSF,1,1);          % make a square matrix   
 [DR,~,~] = mtxexpand(3,DR,1,ScaleFactor); % expand?
 DRl = zeros(size(DR,1),size(DR,2));
 DRc = zeros(size(DR,1),size(DR,2));
 
%  if plots==1
%   figure;  surf(DR,'LineStyle','none');
%  end
 
% Search lines
for lc=1:size(DR,1)
 [PkLoc, PkMag] = peakfinder(DR(lc,:), PkSel, 0, 1);
 DRl(lc,PkLoc) = PkMag;
end

% Search Columns
for lc=1:size(DR,2)
 [PkLoc, PkMag] = peakfinder(DR(:,lc), PkSel, 0, 1);
 DRc(PkLoc,lc) = PkMag;
end

%  if plots==1;
%  figure; contour(DRl)
%  figure; contour(DRc)
%  end

% Process values
DR_psf = sqrt(DRl.*DRc); % Element by element product
 DR = reshape(DR_psf,1,numel(DR));
 DR = sort(DR,'descend');
 DR = DR/max(DR);
 DRrel = DR(1)-DR(2);
 DRdB = 20*(log10(DR/dbRef));
 DRdB = DRdB(1)-DRdB(2); 

 DRdB_corr =  DRdB;
 DRdB_corr(isinf(DRdB)) = 10000; % High number
 
 % Store values for all freqs.
  DRpsf(1,2) = DRrel;      % relative
  DRpsf(2,2) = DRrel;      % relative, just a copy  
  DRpsf(1,1) = DRdB;       % dB
  DRpsf(2,1) = DRdB_corr;  % dB with "inf" removed

end % End DRevalPSF