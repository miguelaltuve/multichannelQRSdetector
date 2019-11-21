%cd /home/miguelaltuve/Documents/MATLAB/detection_latidos_multilead/code

%addpath(pwd);

%singlechannel_detection_performance_main;

%multichannel_detector_performance_main;

wfdbdemo;

[sig, Fs, tm] = rdsamp('mitdb/100', 1);
plot(tm, sig);
saveas(gcf, '../results/mitdb100.png');
