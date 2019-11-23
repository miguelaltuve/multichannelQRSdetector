# multichannelQRSdetector

Code of the paper Ledezma, C. A., & Altuve, M. (2019). Optimal data fusion for the improvement of QRS complex detection in multi-channel ECG recordings. Medical & biological engineering & computing, 1-9. https://doi.org/10.1007/s11517-019-01990-3

The multi-channel detection approach was validated using six different single-channel QRS complex detectors: Pan and Tompkins [1], Benítez et al. [2], Ramakrishnan et al. [3], and PhysioNet’s detectors GQRS, WQRS and SQRS [4,5]. The detectors were applied to two multi-channel ECG databases: MIT-BIH Arrhythmia and INCART.

The following MATLAB functions correspond to the single-channel QRS complex detectors:
1. pan_tompkin.m: Pan and Tompkins filter-based detection method [1]. Coded by Hooman Sedghamiz, Linkoping university.
2. detectHT.m: Benítez et al. Hilbert transform-based detection method [2].
3. dpi_qrs.m: the Ramakrishnan et al. dynamic plosion index-based detection method [3].

We first computed the detections of QRS complexes on each ECG channel and the performance of the QRS complex detectors. This is done in the singlechannel_detection_performance_main.m file. Then, we performed the fusion of the single-channel detections and computed the performances using the multichannel_detector_performance_main.m file. In this file, the weighting coefficients $\alpha$ and the decision threshold $\beta$ are estimated (in the training period). The performance of the detectors was evaluated using the MATLAB wrapper function bxb.

## Abstract
The automatic analysis of the electrocardiogram (ECG) begins, traditionally, with the detection of QRS complexes. Afterwards, useful information can be extracted from it, ranging from the estimation of the instantaneous heart rate to nonlinear heart rate variability analysis. A plethora of works have been published on this topic; consequently, there exist many QRS complex detectors with high-performance values. However, just a few detectors have been conceived that profit from the information contained in several ECG leads to provide a robust QRS complex detection. In this work, we explore the fusion of multi-channel ECG recordings QRS detections as a means to improve the detection performance. This paper presents a decentralized multi-channel QRS complex fusion scheme that optimally combines single-channel detections to produce a single detection signal. Using six different widely used QRS complex detectors on the MIT-BIH Arrhythmia and INCART databases, a reduction in false and missed detections was achieved with the proposed approach compared with the single-channel counterpart. Furthermore, our detection results are comparable with the performance of other multi-channel detectors found in the literature, showing, in turn, various advantages in scalability, adaptability, and simplicity in the system’s implementation

## References

[1] Pan, J., & Tompkins, W. J. (1985). A real-time QRS detection algorithm. IEEE Trans. Biomed. Eng, 32(3), 230-236.

[2] Benitez, D. S., Gaydecki, P. A., Zaidi, A., & Fitzpatrick, A. P. (2000, September). A new QRS detection algorithm based on the Hilbert transform. In Computers in Cardiology 2000. Vol. 27 (Cat. 00CH37163) (pp. 379-382). IEEE.

[3] Ramakrishnan, A. G., Prathosh, A. P., & Ananthapadmanabha, T. V. (2014). Threshold-independent QRS detection using the dynamic plosion index. IEEE Signal Processing Letters, 21(5), 554-558.

[4] Silva, I., & Moody, G. B. (2014). An open-source toolbox for analysing and processing physionet databases in matlab and octave. Journal of open research software, 2(1).

[5] Goldberger, A. L., Amaral, L. A., Glass, L., Hausdorff, J. M., Ivanov, P. C., Mark, R. G., ... & Stanley, H. E. (2000). PhysioBank, PhysioToolkit, and PhysioNet: components of a new research resource for complex physiologic signals. Circulation, 101(23), e215-e220.

