%
% How to generete AWGN with correct PSD on MATLAB
%
clear all
clc

%% Define target PSD (noise floor)

% Define noise floor:
noiseFloor = - 135; % dBm/Hz

% Convert to db/Hz:
noiseFloor_dbHz = noiseFloor - 30;

% Convert to Watts/Hz:
noiseFloor_wattsHz = 10^( noiseFloor_dbHz/10); % Watts /Hz

%% Calculate noise total average power

% Bandwidth:
bandwidth = 100e6; % in Hz

% Average total power:
noisePower = 2*bandwidth*noiseFloor_wattsHz;

%% Generate time domain noise

% Number of samples:
N = 4096;           % samples in a symbol/buffer
nSymbols = 100;     % number of symbols or acumulated buffers

% Define variance for the zero-mean Gaussian discrete sequence
variance = noisePower;

% Generete time domain sequence for AWGN
noise = randn(nSymbols*N,1)*sqrt(variance); 


%% Verify PSD

% split noise symbols/buffers
noise_splitted = reshape(noise, N, nSymbols);

% FFT
noise_splitted_fft = fft(noise_splitted, N);

% Simplest Periodogram
Sk = mean( abs(noise_splitted_fft).^2, 2)/N; % Watts/(fft subcarrier)

% Define sampling frequency on Nyquist Rate
fs = 2*bandwidth; % sampling frequency

% Convert periodogram to Watts/Hz:
Sk_wattsHz = Sk / fs; 

% Convert to db/Hz:
Sk_dbHz = 10*log10(Sk_wattsHz);

% Converto to dbm/Hz:
Sk_dbmHz = Sk_dbHz + 30;

% FFT tone spacing:
deltaf = fs / N;

% plot
figure
plot( (0:(N-1))*deltaf / 1e6, Sk_dbmHz)
xlabel('Analog Frequency (Mhz)')
ylabel(' Noise PSD (dbm/Hz)')
grid on

% Alternative (more accurate) periodogram using Welch's method:
figure
pwelch(noise,[],[],[],fs,'twosided');






