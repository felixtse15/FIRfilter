#!/usr/bin/env python3
# Generate frequency plots to visually confirm FIR filter operation
# Uses fft numpy , plots saved to /documentation

import numpy as np
import matplotlib.pyplot as plt
import os
from matplotlib.ticker import FuncFormatter


# Filter specifications and constants
fs = 200000000.0
cutoff = 49000000.0
nyquistf = fs / 2
num_samples = 512
BITS = 40

# Convert hex string to signed integer
def twos_complement(hexstr):
    value = int(hexstr, 16)
    if value & (1 << (BITS - 1)):
        value -= 1 << BITS
    return value

# File paths
ref_dir = "/mnt/d/projects/FIRfilter/reference"
doc_dir = "/mnt/d/projects/FIRfilter/documentation"
input_filepath = os.path.join(ref_dir, "refmodel_chirp_output.txt")
output_filepath = os.path.join(doc_dir, "refmodel_chirp_freqplot.png")

# Load text files into numpy array for processing
refmodel_input = np.loadtxt(input_filepath, dtype=str)
input_array = np.array([twos_complement(h) for h in refmodel_input], dtype=np.int64)

# Transform time domain output signal to frequency domain with numpy fft function
Y = np.fft.fft(input_array)
freqs = np.fft.fftfreq(len(input_array), d=1/fs)
positive_freq_indices = np.where(freqs >= 0)
freqs_positive = freqs[positive_freq_indices]
Y_positive = Y[positive_freq_indices]

# Plot frequency spectrum
plt.figure(figsize=(10, 6))
plt.plot(freqs_positive, 20 * np.log10(np.abs(Y_positive) + 1e-12), label="Output Spectrum")


plt.title("Frequency Spectrum of FIR Filter Output")
plt.xlabel("Frequency in MHz")
plt.ylabel("Magnitude in dB")
plt.grid(True)
plt.xlim(0, nyquistf)
plt.ylim(-20, 120)  # Adjust ylim as needed to see your signal's spectrum clearly


# Format the x-axis to display frequency in MHz, matching your other plots.
formatter = FuncFormatter(lambda x, _: f"{x/1e6:.0f}")
plt.gca().xaxis.set_major_formatter(formatter)


# Add a vertical line at the cutoff frequency for visual reference.
plt.axvline(cutoff, color='red', linestyle='--', label='Cutoff Frequency')
plt.legend()


# Save the figure to the specified path.
plt.savefig(output_filepath)
print(f"Plot saved to {output_filepath}")
