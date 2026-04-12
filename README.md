# Superheterodyne Receiver & FDM Simulation

## Project Overview
This repository contains a MATLAB-based simulation of a Frequency Division Multiplexed (FDM) communication system employing Double-Sideband Suppressed-Carrier (DSB-SC) amplitude modulation and a Superheterodyne Receiver. 

The project was developed as part of the EECG232-17: Introduction to Communication Systems course at Cairo University, Faculty of Engineering.

## Features & System Architecture
The simulation effectively models the complete communication pipeline:

* **Signal Pre-processing:** Reads standard audio files (Quran and BBC radio channels), converts stereo to mono, zero-pads for equal length, and upsamples to ensure Nyquist compliance.
* **Transmitter (AM Modulator):** Employs DSB-SC modulation to multiplex the baseband signals using FDM. The channels are separated by a 30 kHz spacing, starting from a base carrier frequency of 100 kHz.
* **Superheterodyne Receiver:**
  * **RF Front-End:** Uses a tunable RF Band-Pass Filter (BPF) to select the desired channel and reject image frequencies.
  * **Mixer & Local Oscillator:** Utilizes high-side injection to down-convert the RF signal to the Intermediate Frequency.
  * **IF Stage:** Applies a fixed 15 kHz IF Band-Pass Filter for strict channel selectivity and interference removal.
  * **Baseband Detection:** Recovers the original message using synchronous detection and Low-Pass Filtering (LPF).
* **System Analysis:** Evaluates the impact of hardware imperfections by simulating Local Oscillator frequency offsets (0.1 kHz and 1 kHz) and demonstrates the image frequency problem by removing the RF BPF.

## Prerequisites
To run this simulation, you will need:
* **MATLAB** (with the Signal Processing Toolbox for filter design and processing functions).
* Provided audio files (Short_QuranPalestine.wav and Short_BBCArabic2.wav) placed in the correct directory.
## Repository Structure
* `AnalogCommProject.m`: The main executable script that drives the simulation.
* `receiver.m`: Contains the logic for the RF filtering, mixing, and IF stages.
* `plot_spectra.m`: Helper function to generate the frequency domain plots.
* `modulator.m`: Contains the modulating stage and all the needed operations for modulation
* `preprocessing.m`: Contains the parameters used across the project

## Getting Started

### 1. Clone the Repository
Open your terminal and run the following commands:
```bash
git clone https://github.com/Youssif991/SuperHeterodyneReceiverProject.git
cd SuperHeterodyneReceiverProject
```
### 2. Running the Code and Hearing the Audio

To run the simulation and listen to the processed audio signals, follow these steps:

1. **Open MATLAB:** Launch MATLAB and set your "Current Folder" to the cloned `SuperHeterodyneReceiverProject` directory.
2. **Prepare Audio Files:** Ensure your source audio files (`Short_QuranPalestine.wav` and `Short_BBCArabic2.wav`) are placed in the root of the project folder alongside the scripts.
3. **Run the Simulation:** Open the main script file (e.g., `main.m`). Run the script by clicking the green **Run** button in the Editor tab or by typing the script's name in the Command Window and pressing Enter.
4. **View Plots and Listen:** * The script will generate and display the spectrum plots for the RF, IF, and baseband stages automatically.
   * **You do not need to run any extra commands to hear the audio.** The code automatically utilizes MATLAB's `sound()` function to play the demodulated audio for each test case (Ideal, No RF BPF, and with Local Oscillator offsets). 
   * *Note: The script uses a `pause()` command to wait for each audio clip to finish before moving to the next one. Please ensure your computer's audio is unmuted and the volume is turned up.*
  
## Acknowledgments
This project was developed for the **EECG232-17: Introduction to Communication Systems** course at Cairo University. Special thanks to the teaching staff for their guidance throughout the semester.

## License
This project is for educational purposes. Feel free to use it as a reference for understanding Superheterodyne receivers and FDM systems!

## Authors
- [@Youssif991](https://github.com/Youssif991)
- [@youssefteam18-boop](https://github.com/youssefteam18-boop)
