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
DR = 20;

out_beam = functional_beamforming(simulation,microphones,...
    'distance',distance_from_array,'freq',freq_to_process,...
    'frame_size',0.1,'size',2,'nu_exp',10);

%%
position_data = find_sources_on_image(out_beam, 'freq',freq_to_process, 'treshold',5,'interp',0.01,'show',0);
%%
figure()
out_beam.plot('freq',freq_to_process,'DR',DR)
xlabel('x (m)')
ylabel('y (m)')
title('Imagem acústica para a frequência de 3000 Hz')
%% Plotando a imagem acústica
%%%% Faixa dinâmica para o plot
DR = 10;

%%%% Frequência para o plot
freq_to_plot = 3000;

figure()
out_beam.plot('freq',freq_to_plot,'DR',DR)
hold on 
plot(position_data.x, position_data.y,'gs',...
    'LineWidth',2,...
    'MarkerSize',10,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','white')
legend('Imagem','Posição das fontes sonoras','location','southeast')
colorbar
xlabel('x (m)')
ylabel('y (m)')
title('Imagem acústica para a frequência de 3000 Hz')
%%