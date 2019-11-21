function beats = detectHT(sig, fs)
%
%     beats = detectHT(sig, fs)
% 
%     This function detects the apperance of QRS complexes in an ECG signal. To
%     do so it processes an ECG signal using the Hilbert Transform
%     algorithm 
% 
%     Inputs:
% 
%     'sig' is an array of doubles containing the signal to be
%     processed.
% 
%     'fs' is the sampling frequency
% 
%     Output:
% 
%     'beats' is a line vector containing the detection results. The vector
%     contains the sample numbers where a QRS complexes were found.
% 
%     This routine was developed by the Simon Bolivar University's Applied
%     Biophysics and Bioengineering Group (GBBA-USB) for free and public use. 
%     It is protected under the terms of the Creative Commons Attribution-Non
%     Commercial 4.0 International License, no profit may come from any 
%     application that uses this function and proper credit must be given to 
%     the GBBA-USB. For further information consult 
%     http://creativecommons.org/licenses/by-nc/4.0/
%
%     Author: Carlos Ledezma


%Band-Pass filtering
[num, den] = butter(4, [8 20]/(fs/2), 'bandpass');
sigFilt = filtfilt(num,den,sig);

%Differentiation of the signal
for i = 2 : length(sig)-1
    sigDER(i) = fs/2 * (sigFilt(i+1) -sigFilt(i-1));
end
sigDER(1) = sigDER(2);
sigDER(end+1) = sigDER(end);

%Hilbert transformation
sigH = imag(hilbert(sigDER));

%Moving window where detection will be made
sigWin = zeros(1,1024);
prevMax = 0;

%Detection wait time
detWin = ceil(200/1000*fs);

%Initialize beats vector
beats = -detWin;
%Perform detection in 1024 sample windows
for i = 1 : 1024 : length(sigH)
    
    %Define part that will be analyzed
    if i + 1024 <= length(sigH)
        sigWin = sigH(i : i+1024);
    else
        sigWin = sigH(i : length(sigH));
    end
    
    %Define threshold
    rmsVal = rms(sigWin);
    maxVal = max(sigWin);
    
    comp = rmsVal/maxVal;
    
    if maxVal >= 2*prevMax && prevMax ~= 0
        thresh = 0.39*prevMax;
    elseif comp >= 0.18
        thresh = 0.39*maxVal;
    else
        thresh = 1.6*rmsVal;
    end
    
    prevMax = maxVal;
    
    %Look for peaks
    for j = 2 : length(sigWin)-1
        if sigWin(j) > sigWin(j-1) && sigWin(j) > sigWin(j+1)
            %When a peak is found verify that threshold is exceeded
            if sigWin(j) > thresh
                %If new peak is farther than detection window, save
                %detection
                if i+j - beats(end) > detWin
                    beats(end+1) = i+j;
                else %If peak es within the detection window, save largest peak
                    if sigH(beats(end)) < sigWin(j)
                        beats(end) = i+j;
                    end
                end
            end
        end
    end
end

%Eliminate first beat
beats(1) = [];

end