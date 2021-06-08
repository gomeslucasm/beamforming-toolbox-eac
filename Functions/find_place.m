function [id, outputValue, c] = find_place(input,vector,Vplus,Vminus)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fun��o para buscar uma posi��o em um vetor
%
% Desenvolvido por
%    Prof. William D'Andrea Fonseca, Dr. Eng.
%
% vector = vetor de entrada com a s�rie de dados
% input  = valor a ser buscado
%          
% Vplus e Vminus = s�o ajustes para ter uma margem na busca pelos valores
%
% Atualiza��o: 15/07/2018
%
% Exemplo:
% id = find_place(2000,freqs,10,10);
% id = find_place(2000,freqs);
% [id, out] = find_place(2000,freqs,10,10);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check inputs
if nargin<2; error('Verifique as entradas da fun��o'); end
if nargin<3; Vplus=10; Vminus=10; end

%% Procura frequ�ncias e ajusta vetor
    c = find(vector>=input-Vminus & vector<=input+Vplus);
    dif  = abs(vector-input); [~, id] = min(dif);
    if length(id)==1
      outputValue = vector(id);
    end
if abs(outputValue-input) == 0
   %%% Valor exato encontrado
else
   disp(['O valor buscado n�o existe no vetor, o valor mais pr�ximo � ' num2str(vector(id)) '.']) 
end
end