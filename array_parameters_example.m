clear all; close all;
%% Gerando o array para a simulação
microphones = MicArray;
microphones.GenerateArray('circle','H',0)
% microphones.plot()
frequency = 3000;
%%
array_response = array_pattern_response(microphones, frequency, 5, [[-1,1];[-1,1]], 0.05);
%%
figure()
array_response.plot('freq',3000)
colorbar
xlabel('x (m)')
ylabel('y (m)')
a = colorbar;
a.Label.String = 'Amplitude (dB ref.:1e-5)';
title(['Resposta do array - Frequência = ' num2str(frequency) ' Hz'])
figure()
array_response.plot_3D('freq',3000,'DR',20)
colorbar
xlabel('x (m)')
ylabel('y (m)')
a = colorbar;
a.Label.String = 'Amplitude (dB ref.:1e-5)';
title(['Resposta do array - Frequência = ' num2str(frequency) ' Hz'])
%%
dynamic_range = array_dynamic_range(array_response,'plot_peaks',true);
dynamic_range
%%
beam_width = array_beam_width(array_response);
beam_width
%%
fprintf('\n')
fprintf(['\nFaixa dinâmica = ' num2str(dynamic_range) ' dB\n'])
fprintf(['\nBeamwidth = ' num2str(beam_width) ' metros\n'])
%%