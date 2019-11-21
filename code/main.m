%cd /home/miguelaltuve/Documents/MATLAB/detection_latidos_multilead/code

%addpath(pwd);

%singlechannel_detection_performance_main;

%multichannel_detector_performance_main;

[old_path]=which('rdsamp'); if(~isempty(old_path)) rmpath(old_path(1:end-8)); end
wfdb_url='https://physionet.org/physiotools/matlab/wfdb-app-matlab/wfdb-app-toolbox-0-10-0.zip';
[filestr,status] = urlwrite(wfdb_url,'wfdb-app-toolbox-0-10-0.zip');
unzip('wfdb-app-toolbox-0-10-0.zip');
cd mcode
addpath(pwd)
savepath


wfdbdemo