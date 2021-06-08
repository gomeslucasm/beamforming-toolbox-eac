clear all; close all;
%% Criando as fontes sonoras

distance_from_array = 5;

S1 = Source('x',0.5,'y',1.7,'z',distance_from_array,'Freq',3000,'Amp',40);

S2 = Source('x',-0.5,'y',1.2,'z',distance_from_array,'Freq',3000,'Amp',38);

%% Gerando o array para a simulação
    
microphones = MicArray;
microphones.GenerateArray('spiral','H',1.2)

% M.plot
%% Simulando medição das fontes sonoras 

%%% Selecionando as fontes
sources = {S1, S2};

%%% Rodando a simulação
simulation = SimulateMeasurementSS(sources,microphones,10,44100);
%% Processando os dados com beamfomrming convencional

freq_to_process = 3000;

out_beam = conventional_freq_beamforming(simulation,microphones,...
    'distance',distance_from_array,'freq',freq_to_process,...
    'frame_size',0.1,'size',2);

%% Plotando a imagem acústica
%%%% Faixa dinâmica para o plot
DR = 10;

%%%% Frequência para o plot
freq_to_plot = 3000;

figure()
out_beam.plot('freq',freq_to_plot,'DR',DR)
colorbar
xlabel('x (m)')
ylabel('y (m)')
%%