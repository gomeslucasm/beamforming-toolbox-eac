function varargout = functional_beamforming...
    (audio,array,varargin)
%%
Result = audio;
Array = array;
required_args = ["distance";"freq";];
default_args = containers.Map({'nu','diag_zero','frame_size','size'},...
    {1,false, 0.3, 2});
required_inputs = parse_required_args(required_args,varargin);
default_inputs = parse_default_args(default_args,varargin);
%%
if isscalar(required_inputs('freq'))
    fq = [required_inputs('freq')];
else
    fq = required_inputs('freq');
end
nu_exp = default_inputs('nu');
diag_zero = default_inputs('diag_zero');
distance_from_array = required_inputs('distance');
%%
larg = default_inputs('size');
frame_size = default_inputs('frame_size');
out_focus = FocusPoints(larg,frame_size);
Fs = Result.Fs;
%%
mic_pos = struct();
mic_pos.x = Array.position('x');
mic_pos.y = Array.position('y');
mic_pos.z = Array.position('z');
% Ajustando o vetor dos microfones
z = size(mic_pos.x); 
if z(2)>z(1)
mic_pos.x = mic_pos.x'; 
end
z = size(mic_pos.y); 
if z(2)>z(1)
mic_pos.y= mic_pos.y'; 
end
n_mic = length(mic_pos.x);
%% Processando beamforming
audio = Result.time_data(:,:);
NFFT = length(Result.time_data(1,:));

C = CrossSpectralMatrixBeamF(audio,fq,Fs,NFFT,diag_zero);

c0 = Result.c0;

%%%%%%%%% GRID %%

out_focus_data = out_focus;
out_focus = struct();
out_focus.x = out_focus_data('x');
out_focus.y = out_focus_data('y');
out_focus.x_mesh = out_focus_data('x_mesh');
out_focus.y_mesh = out_focus_data('y_mesh');

%%%%%%%%% Processing %%

for n_f=1:1:length(out_focus.x)
    for n_freq = 1:1:length(fq)
        G = zeros(n_mic,1);
        R = sqrt((mic_pos.x(:)-out_focus.x(n_f)).^2 + ...
                (mic_pos.y(:)-out_focus.y(n_f)).^2 + distance_from_array^2 );
        G = -exp(-2*pi*1i*fq(n_freq).*R/c0);
        G = G./(4*pi*R);
        W = (G/norm(G)^2);
        if nu_exp>1
            %%%% ref for amplitude when nu_exp > 1
            out_beam_ref(n_f,n_freq) = (W'*(C{n_freq})*W);
        end
        [V,D] = eig(C{n_freq});
        out_beam_func(n_f,n_freq) = ...
            ((W'*(V*(D^(1/nu_exp))*V')*W)^(nu_exp));
    end
end

%%%% adjusting ref if nu exponential > 1
if nu_exp>1
    for i=1:1:length(fq)
        max_val = max(out_beam_ref(:,i));
        ref(i) = max_val/max(out_beam_func(:,i));
    end
else
    ref = ones(1,length(fq));
end

k=0;
for n_x =1:1:length(out_focus.x_mesh)
    for n_y = 1:1:length(out_focus.y_mesh)
        k=k+1;
        f_conc(n_y,n_x,:) = out_beam_func(k,:).*ref;
    end
end
%%
if nargout>0
    data = BeamformingFreqResult('data',f_conc,'vector',fq);
    grid  = containers.Map({'x','y', 'x_mesh', 'y_mesh'},...
        {out_focus.x, out_focus.y_mesh, out_focus.x_mesh,out_focus.y_mesh});
    out = BeamformingResult('data',data,'grid',grid,'Fs',Result.Fs);
    varargout{1} = out;
end
end

