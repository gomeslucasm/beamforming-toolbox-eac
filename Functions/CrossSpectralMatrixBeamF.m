function out = CrossSpectralMatrixBeamF(audio,f_q,Fs,NFFT,diag_zero)
    

[~,f_v] = get_fft(audio(1,:),'Fs',Fs,'NFFT',NFFT,'Normalized',0);
sz = size(audio);
out_f = zeros(sz(1),length(f_q));
for i =1:1:length(f_q)
   [~,idx_f(i)] = min(abs(f_v-f_q(i)));
end
for i=1:1:sz(1)
    [f,~] = get_fft(audio(i,:),'Fs',Fs,'NFFT',NFFT,'Normalized',0);
    out_f(i,:) = f(idx_f);
end

C = cell(length(f_q));
for i=1:1:length(f_q)
    C{i} = (out_f(:,i)*out_f(:,i)')/2;
    % Zera a diagonal principal da matrix de espectros cruzados
    if diag_zero
       C_diag = diag(diag(C{i}));
       C{i} = C{i} - C_diag;
    end
end

out = C;

end

