clear all; close all;
%% Criando as fontes sonoras

distance_from_array = 5;

S1 = Source('x',0.5,'y',1.7,'z',distance_from_array,'Freq',3000,'Amp',40);

S2 = Source('x',-0.5,'y',1.2,'z',distance_from_array,'Freq',3000,'Amp',38);

%% Gerando o array para a simula��o
    
microphones = MicArray;
microphones.GenerateArray('spiral','H',1.2)

% M.plot
%% Simulando medi��o das fontes sonoras 

%%% Selecionando as fontes
sources = {S1, S2};

%%% Rodando a simula��o
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
title('Imagem ac�stica para a frequ�ncia de 3000 Hz')
%% Plotando a imagem ac�stica
%%%% Faixa din�mica para o plot
DR = 10;

%%%% Frequ�ncia para o plot
freq_to_plot = 3000;

figure()
out_beam.plot('freq',freq_to_plot,'DR',DR)
hold on 
plot(position_data.x, position_data.y,'gs',...
    'LineWidth',2,...
    'MarkerSize',10,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','white')
legend('Imagem','Posi��o das fontes sonoras','location','southeast')
colorbar
xlabel('x (m)')
ylabel('y (m)')
title('Imagem ac�stica para a frequ�ncia de 3000 Hz')
%%