% This is the main script

% Add code folder to the search path
addpath(pwd); 

% perform singlechannel detections
singlechannel_detection_performance_main; 

% perform multichannel detections
multichannel_detector_performance_main;
