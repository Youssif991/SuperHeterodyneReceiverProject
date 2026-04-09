% main.m
% Authors : Youssef Hisham Ahmed, Youssef Mohammed Ibrahim
% Date : 4/4/2026
% Subject : Modulation schemes for various signals

clear; clc; close all;

%% Run Preprocessing and Modulator
preprocessing;
modulator;

%% Shared Filters Setup (IF & LPF)
F_IF = 15e3;

% IF Filtering Specs
IF_Filter_Order = 8;
IF_PassBand_Low = 5e3;
IF_PassBand_High = 30e3;
IF_Filter_Specs = fdesign.bandpass('N,F3dB1,F3dB2', IF_Filter_Order, IF_PassBand_Low, IF_PassBand_High, Fs1);
IF_filter = design(IF_Filter_Specs, 'butter'); 

% LPF Specs
LPF_Filter_Order = 8;
LPF_Cutoff = 10e3; % 10 kHz cutoff
LPF_Specs = fdesign.lowpass('N,F3dB', LPF_Filter_Order, LPF_Cutoff, Fs1);
LPF_filter = design(LPF_Specs, 'butter');

%% Channel Specific RF Filters & Oscillators
RF_Filter_Order = 26;

% Quran Channel RF Filter (100 kHz Center)
RF_PassBand_Low_Quran = 85e3;
RF_PassBand_High_Quran = 115e3;
RF_Filter_Specs_Quran = fdesign.bandpass('N,F3dB1,F3dB2', RF_Filter_Order, RF_PassBand_Low_Quran, RF_PassBand_High_Quran, Fs1);
RF_filter_Quran = design(RF_Filter_Specs_Quran, 'butter'); 
RF_output_Quran = filter(RF_filter_Quran, FDM);
F_osc_Quran = fc1 + F_IF;

% BBC Channel RF Filter (130 kHz Center)
RF_PassBand_Low_BBC = 115e3;
RF_PassBand_High_BBC = 145e3;
RF_Filter_Specs_BBC = fdesign.bandpass('N,F3dB1,F3dB2', RF_Filter_Order, RF_PassBand_Low_BBC, RF_PassBand_High_BBC, Fs1);
RF_filter_BBC = design(RF_Filter_Specs_BBC, 'butter'); 
RF_output_BBC = filter(RF_filter_BBC, FDM);
F_osc_BBC = fc2 + F_IF;

%% DEMODULATION

% Quran
current_RF_in = RF_output_Quran;
current_F_osc = F_osc_Quran;
station_name = 'Quran Channel';
current_condition = 'Ideal';
receiver;

% BBC
current_RF_in = RF_output_BBC;
current_F_osc = F_osc_BBC;
station_name = 'BBC Channel';
current_condition = 'Ideal';
receiver;

%% Q4 - NO RF Filter

% Quran Q4
current_RF_in = FDM; % Using raw FDM instead of filtered RF
current_F_osc = F_osc_Quran;
station_name = 'Quran Channel';
current_condition = 'Q4 (No BPF)';
receiver;

% BBC Q4
current_RF_in = FDM; % Using raw FDM instead of filtered RF
current_F_osc = F_osc_BBC;
station_name = 'BBC Channel';
current_condition = 'Q4 (No BPF)';
receiver;
%% Q5 - MIXER OFFSET (1 kHz)
% Quran Q5 (1kHz)
current_RF_in = RF_output_Quran;
current_F_osc = F_osc_Quran + 1e3;
station_name = 'Quran Channel';
current_condition = 'Q5 (1kHz Offset)';
receiver;

% BBC Q5 (1kHz)
current_RF_in = RF_output_BBC;
current_F_osc = F_osc_BBC + 1e3;
station_name = 'BBC Channel';
current_condition = 'Q5 (1kHz Offset)';
receiver;
%% Q5 - MIXER OFFSET (0.1 kHz)
% Quran Q5 (0.1kHz)
current_RF_in = RF_output_Quran;
current_F_osc = F_osc_Quran + 0.1e3;
station_name = 'Quran Channel';
current_condition = 'Q5 (0.1kHz Offset)';
receiver;

% BBC Q5 (0.1kHz)
current_RF_in = RF_output_BBC;
current_F_osc = F_osc_BBC + 0.1e3;
station_name = 'BBC Channel';
current_condition = 'Q5 (0.1kHz Offset)';
receiver;

disp('All processing complete!');
