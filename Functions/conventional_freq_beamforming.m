function out = conventional_freq_beamforming(....
    audio,array,varargin)
%%
    required_args = ["freq","distance"];
    required_inputs = parse_required_args(required_args,varargin);
    default_args = containers.Map(...
        {'size','frame_size'},...
        {2,0.2});
    default_inputs = parse_default_args(default_args, varargin);
    space = default_args('size');
    mesh = default_args('frame_size');
    if isscalar(required_inputs('freq'))
        f = [required_inputs('freq')];
    else
        f= required_inputs('freq');
    end
    dist = required_inputs('distance');
%%
% Inputs:
%   audio - a variable MVSAudio or itaAudio
%   array - a variable Mic Array
%   space - mesh size
%   mesh - mesh discretization
%   arg1 - a variable MVSource that contains the distance between the
%   source and the receiver or a simple value of the distance
%   f - frequencies to calculate the ouput beamforming (Optional if arg1 is a MVSource)
%   f(default) if MVSource contains the freq_data valuesthe output frequencies will
%   be the frequencies used to generate the audio of the source on the
%   simulation

% Output:
% out - Beamforming Result

%%
% out = BeamformingResult;

%%            
ita_beam_my = itaAudio(audio.time_data.',audio.Fs,'time');
[P, freq] = data_ita2CBeamf(ita_beam_my,f);
clear ita_beam_my
%%
% Beamforming convencional
Espaco = space; % Valor em metros
Malha  = mesh; % Valor em metros
result = 2;
origin = array.Origin;
Array(:,1) = array.position('x');
Array(:,2) = array.position('y') - origin('y');
Array(:,3) = zeros(length(array.position('x')),1);
[out_beam, out.Grid] = beamforming_ff(Array,f,[result 0],0,audio.c0,Espaco,Malha,dist,P,1);
out_data  = [];


for i=1:1:length(out_beam(1,:))
    out_data(:,:,i) = out_beam{1,i};
end

if nargout>0
    data = BeamformingFreqResult('data',out_data,'vector',f);
    grid  = containers.Map({'x','y', 'x_mesh', 'y_mesh'},...
        {out.Grid.MeshFx, out.Grid.MeshFy + origin('y'), ...
        out.Grid.fx , out.Grid.fy + origin('y')});
    out = BeamformingResult('data',data,'grid',grid,'Fs',audio.Fs);
    varargout{1} = out;
end

end