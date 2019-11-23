% This script permits obtaining multichannel QRS complex detection
% performance by optimally combining singlechannel QRS complex detections.
% Singlechannel QRS complex detections come from six different detectors:
% Pan and Tompkins filter-based (PT), Benitez et al. Hilbert
% transform-based (HT), Ramakrishnan et al. dynamic plosion index-based
% (DPI), and GQRS, WQRS and SQRS PhysioNet's detectors.
% The performance is estimated on two different databases: MIT and INCART.
% As recommended by the ANSI/AAMI EC38:1998, the first five minutes of each
% record were used in a learning period and the remainder of the record was
% used to evaluate the detector performance.
% Author: Miguel Altuve, PhD
% Date: March 2018
% Email: miguelaltuve@gmail.com
% Last updated: May 2018

database = {'MIT','INCART'}; % name of the databases

% Loading singlechannel detections
cd ../results/
load('DetectionsSinglechannel')

detectionsTemp = detections;
clear detections; % the name detections will be used again

cd ../data/

for i = 1:length(database)
    
    % Pan and Tompkins filter-based
    % Training
    % Detection threshold vector to find the optimal threshold
    %     beta = -1.2:0.01:1.2; % uncomment this line to find the optimal beta within a search space
    %%%--- comment this part if the previous line was uncommented ----%%
    if strcmp(database(i),'MIT') % These are the optimal values reported in the paper
        beta = -0.125;
    else
        beta = 0.2;
    end
    %%%---------------------------------------------------------------%%
    disp(['Training PT detector in ' database{i}]);
    [performance{i}.Train.PT, coefficients{i}.PT, beta_opt{i}.PT] = multichannel_detector_training(detectionsTemp{i}.PT, database{i}, beta);
    % Test
    [performance{i}.Test.PT, detections{i}.PT] = multichannel_detector_test(detectionsTemp{i}.PT, database{i}, beta_opt{i}.PT, coefficients{i}.PT);
    
    
    % Benitez et al. Hilbert transform-based
    % Training
    % Detection threshold vector to find the optimal threshold
    % beta = -3:0.01:1; % uncomment this line to find the optimal beta within a search space
    %%%--- comment this part if the previous line was uncommented ----%%
    if strcmp(database(i),'MIT') % These are the optimal values reported in the paper
        beta = 0.215;
    else
        beta = -1.25;
    end
    %%%---------------------------------------------------------------%%
    disp(['Training HT detector in ' database{i}]);
    [performance{i}.Train.HT, coefficients{i}.HT, beta_opt{i}.HT] = multichannel_detector_training(detectionsTemp{i}.HT, database{i}, beta);
    % Test
    [performance{i}.Test.HT, detections{i}.HT] = multichannel_detector_test(detectionsTemp{i}.HT, database{i}, beta_opt{i}.HT, coefficients{i}.HT);
    
    
    % Ramakrishnan et al. dynamic plosion index-based
    % Training
    % Detection threshold vector to find the optimal threshold
    % beta = -0.7:0.01:0.5; % uncomment this line to find the optimal beta within a search space
    %%%--- comment this part if the previous line was uncommented ----%%
    if strcmp(database(i),'MIT') % These are the optimal values reported in the paper
        beta = -0.1;
    else
        beta = -0.135;
    end
    %%%---------------------------------------------------------------%%
    disp(['Training DPI detector in ' database{i}]);
    [performance{i}.Train.DPI, coefficients{i}.DPI, beta_opt{i}.DPI] = multichannel_detector_training(detectionsTemp{i}.DPI, database{i}, beta);
    % Test
    [performance{i}.Test.DPI, detections{i}.DPI] = multichannel_detector_test(detectionsTemp{i}.DPI, database{i}, beta_opt{i}.DPI, coefficients{i}.DPI);
    
    
    % GQRS PhysioNet's detectors
    % Training
    % Detection threshold vector to find the optimal threshold
    % beta = -3:0.01:7; % uncomment this line to find the optimal beta within a search space
    %%%--- comment this part if the previous line was uncommented ----%%
    if strcmp(database(i),'MIT') % These are the optimal values reported in the paper
        beta = 0.29;
    else
        beta = 2.785;
    end
    %%%---------------------------------------------------------------%%
    disp(['Training GQRS detector in ' database{i}]);
    [performance{i}.Train.GQRS, coefficients{i}.GQRS, beta_opt{i}.GQRS] = multichannel_detector_training(detectionsTemp{i}.GQRS, database{i}, beta);
    % Test
    [performance{i}.Test.GQRS, detections{i}.GQRS] = multichannel_detector_test(detectionsTemp{i}.GQRS, database{i}, beta_opt{i}.GQRS, coefficients{i}.GQRS);
    
    
    % WQRS PhysioNet's detectors
    %  Training
    % Detection threshold vector to find the optimal threshold
    % beta = -5:0.02:1; % uncomment this line to find the optimal beta within a search space
    if strcmp(database(i),'MIT') % These are the optimal values reported in the paper
        beta = -0.53;
    else
        beta = -0.24;
    end
    %%%---------------------------------------------------------------%%
    disp(['Training WQRS detector in ' database{i}]);
    [performance{i}.Train.WQRS, coefficients{i}.WQRS, beta_opt{i}.WQRS] = multichannel_detector_training(detectionsTemp{i}.WQRS, database{i}, beta);
    % Test
    [performance{i}.Test.WQRS, detections{i}.WQRS] = multichannel_detector_test(detectionsTemp{i}.WQRS, database{i}, beta_opt{i}.WQRS, coefficients{i}.WQRS);
    
    
    % SQRS PhysioNet's detectors
    %  Training
    % Detection threshold vector to find the optimal threshold
    % beta = -5:0.02:2; % uncomment this line to find the optimal beta within a search space
    if strcmp(database(i),'MIT') % These are the optimal values reported in the paper
        beta = 0.49;
    else
        beta = 1.02;
    end
    %%%---------------------------------------------------------------%%
    disp(['Training SQRS detector in ' database{i}]);
    [performance{i}.Train.SQRS, coefficients{i}.SQRS, beta_opt{i}.SQRS] = multichannel_detector_training(detectionsTemp{i}.SQRS, database{i}, beta);
    % Test
    [performance{i}.Test.SQRS, detections{i}.SQRS] = multichannel_detector_test(detectionsTemp{i}.SQRS, database{i}, beta_opt{i}.SQRS, coefficients{i}.SQRS);
    
    
end

% Saving variables of interest
cd ../results/
% Save multichannel QRS complex detections (QRS complex localization)
save('DetectionsMultichannel','detections');
% Save multichannel QRS complex detection performance
save('PerformanceMultichannel','performance','coefficients','beta_opt');