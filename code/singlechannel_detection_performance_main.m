
% This script permits obtaining singlechannel QRS complex detection
% performance using six different QRS complex detector on two different
% databases: MIT and INCART. Singlechannel detectors are: Pan and Tompkins
% filter-based (PT), Benitez et al. Hilbert transform-based (HT),
% Ramakrishnan et al. dynamic plosion index-based (DPI), and GQRS, WQRS and
% SQRS PhysioNet's detectors.
% As recommended by the ANSI/AAMI EC38:1998, the first five minutes of each
% record were used in a learning period and the remainder of the record was
% used to evaluate the detector performance.
% Author: Miguel Altuve, PhD
% Date: March 2018
% Email: miguelaltuve@gmail.com
% Last updated: May 2018


cd ../data/

database = {'MIT', 'INCART'}; % name of the databases

for i = 1 : length(database)
    
    % Singlechannel performance of PT detector
    [PERFORMANCE, DETECTIONS] = singlechannel_detection_performance('PT', database{i});
    performance{i}.PT= PERFORMANCE; % singlechannel QRS complex detection performance
    detections{i}.PT = DETECTIONS; % singlechannel QRS complex detection (QRS complex localization)
    
    % Singlechannel performance of HT detector
    [PERFORMANCE, DETECTIONS] = singlechannel_detection_performance('HT', database{i});
    performance{i}.HT= PERFORMANCE; detections{i}.HT = DETECTIONS;
    
    % Singlechannel performance of DPI detector
    [PERFORMANCE, DETECTIONS] = singlechannel_detection_performance('DPI', database{i});
    performance{i}.DPI= PERFORMANCE; detections{i}.DPI= DETECTIONS;
    
    % Singlechannel performance of GQRS detector
    %Test single lead GQRS algorithm
    [PERFORMANCE, DETECTIONS] = singlechannel_detection_performance('GQRS', database{i});
    performance{i}.GQRS = PERFORMANCE; detections{i}.GQRS = DETECTIONS;
    
    % Singlechannel performance of GQRS detector
    [PERFORMANCE, DETECTIONS] = singlechannel_detection_performance('WQRS', database{i});
    performance{i}.WQRS= PERFORMANCE; detections{i}.WQRS = DETECTIONS;
    
    % Singlechannel performance of SQRS detector
    [PERFORMANCE, DETECTIONS] = singlechannel_detection_performance('SQRS', database{i});
    performance{i}.SQRS= PERFORMANCE; detections{i}.SQRS = DETECTIONS;
    
end

% Saving variables of interest
cd ../results/
% Save singlechannel QRS complex detections (QRS complex localization)
save('DetectionsSinglechannel','detections');
% Save singlechannel QRS complex detection performance
save('PerformanceSinglechannel','performance');


%============ Function singlechannel_detection_performance================
function [performance, detections] = singlechannel_detection_performance(DetectorName, database)

% Initialization of variables
switch database    
    case 'MIT'
        data_path = 'MIT';
        N = 2; % Number of ECG channels in the database
        
    case 'INCART'
        data_path = 'INCART';
        N = 12; % Number of ECG channels in the database        
end

% Time specifying the match window size. A detection time is
% considered TP if it lies within a 150 ms matching window of a
% reference annotation time
matchWindow = '0.15';

cd(data_path);
rec_ext='dat'; % using the WFDB binary dataset
records=dir(['*.' rec_ext]);
L=length(records); % Number of records in the database

detections = cell(L, N); % Cell of detections
performance = cell(1, N); % Cell of performance

%Perform detection on all ECG channels
for j = 1 : N
    
    for i = 1 : L % Perform detection on every record (the entire duration of the record)
        
        record_id=records(i).name(1:3); % name of record
        [signal,fs,~]= rdsamp(record_id); % Reading record
        
        % This if section is only valid for MIT database since record 114 has MLII on channel 2.
        if strcmp(database,'MIT') && strcmp(record_id,'114')
            
            if j ==1
                m = 1; % select the next channel
            else
                m = -1; % select the previous channel
            end
            
            switch DetectorName
                
                case 'PT' % Pan and Tompkins filter-based
                    disp(['Evaluating PT detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    [~,det] = pan_tompkin(signal(:,j+m),fs);
                    
                case 'HT' % Benitez et al. Hilbert transform-based
                    disp(['Evaluating HT detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    det = detectHT(signal(:,j+m),fs);
                    
                case 'DPI' % Ramakrishnan et al. dynamic plosion index-based
                    disp(['Evaluating DPI detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    det = dpi_qrs(signal(:,j+m),fs,1800,5); % using the parameters recommended in the code
                    
                case 'GQRS' % GQRS PhysioNet's detectors
                    disp(['Evaluating GQRS detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    gqrs(record_id,[],[],j+m); % Creates a .qrs annotation file at the current directory
                    det = rdann(record_id,'qrs'); % Read .qrs annotation file
                    
                case 'WQRS' % WQRS PhysioNet's detectors
                    disp(['Evaluating WQRS detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    wqrs(record_id,[],[],j+m); % Creates a .wqrs annotation file at the current directory
                    det = rdann(record_id,'wqrs'); % Read .qrs annotation file
                    
                case 'SQRS' % SQRS PhysioNet's detectors
                    disp(['Evaluating SQRS detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    sqrs(record_id,[],[],[],j+m); % Creates a .qrs annotation file at the current directory
                    det = rdann(record_id,'qrs'); % Read .qrs annotation file
                    
            end
            
        else % MIT different of record 114 and other databases
            
            switch DetectorName
                
                case 'PT' % Pan and Tompkins filter-based
                    disp(['Evaluating PT detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    [~,det] = pan_tompkin(signal(:,j),fs);
                    
                case 'HT' % Benitez et al. Hilbert transform-based
                    disp(['Evaluating HT detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    det = detectHT(signal(:,j),fs);
                    
                case 'DPI' % Ramakrishnan et al. dynamic plosion index-based
                    disp(['Evaluating DPI detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    det = dpi_qrs(signal(:,j),fs,1800,5); % using the parameters recommended in the code
                    
                case 'GQRS' % GQRS PhysioNet's detectors
                    disp(['Evaluating GQRS detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    gqrs(record_id,[],[],j); % Creates a .qrs annotation file at the current directory
                    det = rdann(record_id,'qrs'); % Read .qrs annotation file
                    
                case 'WQRS' % WQRS PhysioNet's detectors
                    disp(['Evaluating WQRS detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    wqrs(record_id,[],[],j); % Creates a .wqrs annotation file at the current directory
                    det = rdann(record_id,'wqrs'); % Read .qrs annotation file
                    
                case 'SQRS' % SQRS PhysioNet's detectors
                    disp(['Evaluating SQRS detector in ' database ' ECG channel ' num2str(j) ', Record ' num2str(i) ', Remaining ' num2str(L-i) ' records']);
                    sqrs(record_id,[],[],[],j); % Creates a .qrs annotation file at the current directory
                    det = rdann(record_id,'qrs'); % Read .qrs annotation file
            end
            
        end
        
        % In case there are no detections reported by the detector
        if isempty(det)
            
            % As recommended by the ANSI/AAMI EC38:1998, the performance of
            % the QRS complex detector was evaluated from minute 5 of each
            % record (300 s). Also, a beat-by-beat comparison was performed
            % using MATLAB wrapper function bxb    
            cd ..
            % Reading the annotation provided in the database (do not use
            % rdann because the number obtained is incorrect) 
            report=bxb([database '/' record_id],'atr','atr',['bxbReport' record_id '.txt'],'300',[],matchWindow);
            delete(['bxbReport' record_id '.txt']); % Deleting the file
            
            % Measures
            tp =0; % True positive
            fn =sum(sum(report.data(1:5,1:5))) +sum(report.data(1:5,6)); % False negative
            fp =0; % False positive
            
        else
            
            det(det<1)=[]; % In case there are negative detections
            det = det(:); % Convert the vector into a column vector
            
            % Write detections to disk
            type = char('N'*(ones(size(det,1),1)));
            subtype = zeros(size(det,1),1);
            chan = zeros(size(det,1),1);
            num = zeros(size(det,1),1);
            wrann(record_id,'test',det,type,subtype,chan,num);
            
            % As recommended by the ANSI/AAMI EC38:1998, the performance of
            % the QRS complex detector was evaluated from minute 5 of each
            % record (300 s). Also, a beat-by-beat comparison was performed
            % using MATLAB wrapper function bxb   
            cd ..
            report=bxb([database '/' record_id],'atr','test',['bxbReport' record_id '.txt'],'300',[],matchWindow);
            delete(['bxbReport' record_id '.txt']); % Deleting the file
            
            % Measures
            tp =sum(sum(report.data(1:5,1:5))); % True positive
            fn =sum(report.data(1:5,6)); % False negative
            fp =sum(report.data(6:end,1)); % False positive
            
        end
        
        % Performance metrics
        Se = tp/(tp+fn)*100; % Sensitivity
        PP = tp/(tp+fp)*100; % Positive predictivity
        % In case tp and fp are 0, PP is undefined.  This occurs, for
        % example, with PT detector in INCART  database channel 11 record
        % 66  
        if isnan(PP) 
            PP = 100; 
        end
        DER = (fp+fn)/(tp+fn)*100; % Detection error rate
        
        % The shortest Euclidean distance to perfect detection (point (0,1)
        % in the ROC curve) 
        SDTP = sqrt( (1-Se/100)^2 + (1-PP/100)^2 ); 
        
        % cell of detections (QRS complex localization)
        detections{i,j} = det; % row = Record, column = ECG channel
        
        % cell of performance
        performance{j}(i,:) = [string(record_id), tp,fn,fp,Se,PP,DER,SDTP];
        
        cd(data_path);
        
    end
    
end

cd ..

end