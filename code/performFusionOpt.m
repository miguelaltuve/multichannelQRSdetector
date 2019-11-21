function fusion = performFusionOpt(det, detWin, coefficients, beta)
%
%     fusion = performFusion(det, fs, fusionType)
%
%     Function to perform fusion of different detection results using the
%     Chair and Varshney optimal fusion method
%
%     'det' is a cell array containing the sample numbers where detections were
%     made on the different detection channels. Every row should correspond
%     to a detection signal.
%
%     'fs' is the sampling frequency used to perform the detection.
%
%     'coefDet' are the weights to be used on each channel when a detection
%     is signaled.
%     
%     'coefNoDet' are the weights to be used on each channel when detection
%     is not signaled
%
%     'a0' is the coefficient that corresponds to probability of occurrence
%     of the event being detected. It must be determined before using this
%     routine
%
%     This routine was developed by the Simon Bolivar University's Applied
%     Biophysics and Bioengineering Group (GBBA-USB) for free and public
%     use. It is protected under the terms of the Creative Commons
%     Attribution-Non Commercial 4.0 International License, no profit may
%     come from any application that uses this function and proper credit
%     must be given to the GBBA-USB. For further information consult
%     http://creativecommons.org/licenses/by-nc/4.0/
%
%     Author: Carlos Ledezma
%     Last modified: Miguel Altuve, Mar 2018, miguelaltuve@gmail.com

%Variable to count which detection signals are empty
emp = false(size(det));
%Detection window
% detWin = ceil(150/1000*fs); % ventana para la fusion 150 ms
%Detection counter
k = 1;
%Initialize fusion result
fusion = 0;

%Perform fusion while there is at least one signal with detections left
while ~all(emp)
    count = zeros((size(det)));
    
    %Find channel that has earliest detection
    firstNotEmpty = find(emp == false,1);
    comp = det{firstNotEmpty}(1);
    chan = firstNotEmpty;
    for i = firstNotEmpty : length(det)
        if ~isempty(det{i})
            if det{i}(1) < comp
                comp = det{i}(1);
                chan = i;
            end
        end
    end
    
    count(chan) = 1;
    DetectSample = comp;
    
    %Compare to other channels and count which have detections within the
    %detection window
    for i = 1 : length(det)
        if i ~= chan && ~isempty(det{i})%Do not compare channel with itself or with an empty channel
            if det{i}(1) - comp <= detWin %If detections are close enough
                %Mark detection
                count(i) = 1; 
                %Sample where detection occurs
                DetectSample = [DetectSample det{i}(1)];
                %Eliminate detection that has already been analyzed
                det{i}(1) = [];
            end
        end
    end
    
    %Eliminate the detection being analyzed
    det{chan}(1) = [];
    
    %Update empty verification vector
    for i = 1 : length(det)
        if isempty(det{i})
            emp(i) = true;
        end
    end
    
    %Perform fusion
    %Initialize sum with offset a0
    sum = 0; 
    %Start adding
    for i = 1 : length(count)
        if count(i) == 1 %If the lead signaled detection sum the corresponding ai
            sum = sum + coefficients(1,i);
        else %If the lead did not signal detection subtract the corresponding ai
            sum = sum - coefficients(2,i);
        end
    end
    
    if sum > beta
        fusion(k) = round(mean(DetectSample));
        k = k + 1;
    end
end