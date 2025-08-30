#!/usr/bin/env python3
# Generates filter coefficients for the FIR filter using Kaiser window
# Kaiser window selected for tunable parameter to make explicit specification for stopband attenuation
import numpy as np
import matplotlib.pyplot as plt
import os
from scipy import signal
from matplotlib.ticker import FuncFormatter


# Define filter specifications (in Hz)
# Odd number of taps for linear phase filter
# Coeff width for quantization  
numtaps = 53
cutoff = 49000000.0
fs = 200000000.0
nyquistf = fs / 2
coeff_width = 16
stopb_att = 60.0

# Use this empirical formula to calculate Kaiser beta for stopband attenuation greater than 50
beta = 0.1102 * (stopb_att - 8.7)



# Generate floating point coefficients using scipy.signal.firwin, which designs a windowed FIR filter
# Cutoff parameter is normalized to nyquist frequency
# Pass_zero=True indicates low pass filter (False for high pass)
float_coeffs = signal.firwin(numtaps, cutoff / nyquistf, width=None, window=('kaiser', beta), pass_zero=True)



# Quantize coefficients to fixed point
# Use np.round to round elements of an array to nearest integer, cast to int
scale_factor = (2**(coeff_width - 1)) - 1
fixed_coeffs = np.round(float_coeffs * scale_factor).astype(int)
print(fixed_coeffs)


# Export fixed-point coefficients to a file
# Convert integers to 4 width hex characters. Use & with a mask to ensure negative numbers are correctly represented
# Dynamically calculate required hexadecimal width in case coeff_width is changed later
with open("/mnt/d/projects/FIRfilter/reference/fir_coeff.txt", 'w') as f:
    for coeff in fixed_coeffs:
        hex_string = format(coeff & (2**coeff_width - 1), f'0{coeff_width // 4}x')
        f.write(f"{hex_string}\n")
        
        
# -------- PLOT 1: FIXED POINT ------------------------        
# Verify and plot frequency response of fixed-point
# Use signal.freqz, which takes the numerator and denominator of the transfer function
w_fix, h_fix = signal.freqz(fixed_coeffs, 1, worN=2048)

# Convert normalized frequency back to Hz
freq_hz_fix = (w_fix / np.pi) * nyquistf

plt.figure(figsize=(10,6))

# Plot the frequency response, convert complex magnitude to dB 
plt.plot(freq_hz_fix, 20*np.log10(abs(h_fix)), label="Magnitude Response in dB")
plt.title("FIR Filter Frequency Response: Normalized Fixed Point")
plt.xlabel("Frequency in MHz")
plt.ylabel("Magnitude in dB")
plt.grid(True)
plt.xlim(0, nyquistf)
plt.ylim(-40, 125)
formatter = FuncFormatter(lambda x, _: f"{x/1e6:.0f}")
plt.gca().xaxis.set_major_formatter(formatter)
plt.axvline(cutoff, color='red', linestyle='--', label='Cutoff Frequency')
plt.legend()

# Save the figure to /documentation directory
doc_dir = "/mnt/d/projects/FIRfilter/documentation"
filepath = os.path.join(doc_dir, "fir_freq_response_fix.png")
plt.savefig(filepath)


# --------- PLOT 2: FLOATING POINT ---------------------
w_float, h_float = signal.freqz(float_coeffs, 1, worN=2048)
freq_hz_float = (w_float / np.pi) * nyquistf

plt.figure(figsize=(10, 6))
plt.plot(freq_hz_float, 20 * np.log10(abs(h_float)), label="Magnitude Response in dB")
plt.title("FIR Filter Frequency Response: Floating Point")
plt.xlabel("Frequency in MHz")
plt.ylabel("Frequency in dB")
plt.grid(True)
plt.xlim(0, nyquistf)
plt.ylim(-140, 10)
formatter = FuncFormatter(lambda x, _: f"{x/1e6:.0f}")
plt.gca().xaxis.set_major_formatter(formatter)
plt.axvline(cutoff, color='red', linestyle='--', label="Cutoff Frequency")
plt.legend()

filepath = os.path.join(doc_dir, "fir_freq_response_float.png")
plt.savefig(filepath)
