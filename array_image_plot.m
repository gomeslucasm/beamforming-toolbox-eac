clear all; close all;
%% Gerando o array para a simulação
microphones = MicArray;
microphones.GenerateArray('spiral','H',0)
% microphones.plot()
frequency = 3000;
origin = microphones.Origin();
%%
array_response = array_pattern_response(microphones, frequency, 5, [[-2,2];[-2,2]], 0.05);
%%
figure()
array_response.plot('freq',3000)
hold on
microphones.plot()
hold on
scatter(origin('x'),origin('y'),'s','MarkerEdgeColor','magenta','MarkerFaceColor','white',...
                          'LineWidth',1.5)
legend('Resposta do array','Posição dos microfones','Fonte sonora')
xlabel('x (m)')
ylabel('y (m)')
title('Resposta do array - Frequência = 3000 Hz - Distância = 5 metros')
export_fig('comp_array_image_source','-pdf','-transparent')
%%






%%