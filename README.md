# Adaptive-Chaotic-Modulation-for-SatCom
ECE-UY-3404 Fundamentals of Communication Theory

Spring 2026 Final project

## Pipeline overview
1) Input: Signal / Image+Llyod-Max (i.e. Start Tracker data)
2) Channel:  AWGN / AWGN+interference
3) Linear SNR esimator
4) ACM transceiver: linear (QAM/QPSK/BPSK) / chaotic (CSK)
--> Performance metrics: BER vs SNR, BER vs Throughput, Reconstructed image, RMSE comparison table 

### Supporting functions
adaptive_controller.m
mod_qam.m: (M: 2= BPSK, 4= QPSK, 16= 16QAM)
mod_csk.m: CSK

## Adaptive Coding and Modulation (ACM)
1) Estimator
* Predicts next SNR
* trend: based on slope of SNR. switch to CSK if signal strength fades into noise
* Robust against scintillation (high-freq ionospheric disturbance)
2) Adaptive controller
* [16-QAM] <---- [QPSK] <---- [BPSK] <---- [CSK]
* (Fast; Need high SNR)        (Robust; Latency)
* switches mod scheme based on environment
* targetBER: determines controller behavior for tradeoff
* tradeoff between speed (throughput) and reliability (SNR resilience)
* sampling frequency must stay the same 
    * QAM/BPSK: length(tx_sig) = bitsPerPacket / log2(M) * nov
    * CSK: length(tx_sig) = bitsPerPacket * nov
* assumption: controller has interference detector (if channel == AWGN or AWGN+inteference)

## n.b. CSK: parameter justification
* Chaotic map & Bifurcation Diagram (Adapted from ECE-UY-3404 Lab 6)
* Using the nonlinear map: x_{n+1} = a*cos(x_n)
* Lyapunov Exponent (LLE) measures sensitivity to initial conditions. A positive LLE means sensitive dependence on initial conditions, meaning the system is chaotic. LLE becomes positive for a>2. 
(comment out to save gpu rendering)
