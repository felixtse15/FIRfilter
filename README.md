# Pipelined FIR Low-Pass Filter for 5G FR1 Baseband
This project is a RTL implementation, in SystemVerilog, of a Finite Impulse Response (FIR) low-pass filter

# Key Features
- Parameterizable filter taps to allow for different filter specifications
- Pipelined adder tree to increase throughput of operations
- Kaiser window method selected to specify stopband attenuation for more optimal filtering
- 16-bit fixed-point quantization is a common standard in DSP systems, and chosen for its balance between precision and hardware efficiency

# Filter Specifications and Implementation Details
- The target application is Frequency Range 1 of 5G. The max bandwidth is 100MHz, when demodulated to baseband and centered around 0Hz,
  the signal occupies the frequency range from 0Hz to 50MHz. Sampling rate is therefore 100MHz, oversampled to 200MHz to account for error and
  noise
- Considering the implementation of a low-pass filter, key performance metrics are a sharp roll off (narrower bandwidth) and minimized passband
  ripple, and good stopband attenuation. Reasonably, passband ripple: 0.01, stopband attenuation: 0.001 (-60dB). Transition band: 10MHz
- From [1], a formula for generally estimating the number of taps N for a linear phase filter was used: N = 53 taps
- Cutoff frequency is 49Hz (at 50Hz results in half-band filter)

# Filter Architecture
Implemented using direct-form pipelined architecture. Total latency is 1 cycle for input register, N cycles for N filter stages, and 1 cycle for  output register

# Python Scripts and Verification
- generate_filter_coefficients.py generates coefficients for FIR filter based on specifications above and Kaiser windowing method
- generate_stimulus.py generates text file containing input test vectors for multi-tone sine, impulse and step responses, and frequency sweep
- reference_model.py takes input text file from generate_stimulus.py and performs exact calculation of the convolution equation
- generate_frequency_plots.py takes output from reference_model.py and plots the output in the frequency domain
- firfilter_tb.sv takes the output from reference_model.py and self checks against the output from RTL
- addertree_tb.sv, multiplier_tb.sv, shiftchain_tb.sv test some basic edge cases to ensure functionality of respective modules

# Input/Output Files and Documentation
- All input and output samples/test vectors are stored in /reference
- All associated plots, images, and screenshots of verified RTL time-domain response in ModelSim are stored in /documentation

# References
[1] Maurice Bellanger, _Digital Processing of Signals - Theory and Practice_
