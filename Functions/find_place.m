function [id, outputValue, c] = find_place(input,vector,Vplus,Vminus)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função para buscar uma posição em um vetor
%
% Desenvolvido por
%    Prof. William D'Andrea Fonseca, Dr. Eng.
%
% vector = vetor de entrada com a série de dados
% input  = valor a ser buscado
%          
% Vplus e Vminus = são ajustes para ter uma margem na busca pelos valores
%
% Atualização: 15/07/2018
%
% Exemplo:
% id = find_place(2000,freqs,10,10);
% id = find_place(2000,freqs);
% [id, out] = find_place(2000,freqs,10,10);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check inputs
if nargin<2; error('Verifique as entradas da função'); end
if nargin<3; Vplus=10; Vminus=10; end

%% Procura frequências e ajusta vetor
    c = find(vector>=input-Vminus & vector<=input+Vplus);
    dif  = abs(vector-input); [~, id] = min(dif);
    if length(id)==1
      outputValue = vector(id);
    end
if abs(outputValue-input) == 0
   %%% Valor exato encontrado
else
   disp(['O valor buscado não existe no vetor, o valor mais próximo é ' num2str(vector(id)) '.']) 
end
end