%
% How to generete AWGN with correct PSD on MATLAB
%
clear all
clc

FFT_convention = 0; % 0 - Classic FFT convention (default on Matlab)
                    % 1 - Unitary FFT convention
                    
% NOTE: the unitary FFT convention is the one in which the FFT 
% transform is energy-preserving.

%% Define target PSD (noise floor)

% Define noise floor:
noiseFloor = -135; % dBm/Hz

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
switch FFT_convention
    case 0
        noise_fft = fft(noise_splitted, N);
    case 1
        noise_fft = fft(noise_splitted, N) / sqrt(N);
end

% Simplest Periodogram - in Watts/(FFT subcarrier)
switch FFT_convention
    case 0
        Sk = mean( abs(noise_fft).^2, 2) / N;
    case 1
        % Note: for an unitary FFT convention, the mean-square of the noise
        % time domain samples and the mean square of the FFT points are
        % equal.
        % You can check by comparing the following (commmented) lines:
        % mean(abs(noise_splitted(:,1)).^2)
        % mean(abs(noise_fft(:,1)).^2)
        Sk = mean( abs(noise_fft).^2, 2); 
end

% Define sampling frequency on Nyquist Rate
fs = 2*bandwidth; % sampling frequency

% Convert PSD estimator to Watts/Hz:
Sk_wattsHz = Sk / fs; 
% Note: when the PSD in Watts/tone `Sk` is adopted, the total power is 
% computed by sum(Sk * (1/N)), where (1/N) is the digital frequency 
% spacing. In contrast, if the PSD in Watts/Hz `Sk_wattsHz` is used, the
% total power becomes sum(Sk_wattsHz * toneSpacing), where toneSpacing is
% the analog frequency spacing, which is equal to fs/N. Hence, it follows 
% from this that the factor 1/fs must appear in the PSD.

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

% Alternative (more accurate) PSD estimation using Welch's method:
figure
pwelch(noise,[],[],[],fs,'twosided');






