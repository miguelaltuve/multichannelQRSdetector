function [performance, coefficients, beta_opt] = multichannel_detector_training(detections, database, beta)
% This function permits to train the multichannel detector. Weighting
% coefficients alpha and decision threshold beta were estimated in the
% learning period. As recommended by the ANSI/AAMI EC38:1998, the first
% five minutes of each record were used in a learning period to estimate
% coefficients alpha and threshold beta.
% Author: Miguel Altuve, PhD
% Date: March 2018
% Email: miguelaltuve@gmail.com
% Last updated: May 2018

% Initialization of variables
switch database
    
    case 'MIT'
        data_path = 'MIT';
        fs = 360; % Sampling frequency
        
    case 'INCART'
        data_path = 'INCART';
        fs = 257; % Sampling frequency
end

% Time specifying the match window size. A detection time is
% considered TP if it lies within a 150 ms matching window of a
% reference annotation time
matchWindow = '0.15';

% The multi-channel QRS complex detector simultaneously monitors N
% different ECG channels for the detection of QRS complexes. Once detection
% is signaled in a given ECG channel, a time window TD is opened during
% which the detections signaled in other ECG channels are considered
% simultaneous and over which the final decision rule is applied. Window TD
% was chosen to be 150 ms long (TD = matchWindow) to tackle with the
% different QRS complex morphologies and different latencies of the cardiac
% electric phenomena, as consequence of the spatial variation of electrode
% placement, that could produce individual decisions shifted in time.
TD = ceil(150/1000*fs);

cd(data_path);
rec_ext='dat'; % using the WFDB binary dataset
records=dir(['*.' rec_ext]);
L=length(records); % Number of records in the database
N = size(detections,2); % Number of ECG channels in the database


%=======Estimating weighting coefficients alpha=================
% The reliability of detector decisions in individual channels is taken
% into account as the weighted sum of decisions

disp('Estimating weighting coefficients alpha');

Se = zeros(L, N); % Sensitivity
PP = zeros(L, N); % Positive predictivity

% Reading singlechannel detections on all ECG channels
for j = 1 : N
    
    % Reading singlechannel detections on every record (first 5 minutes of
    % the record)
    for i = 1 : L
        
        record_id=records(i).name(1:3); % Name of record
        
        %Singlechannel detection (QRS complex localization)
        det = detections{i,j}; % row = Record, column = ECG channel
        
        % In case there are no detections reported by the singlechannel detector
        if isempty(det)
            
            % As recommended by the ANSI/AAMI EC38:1998, the first 5
            % minutes of each record were used in a learning period to
            % estimate coefficients alpha. Also, a beat-by-beat comparison
            % was performed using MATLAB wrapper function bxb
            cd ..
            %Reading the annotation provided in the database (do not use
            %rdann because the number obtained is incorrect)
            report=bxb([database '/' record_id],'atr','atr',['bxbReport' record_id '.txt'],'0','300',matchWindow);
            delete(['bxbReport' record_id '.txt']); % Deleting the file
            
            % Measures
            tp =0 ; % True positive
            fn =sum(sum(report.data(1:5,1:5)))+sum(report.data(1:5,6)); % False negative
            fp =0; % False positive
            
        else
            
            det = det(:); % convert the vector into a column vector
            
            % Write detections to disk
            type = char('N'*(ones(size(det,1),1)));
            subtype = zeros(size(det,1),1);
            chan = zeros(size(det,1),1);
            num = zeros(size(det,1),1);
            wrann(record_id,'test',det,type,subtype,chan,num);
            
            % As recommended by the ANSI/AAMI EC38:1998, the first 5
            % minutes of each record were used in a learning period to
            % estimate coefficients alpha. Also, a beat-by-beat comparison
            % was performed using MATLAB wrapper function bxb.
            
            cd ..
            report=bxb([database '/' record_id],'atr','test',['bxbReport' record_id '.txt'],'0','300',matchWindow);
            delete(['bxbReport' record_id '.txt']); % Deleting the file
            
            % Measures
            tp =sum(sum(report.data(1:5,1:5))); % True positive
            fn =sum(report.data(1:5,6)); % False negative
            fp =sum(report.data(6:end,1)); % False positive
            
        end
        
        % Performance metrics
        Se(i,j) = tp/(tp+fn); % Sensitivity
        PP(i,j) = tp/(tp+fp); % Positive predictivity
        if isnan(PP(i,j)) % % in case tp and fp are 0, PP is undefined.
            PP(i,j) = 1;
        end
        
        cd(data_path);
        
    end
    
end

% Calculation of the weighting coefficients
coefficients(1,:) = log10(mean(Se)./(1-mean(PP))); % if y = +1
coefficients(2,:) = log10(mean(PP)./(1-mean(Se))); % if y = -1

%=======Estimating decision threshold beta=================
% Threshold beta, used to decide whether a detection is true or false, was
% estimated in the learning period. For various threshold values, the
% threshold that leads to the shortest Euclidean distance to perfect
% detection was selected

disp('Estimating decision threshold beta');

M = length(beta); % number of thresholds
performance = zeros(M,8); % matrix of performance

% Evaluate each decision threshold beta
for j = 1:M
    
    disp(['Evaluating multichannel detector in ' database ', Threshold beta = ' num2str(beta(j)) ', Remaining ' num2str(M-j) ' thresholds']);
    
    TEMP = zeros(L,7); %
    
    % Evaluate detection on every record (the first 5 minutes of the record)
    for i = 1 : L
        
        record_id=records(i).name(1:3); % name of record
        
        % Reading N singlechannel detections of record i
        det = detections(i,:);
        % Perform optimal fusion from signlechannel detections
        det = performFusionOpt(det, TD, coefficients, beta(j));
        
        % In case there are no detections reported by the multichannel detector
        if isempty(det)
            
            % As recommended by the ANSI/AAMI EC38:1998, the first 5
            % minutes of each record were used in a learning period to
            % estimate coefficients alpha. Also, a beat-by-beat comparison
            % was performed using MATLAB wrapper function bxb.
            cd ..
            % Reading the annotation provided in the database (do not use
            % rdann because the number obtained is incorrect)
            report=bxb([database '/' record_id],'atr','atr',['bxbReport' record_id '.txt'],'0','300',matchWindow);
            delete(['bxbReport' record_id '.txt']);
            
            % Measures
            tp =0; % True positive
            fn =sum(sum(report.data(1:5,1:5)))+sum(report.data(1:5,6)); % False negative
            fp =0; % False positive
            
        else
            
            det = det(:); % Convert the vector into a column vector
            
            % Write detections to disk
            type = char('N'*(ones(size(det,1),1)));
            subtype = zeros(size(det,1),1);
            chan = zeros(size(det,1),1);
            num = zeros(size(det,1),1);
            wrann(record_id,'test',det,type,subtype,chan,num);
            
            % As recommended by the ANSI/AAMI EC38:1998, the first 5
            % minutes of each record were used in a learning period to
            % estimate coefficients alpha. Also, a beat-by-beat comparison
            % was performed using MATLAB wrapper function bxb.
            cd ..
            report=bxb([database '/' record_id],'atr','test',['bxbReport' record_id '.txt'],'0','300',matchWindow);
            delete(['bxbReport' record_id '.txt']); % Deleting the file
            
            % Measures
            tp =sum(sum(report.data(1:5,1:5))); % True positive
            fn =sum(report.data(1:5,6)); % False negative
            fp =sum(report.data(6:end,1));  % False positive
            
        end
        
        % Performance metrics
        Se = tp/(tp+fn)*100; % Sensitivity
        PP = tp/(tp+fp)*100; % Positive predictivity
        if isnan(PP) % In case tp and fp are 0, PP is undefined.
            PP = 100;
        end
        DER = (fp+fn)/(tp+fn)*100; % Detection error rate
        
        % The shortest Euclidean distance to perfect detection (point (0,1)
        % in the ROC curve)
        SDTP = sqrt( (1-Se/100)^2 + (1-PP/100)^2 );
        
        TEMP(i,:) = [tp,fn,fp,Se,PP,DER,SDTP];
        
        cd(data_path);
        
    end
    
    performance(j,:) = [beta(j), sum(TEMP)];
    performance(j,5:end) = performance(j,5:end)/L; % Performance average
    
    
end

% Get SDTP
TEMP = performance(:,end);
% In case various thresholds met the SDTP criteria, the mean value of these
% thresholds was selected.
beta_opt = mean(beta(TEMP == min(TEMP)));

cd ..

end
