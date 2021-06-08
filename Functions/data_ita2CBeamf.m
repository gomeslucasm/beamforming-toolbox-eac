function [p, freqs] = data_ita2CBeamf(med,f,Vplus,Vminus)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Função para ajustar itaAudio para utilização no Beamforming Convencional
%
% Desenvolvido por
%    Prof. William D'Andrea Fonseca, Dr. Eng.
%
% med = itaAudio com a medição de beamforming
%          
% f   = vetor com frequências a serem analisadas
%
% Atualização: 15/07/2018
%
% Exemplo:
% [p, freqs] = data_ita2CBeamf(sinal,f);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check inputs
if nargin<2; error('Verifique as entradas da função'); end
if nargin<3; Vplus=10; Vminus=10; end

%% Procura frequências e ajusta vetor
p=zeros(length(f),med.dimensions); freqs = zeros(1,length(f));
OriFreqs=med.freqVector;
for n=1:length(f)
    freq = med.freqVector;
    c = find(freq>f(n)-Vminus & freq<f(n)+Vplus);
    freq = freq(c);
    temp = med.freqData(c,:);
    dif  = abs(f(n)-freq); [~, idx] = min(dif);
%     if ~isempty(idx)
       freqs(1,n) = freq(idx);
%     else
%        error(['Sorry, I cannot find such value. The max fequency is ' num2str(OriFreqs(end)) ' Hz.']) 
%     end
    p(n,:)  = temp(idx,:).';
end

p = p.';

%% Caso não encontre as frequências extas
ff   = f - freqs;
if max(abs(ff))>0
        disp('Sorry, I could not find the exact frequencies, I am sending you the nearest I have. If you need the exact ones consider adjusting the fs or time vector.')
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EOF


