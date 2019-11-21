function [performance, Detections] = multichannel_detector_test(detections, database, beta, coefficients)
% This function permits to test the multichannel detector from
% singlechannel detection, and weighting coefficients alpha and decision
% threshold beta estimated in the learning period.  
% As recommended by the ANSI/AAMI EC38:1998, the performance of the
% multichannel QRS complex detector was evaluated from minute 5 of each
% record (300 s).  
% Author: Miguel Altuve, PhD
% Date: March 2018
% Email: miguelaltuve@gmail.com
% Last updated: May 2018

switch database
    
    case 'MIT'
        data_path = 'MIT';
        fs = 360;
        
    case 'INCART'
        data_path = 'INCART';
        fs = 257;
end

% Time specifying the match window size. A detection time is considered TP
% if it lies within a 150 ms matching window of a reference annotation time 
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
rec_ext='dat'; % Using the WFDB binary dataset
records=dir(['*.' rec_ext]);
L=length(records); % Number of records in the database


%=========Evaluating multichannel detector performance on the test set===============

disp('Testing detector');

% Reading singlechannel detections on every record (from minute 5 of the record)
for i = 1 : L
    
    record_id=records(i).name(1:3); % Name of record
    
    % Reading N singlechannel detections of record I
    det = detections(i,:);
    
    % Perform optimal fusion from signlechannel detections
    det = performFusionOpt(det,TD,coefficients,beta);
    
    % In case there are no detections reported by the multichannel detector
    if isempty(det)
        
        % As recommended by the ANSI/AAMI EC38:1998, from minute 5 of each
        % record were used to evaluate the detection performance. Also, a
        % beat-by-beat comparison was performed using MATLAB wrapper
        % function bxb.   
        cd ..
        % Reading the annotation provided in the database (do not use rdann
        % because the number obtained is incorrect) 
        report=bxb([database '/' record_id],'atr','atr',['bxbReport' record_id '.txt'],'300',[],matchWindow);
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
        
        % As recommended by the ANSI/AAMI EC38:1998, from minute 5 of each
        % record were used to evaluate the detection performance. Also, a
        % beat-by-beat comparison was performed using MATLAB wrapper
        % function bxb.   
        cd ..
        report=bxb([database '/' record_id],'atr','test',['bxbReport' record_id '.txt'],'300',[],matchWindow);
        delete(['bxbReport' record_id '.txt']);
        
        % Measures
        tp =sum(sum(report.data(1:5,1:5))); % True positive
        fn =sum(report.data(1:5,6)); % False negative
        fp =sum(report.data(6:end,1)); % False positive
    end
    
    % Performance metrics
    Se = tp/(tp+fn)*100; % Sensitivity
    PP = tp/(tp+fp)*100; % Positive predictivity
    if isnan(PP) % In case tp and fp are 0, PP is undefined.
        PP = 100;
    end
    DER = (fp+fn)/(tp+fn)*100; % Detection error rate
    
    % The shortest Euclidean distance to perfect detection (point (0,1) in
    % the ROC curve) 
    SDTP = sqrt( (1-Se/100)^2 + (1-PP/100)^2 );
    
    % cell of detections (QRS complex localization)
    Detections{i} = det;
    
    % Performance for each record
    performance(i,:) = [string(record_id), tp,fn,fp,Se,PP,DER,SDTP];
    
    cd(data_path);

end

cd ..

end