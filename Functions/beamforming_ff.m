 function [Map_1, scan_grid, BeamInput, G]=beamforming_ff(geo,f_BF,mode,G,c0,l,le,fz,P1,dBref,parallel)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function developed to:
%  calculate Conventional Beamforming (CB) for free-field steering vector
%  calculate CB up to three input pressure vectors
%  calculate CB for an input steering vector
%  calculate the CB-PSF for a give array
%  calculate the free-field steering vector
%  calculate scannig grid data
%
% INputs:
%  geo - array's geometry, a three column vector with x, y and z.
%
%  f_BF - frequency vector
%
%  mode - 1: CB, free-field, PSF (P1 is not needed)
%       1.1: CB, just calculate the steering vector (no beamforming is carried out)
%       1.5: CB, input steering vector, PSF (P1 is not needed)
%       1.6: CB, input steering vector, monopole off-center (spec. in P1)
%         2: CB, free-field, uses input P1
%         3: CB, input steering vector, uses inputs P1
%  If mode is [mode 0] the silent mode is turned off.
%
%  G - steering vector:
%    for G = 0 the internal code calculates the free-field steering vector
%    for an external G must be in the format 
%        G{X-scan_grid,Y-scan_grid}(P-mics,frequencies)
%
%  c0 - speed of sound
%
%  l - span of the solid angle of vision in meters. Scanning grid in x and
%  y direction (the scanning grid is the plane of potential sources)
%
%  le - increment on the scannig grid (this implementation only allows 
%  square maps)
%
%  fz - arrays's distance from the scanning grid
%
%  P1 is the input pressures (measurements) to process the CB.
%  P1 format is (P-mics,frequencies)
%  If P1 is of size two like [x y] in mode 1.6 the monopole is put in that
%  position on x and y axis.
%
% dBref = dB reference, for example, 1 or 20E-6.
%
% parallel = 1 for parallel computing and 0 for serial.
%
% OUTputs:
%
%  Map_1 - CB for P1 input
% 
%  scan_grid - data of the scan grid in the focal plane
%
%  BeamInput - metadata of the post-processing
%
%  G - free-field steering vector (if you wanna save and spare time on the 
%  next run)
%
% Demo mode
% Just use 'data_demo' in geo
%
% Example:
% [BeamfMap, scan_grid] = beamforming_ff(array,f,[result 0],0,c0,space,mesh,dist,P,1);
% 
%
% Developed by professor William D'Andrea Fonseca, Dr. Eng.
%                                   Acoustical Engineering
%
% Last change: 15/07/2018
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function programming %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear all; close all;
% nargin = 1;
%% Input and error checking %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<1
  error('Oh Lord.... have a look to the inputs needed.')
elseif nargin==1 && strcmp(geo,'data_demo')
  disp('  It looks like you want a demo run... right? I will use a spiral array.');
 % Spriral array
 x = [0.1 0.05 0 -0.05 -0.1 -0.05 0 0.05 0.15 -0.05 -0.25 -0.3 -0.15 0.05 0.25 0.3 0.1 -0.2 -0.4 -0.35 -0.1 0.2 0.4 0.35 0.05 -0.35 -0.5 -0.4 -0.05 0.35 0.5 0.4];
 y = [0 0.05 0.1 0.05 0 -0.05 -0.1 -0.05 0.25 0.3 0.15 -0.05 -0.25 -0.3 -0.15 0.05 0.4 0.35 0.1 -0.2 -0.4 -0.35 -0.1 0.2 0.5 0.4 0.05 -0.35 -0.5 -0.4 -0.05 0.35];
 d1 = 0.00; z= ones(1,length(x))*(d1); geo = [x' y' z'];
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 500 1000 5000
 f_BF = [500 2000 10000]; mode = 1; G = 0; c0= 343; l=2.2; le=0.04; fz = 2.0; parallel = 0;
 % norm = [];
end

if nargin<11; parallel = 0; end

if mode(1)==2.1; mode(1)=2; end

% Silent?
if length(mode)==2; silent=mode(2); mode=mode(1);
else; silent=1; mode=mode(1);
end

% dB reference
if ~exist('dBref','var'); dBref=1; end

% Distance of the scanning grid
if isnumeric(fz)
if length(fz)>1
   disp(['For now, this implementation only considers a fixed scanning grid ' ... 
   'distance. I will use the first element of fz.']); fz = fz(1);
end
else
   error('I only accept numerical distances in meters.')
end
tStart = tic;
%% Array geometry %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = geo(:,1); y = geo(:,2); z = geo(:,3); % Array's coordinates
M = length(x); fqs = length(f_BF); 
%% Scan grid configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scan_grid.fx = -l/2:le:l/2;                      % Monopoloe on x axis coordinates
scan_grid.fy = l/2:-le:-l/2;                     % Monopoloe on y axis coordinates
scan_grid.fz = ones(1,numel(scan_grid.fx))*fz;   % Monopoloe on z axis coordinates - fixed plane
% Scan grid sizes
scan_grid.sizefx = numel(scan_grid.fx); scan_grid.sizefy = numel(scan_grid.fy); 
scan_grid.totalsize = scan_grid.sizefx*scan_grid.sizefy; 
% Scan grid mesh
[scan_grid.MeshFx, scan_grid.MeshFy] = meshgrid(scan_grid.fx, scan_grid.fy);
%%% Calculate solid angle
if exist('l','var') && exist('fz','var')
scan_grid.s_angle.rad = atan((l/2)/fz); scan_grid.s_angle.deg = rad2deg(scan_grid.s_angle.rad);
disp(['  Your solid angle of vision is ' num2str(scan_grid.s_angle.deg,'%5.2f') 'º.']);
if scan_grid.s_angle.deg>30; disp('  Angles greater than 30º may lead to aberrations on images.'); end
end
%% Monopoles on the scanning grid %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if mode == 1 || mode == 2 || mode == 1.1
G = struct;  G.p = cell(scan_grid.sizefx,scan_grid.sizefy);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if parallel == 0 %%% Serial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g = waitbar(0,'Montando vetor de direções... aguarde.');
for n=1:fqs % Calculates the free-field steering vector
    for k=1:scan_grid.sizefx  % Square steering vector
     for l=1:scan_grid.sizefy % Square steering vector
     % Distância entre a fonte (monopolo) na posição (fx,fy) e cada um dos microfones
     dfr = sqrt(((x-scan_grid.fx(k)).^2)+((y-scan_grid.fy(l)).^2)+((z-scan_grid.fz(k)).^2)); 
     % Tempo de atraso do monopolo no grid para o microfone m
     G.Delta_m{k,l}(:,n) = dfr/c0;
     % Função de Green para campo livre
     G.p{k,l}(:,n) = exp(-1j.*(2*pi*f_BF(n)).*G.Delta_m{k,l}(:,n))./dfr;  % ou G(i,:) =(exp(-1j*k0.*dfr))./(dfr); 
     end
    end
    waitbar(n/fqs,g);
end; delete(g); % monopole freq. loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif parallel == 1 %%% CPU Parallel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% FALTA ARRUMAR AINDA NÃO FUNCIONAL %%%%%%%%%%%%%%%%
    hbar = parfor_progressbar(fqs,'Montando vetor de direções... aguarde... (paralelo)');
parfor n=1:fqs % Calculates the free-field steering vector
    f_ang(n) = -1j.*(2*pi*f_BF(n)); sx=0; sy=0;
    A = cell(scan_grid.sizefx,scan_grid.sizefy); B = cell(scan_grid.sizefx,scan_grid.sizefy);
    for k=1:scan_grid.sizefx  % Square steering vector
     for l=1:scan_grid.sizefy % Square steering vector
     % Distância entre a fonte (monopolo) na posição (fx, fy) e cada um dos microfones
     dfr = sqrt(((x-scan_grid.fx(k)).^2)+((y-scan_grid.fy(l)).^2)+((z-scan_grid.fz(k)).^2)); 
%      % Tempo de atraso do monopolo no grid para o microfone m
     Delta = dfr/c0;
     B(k,l) = {Delta};
     % Função de Green para campo livre
     A(k,l) = {exp(f_ang(n).*Delta)./dfr};  % ou G(i,:) =(exp(-1j*k0.*dfr))./(dfr); 
     end
    end
     Delta_m(n) = {B};
     p(n) = {A};    
    hbar.iterate(1); 
end; close(hbar); % monopole freq. loop 
for a=1:scan_grid.sizefx
    for b=1:scan_grid.sizefx
        for f=1:fqs
        G.p{a,b}(:,f) = p{1,f}{a,b};
        G.Delta_m{a,b}(:,f) = Delta_m{1,f}{a,b};
        end
    end
end
% G.p = p; G.D = Delta_m;
% G.p = reshape(A,[scan_grid.sizefx,scan_grid.sizefy]);
end
end

if mode~=1.1
%% Calculate PSF? %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if mode == 1 || mode == 1.5 %% Calculate PSF.
  if mod(size(G.p,1),2)~=0      % Odd number
   P1 = (sqrt(2)).*G.p{floor(size(G.p,1)/2)+1,floor(size(G.p,1)/2)+1}; 
   elseif mod(size(G.p,1),2)==0 % Even number
   P1 = (sqrt(2)).*G.p{size(G.p,1)/2,size(G.p,1)/2}; 
  end

 %% Preciso terminar ainda %%%%%%%%%%%%%%%%%%%
elseif mode == 1.6 %% Put the monopole at some other point.
  if length(P1) == 2 && P1(1)<=l && P1(2)<=l
     Pos = P1; P1 = [];
  if mod(size(G.p,1),2)~=0      % Odd number
   P1 = (sqrt(2)).*G.p{floor(size(G.p,1)/2)+1,floor(size(G.p,1)/2)+1}; 
   elseif mod(size(G.p,1),2)==0 % Even number
     %%% Find nearest point
     [cx idx] = min(scan_grid.fx-Pos(1));
     [cy idy] = min(scan_grid.fy-Pos(2));
%      disp('I put the monopole in the nearest position ' '.');       
   P1 = (sqrt(2)).*G.p{size(G.p,1)/2,size(G.p,1)/2}; 
  end
  else
    error('Please put the monopole inside the range.')  
  end
end

if isempty('G') || isempty('G.p'); error('Something is wrong with Steering Vector, have a look to the selected mode.'); end
%% Conventional Beamforming %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = waitbar(0,'Calculando beamforming convencional... aguarde.');
for n=1:fqs % Frequency loop
%%% Processing... Usually free-field
if exist('P1','var') && ~isempty(P1) && size(P1,1)~=1; if n==1; Map_1 = cell(1,fqs); end
for xi=1:size(G.p,1)
   for yi=1:size(G.p,2) 
    denom = sum((abs(G.p{xi,yi}(:,n))).^2);
    a1(1) = (G.p{xi,yi}(:,n))'*(P1(:,n)); % Here ' is the Hermitian operator (complex conjugate transpose)
    a1(2) = a1(1)/denom; 
    a1(3) = 0.5*(abs(a1(2))).^2;
    Map_1{1,n}(xi,yi) = sqrt(abs(a1(3))); % For pressure output
   end
end 
Map_1{1,n} = flipud(rot90(Map_1{1,n}));
if n>10 || length(scan_grid.fx)>50
   waitbar(n/fqs,h);
end
elseif mode==3 && ~exist('P1','var')
    error('Have a look to the pressure input.')
else
    error('Something is wrong... have a look to the pressure vector.')
end % Map_1

end % END freq. loop

delete(h);

%% Option for maps %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for f=1:fqs
%%% Complete map 1 matrix     
%   Map_1{1,f}                            % ORIGINAL 
 Map_1{2,f} = max(max(Map_1{1,f}));       % Max values of original
 Map_1{3,f} = Map_1{1,f}/Map_1{2,f};      % Max values of array power response
 Map_1{4,f} = 20*log10(Map_1{3,f}/dBref); % Valor em dB ref. 
end

else
    Map_1 = []; BeamInput = [];

end % Do beamforming?

%% Metadata %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BeamInput.mode = mode; BeamInput.c0 = c0; 
BeamInput.geo = geo; BeamInput.mics = M; BeamInput.f_bf = f_BF; 
BeamInput.scan_grid = scan_grid;

%% Plots for demo mode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==1 && strcmp(geo,'data_demo')
for f=1:fqs
    figure(f); pcolor(Map_1{1,f}); shading interp; colormap(jet); colorbar;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tElapsed = toc(tStart);
if silent~=1
  disp(['Conventional Beamforming calculated for ' int2str(fqs) ' frequncies, grid size (' ...
        int2str(scan_grid.sizefx) ',' int2str(scan_grid.sizefx) '), scanning grid distance ' ...
        num2str(fz,'%5.2f') ' m, elapsed time ' num2str(tElapsed,'%6.2f') ' s.']) 
end
end % END function

%% Ainda estou ajustando
function AAA = pos_monopole(l,Pos)
  if length(P1) == 2 && Pos(1)<=l && Pos(2)<=l
  if mod(size(G.p,1),2)~=0      % Odd number
   P1 = (sqrt(2)).*G.p{floor(size(G.p,1)/2)+1,floor(size(G.p,1)/2)+1}; 
   elseif mod(size(G.p,1),2)==0 % Even number
     %%% Find nearest point
     [cx idx] = min(scan_grid.fx-Pos(1));
     [cy idy] = min(scan_grid.fy-Pos(2));
%      disp('I put the monopole in the nearest position ' '.');       
   P1 = (sqrt(2)).*G.p{size(G.p,1)/2,size(G.p,1)/2}; 
  end
  else
    error('Please put the monopole inside the range.')  
  end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOF