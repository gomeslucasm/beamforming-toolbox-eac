clear all; close all;
%% Carregando os dados da medição

%%%% Pasta aonde estão os dados de medição
data_path = 'Measure Data';

%%%% Carregando posições dos mics no array
M = MicArray('load',...
    'Measure data/coordenadas_espiral.txt','H',1.2);

%%%% Carregando os dados dos mics
load('Measure data/Espiral_2_Fonte_50cm.mat');


%%%% O nome da variável do .mat é sinal e é um objeto itaAudio
measure_data = SAudio('data',sinal.time.','Fs',sinal.samplingRate);

%%%% Invertendo as posições no eixo X
M.invert_mic_position('x') 

%%%% Plotando o array
%M.plot()

%% Parâmetros para o processamento da imagem acústica

%%%% Distância do plano de medição ao array (m)
distance_from_array = 2;   

%%%% Frequência para o processamento (Hz)
freq_to_process = [1000,2000,3000];

%%%% Exponencial (-)
nu_exp = 1; 

%%%% Tamanho da imagem a ser gerada (size x size) (m)
size_of_image = 2;  

% Discretização da imagem (m)
discretization = .05;    

%% Processando os dados

out_beam = conventional_freq_beamforming(measure_data,M,...
    'distance',distance_from_array,'freq',freq_to_process,...
    'frame_size',0.05,'size',2);

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
%% Plotando a imagem acústica _ foto
%%%% Faixa dinâmica para o plot
DR = 10;

%%%% Frequência para o plot
freq_to_plot = 3000;

%%%% Tamanho da figura
figure_length = 2.4;

%%%% Carregando a imagem
img = ImageToPlot('Measure data/2metros_50cm.jpg','figure_length',figure_length); 


figure()
out_beam.plot('freq',freq_to_plot,'DR',DR)
colorbar
hold on 
img.plot('alpha',.4);
xlabel('x (m)')
ylabel('y (m)')
%%
