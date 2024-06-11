if ~exist('new_dataset', 'dir')
    mkdir('new_dataset');
end

% Directory principale contenente tutte le sottocartelle
dir_principale = '/Users/robertabattaglia/Desktop/2024_I2MTC_CarAudio/dataset';
% Trova tutti i file .wav nella directory principale e nelle sottocartelle
file_audio_originali = dir(fullfile(dir_principale, '**', '*.wav'));
%Funzione dir: Recupera una lista di file e directory che corrispondono al pattern specificato.
%Pattern '**/*.wav': Cerca ricorsivamente tutti i file .wav nelle sottodirectory.

% File dei rumori
file_rumore_pioggia = 'audiopioggia.wav';
file_rumore_vento = 'vento.wav';

% Carico i file audio dei rumori 
[rumore_pioggia, fs_rumore] = audioread(file_rumore_pioggia);
[rumore_vento, fs_rumore_vento] = audioread(file_rumore_vento);

%Parametro di miscelazione
alpha = 0.4;

for i = 1:length(file_audio_originali)
    %Percorso completo del file audio originale
    percorso_audio_originale = fullfile(file_audio_originali(i).folder, file_audio_originali(i).name);
%file_audio_originali(i): Accede al i-esimo file nella lista dei file trovati.
%file_audio_originali(i).folder: Ottiene il percorso della cartella che contiene il file corrente.
%file_audio_originali(i).name: Ottiene il nome del file corrente.
%fullfile: Combina la cartella e il nome del file per creare il percorso completo del file audio.

% Carico il file audio originale
[audio_originale, fs] = audioread(percorso_audio_originale);

% Assicuro che le frequenze di campionamento siano uguali
if fs ~= fs_rumore
    % Ricampionamento del rumore alla stessa frequenza di campionamento del file audio originale
    rumore_pioggia = resample(rumore_pioggia, fs, fs_rumore);
end

% Se le durate non sono uguali, faccio in modo che abbiano la stessa durata
lunghezza_originale = length(audio_originale);
lunghezza_rumore = length(rumore_pioggia);

if lunghezza_rumore < lunghezza_originale
% Ripeto il rumore finché non è lungo abbastanza
    rumore_pioggia = repmat(rumore_pioggia, ceil(lunghezza_originale / lunghezza_rumore), 1);
 end

% Calcolo la lunghezza minima tra i due segnali audio
lunghezza_minima = min(length(rumore_pioggia), lunghezza_originale);

% Tronco alla lunghezza minima
rumore_troncato = rumore_pioggia(1:lunghezza_minima);
audio_originale_troncato = audio_originale(1:lunghezza_minima);

%Evitare il clipping
%Massima ampiezza del segnale audio originale
max_originale = max(abs(audio_originale_troncato));

%Massima ampiezza del rumore
max_rumore = max(abs(rumore_troncato));

% Calcolo del nuovo alpha
alpha_star = round((1 - max_originale) / max_rumore, 2);

if alpha_star < alpha
    alpha = alpha_star;
end

% Calcolo il segnale audio risultante utilizzando il nuovo alpha
augmented_audio = audio_originale_troncato + (alpha * rumore_troncato);

  
%Percorso per salvare il nuovo file audio
tipo_rumore = 'pioggia';
percorso_augmented_audio = fullfile('new_dataset', sprintf('augmented_%s_alpha%.2f_%s', tipo_rumore, alpha, file_audio_originali(i).name));

%Salvo il nuovo file audio
audiowrite(percorso_augmented_audio, augmented_audio, fs,'BitsPerSample',32);


disp(['File salvato con pioggia: ' percorso_augmented_audio]);

% Aggiungo rumore del vento
lunghezza_rumore_vento = length(rumore_vento);

if lunghezza_rumore_vento < lunghezza_originale
     rumore_vento = repmat(rumore_vento, ceil(lunghezza_originale / lunghezza_rumore_vento), 1);
 end

lunghezza_minima_vento = min(length(rumore_vento), lunghezza_originale);

rumore_troncato_vento = rumore_vento(1:lunghezza_minima_vento);
audio_originale_vento = audio_originale(1:lunghezza_minima_vento);

%Evitare il clipping
% Massima ampiezza del segnale audio originale
max_originale = max(abs(audio_originale_vento));

%Massima ampiezza del rumore
max_rumore = max(abs(rumore_troncato_vento));

% Calcolo del nuovo alpha 
alpha = 0.4;
alpha_star = round((1 - max_originale) / max_rumore, 2);

if alpha_star < alpha
    alpha = alpha_star;
end

% Calcolo il segnale audio risultante utilizzando il nuovo alpha
augmented_audio_vento = audio_originale_vento + (alpha * rumore_troncato_vento);

tipo_rumore = 'vento';
percorso_augmented_audio_vento = fullfile('new_dataset', sprintf('augmented_%s_alpha%.2f_%s', tipo_rumore, alpha, file_audio_originali(i).name));

audiowrite(percorso_augmented_audio_vento, augmented_audio_vento, fs,'BitsPerSample',32);

disp(['File salvato con vento: ' percorso_augmented_audio_vento]);

end
