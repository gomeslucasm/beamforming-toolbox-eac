function  [BWmtx, BWf] = BWevalPSF(PSF,ScaleFactor,mirror,errmax,PkSel,silent)
% Estimate the Beamwidth from a beamforming PSF
%
%   Prof. William D'andrea Fonseca, Dr. Eng. - Acoustical Engineering
%
%   Last change: 13/06/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function input parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1 || nargin < 2
  error('Two inputs are required!');
end
if nargin < 3
  mirror = 0; Unt = 10;
  errmax = 0.081; PkSel = 0.0060; silent=1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Test input
% close all
% PSF = mtx; % mirror = 0;
% ScaleFactor = 4;

%   A1 = Mbin{1,2}(1:180,1:181);
%   A2 = Mbin{1,2}(181:360,1:181); 
%   % Ajust table and Normalise  
%   B = [A2; A1]; B = B/max(max(B));
%% Expand matrix to better find the points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ZI,~,~] = mtxexpand(3,PSF,1,ScaleFactor); PSF = ZI;
% pcolor(ZI); shading interp; colormap(jet); colorbar;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Is there a MIRROR lobe ? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if mirror ==1 
 ZI(:,round(size(ZI,2)/2 + 1):end) = []; %% Just use the left side of the mtx
 Unt = 5;                                %% Units away from the border
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Process %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constants
   BW3db = 1/sqrt(2) ; % Value for 3dB down
   % Max error for a value close to BW3db
%    errmax = 0.081;
   % Peak selection factor
%    PkSel = 0.0060;
   % Pre-allocation
   BW  = zeros(size(ZI,1),size(ZI,2));
   BWw = zeros(size(ZI,1),3);   
%% Evaluate Matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   % First create a BW matrix with zeros and ones
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
   for row=1:size(ZI,1)
   A = ZI(row,:); % One line at time
   % Find peak position and split in left and right side
   [PkLoc, PkMag] = peakfinder(A, PkSel, 0, 1); 
   % Only enter the estimation if there is a value greater than (BW3db-errmax*0.080)
   if max(PkMag)>=(BW3db-errmax*0.080)
   Pk = find(PkMag==max(PkMag));
   Pk = PkLoc(Pk);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
   % Left side
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   err = 0.001;
   A = ZI(row,1:Pk);      % Assign left side
   B = abs(A - BW3db);    % Subtract BW3db
   [~,c] = find(B<=err);  % Find in B the value(s) close to ZERO and less than "err"
   while (isempty(c)==1 && err<=errmax)   % If no values are found ("c" is empty) raise the "err" up to "errmax"
       err = err + 0.001;                  % If no value is found until "errmax" assign ZERO
       [~,c] = find(B<=err);                 
   end
   if ~isempty(c); c = c(end);  end   % Use just the (ONE) value closest to the Pk (in this case the last)
   if (err<=errmax && ~isempty(c))    % Assign ONE if the value is found
      BW(row,c) = 1;      
      BWw(row,1) = size(A,2)-c(end); 
%    elseif ~isempty(c)                  % Assign ZERO if the value is NOT found
%       BW(row,c) = 0; BWw(row,1) = 0;   % Just in case
   end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
   % Right side
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   err = 0.001;
   A = ZI(row,Pk+1:end);
   B = abs(A - BW3db);
   [~,c] = find(B<=err);
   while (isempty(c)==1 && err<=errmax)
       err = err + 0.001;
       [~,c] = find(B<=err);
   end
   if ~isempty(c); c = c(1); end % Use just the (ONE) value closest to the Pk (in this case the first)
   if (err<=errmax && ~isempty(c))
      BW(row,c+Pk) = 1;  BWw(row,2) = c(1);
%    elseif ~isempty(c)  
%       BW(row,c+Pk) = 0;  BWw(row,2) = 0;
   end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
  % One line estimation
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        BWw(row,3) = (BWw(row,1)+BWw(row,2))/ScaleFactor;
        if row == round(size(ZI,1)/2 + 1)
           BWf.OneRow =  BWw(row,3);
        end 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   end % If there is no value higher than BW3db then go to the next line
   end % Go to the next line

% figure; imagesc(BW);
% surf(BW,'linestyle','none');
% pcolor(PSF); shading interp; colormap(jet);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
  % Calculate the size of BW
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   % Find the mainlobe position %%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       [Pkr, Pkc] = find(PSF==max(max(PSF)));
       if size(Pkc,1)>1 %% If more than one cell contains the max
          Pkc = Pkc(round(size(Pkc,2)/2));
       end 
       if size(Pkr,1)>1 %% If more than one cell contains the max
          Pkr = Pkr(round(size(Pkr,2)/2));
       end
       PkPos = [Pkr Pkc-2];  % [x y] mainlobe position
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do the calculation if the angles are at leat 10 units away from the border %%%%%%%%%%%%   
%%% Unt = 10, means units away from the border
if (((Pkr)>Unt*ScaleFactor && (Pkc)>Unt*ScaleFactor)...
&& ((size(PSF,1)-Pkr)>Unt && (size(PSF,2)-Pkc)>Unt))
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   % Line scan - Phi %%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   % Look for the peak at PkPos(1), if not found go to the next line
   % Right side %%%%%%%%%%%%%%%%%%%%%
   linha = PkPos(1);  PkLoc = []; % One line at time
   while (isempty(PkLoc) && linha<=size(BW,1))  % Do while PkLoc=[] (no localization)
                                                % and until the max matrix size
    [PkLoc, PkMag] = peakfinder(BW(linha,PkPos(2):end), PkSel, 0, 1);
    linha = linha + 1;
   end
   if (~isempty(PkLoc))            % Assign the localization
    Ld = [PkLoc(1) PkMag(1)];      else
    Ld = [0 0];                    end
   % Left side %%%%%%%%%%%%%%%%%%%%%%
   linha = PkPos(1);  PkLoc = [];
   while (isempty(PkLoc) && linha<=size(BW,1))
    [PkLoc, PkMag] = peakfinder(BW(linha,1:PkPos(2)), PkSel, 0, 1);
    linha = linha + 1;
   end
   if (~isempty(PkLoc))            % Assign the localization
    Le = [PkLoc(end) PkMag(end)];  else
    Le = [0 0];                    end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Rows RIGHT
    BWf.Ld = Ld(1,1)/ScaleFactor;
   % Rows LEFT
    BWf.Le = (PkPos(2) - Le(1,1))/ScaleFactor;   
   % Store row values !
    BWf.bwL =  (BWf.Le+BWf.Ld);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   % Column scan - Theta %%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   % Look for the peak at PkPos(1), if not found go to the next line
   % Down side %%%%%%%%%%%%%%%%%%%%%
   linha = PkPos(2);  PkLoc = [];
   while (isempty(PkLoc) && linha<=size(BW,2))  
    [PkLoc, PkMag] = peakfinder(BW(PkPos(1):end,linha), PkSel, 0, 1);
    linha = linha + 1;
   end
   if (~isempty(PkLoc))
    Cd = [PkLoc(1) PkMag(1)];     else
    Cd = [0 0];                   end
   % Up side %%%%%%%%%%%%%%%%%%%%%
   linha = PkPos(2);  PkLoc = [];
   while (isempty(PkLoc) && linha<=size(BW,2))   
   [PkLoc, PkMag] = peakfinder(BW(1:PkPos(1),linha), PkSel, 0, 1);
    linha = linha + 1;
   end   
   if (~isempty(PkLoc))
    Cu = [PkLoc(end) PkMag(end)]; else
    Cu = [0 0];                   end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Columns DOWN
    BWf.Cd = Cd(1,1)/ScaleFactor;
   % Columns UP
    BWf.Cu = (PkPos(1) - Cu(1,1))/ScaleFactor;   
   % Store column values !
   BWf.bwC = (BWf.Cu+BWf.Cd);
else % If the mainlobe is close to the border somtimes 
     % it is not possible to calculate 3dB down
   BWf.bwC = NaN;
   BWf.bwL = NaN;
   BWf.OneRow = NaN;
   if silent~=1
    disp([ num2str(PkPos) ' peak position... the PEAK must be at least 10 units away from the borders so I can calculate the BW.'])
   end
end
   
if nargout >= 2
    BWmtx = BW;
end

% pcolor(BWmtx); shading interp; colormap(jet); colorbar;

end % end BWevalPSF