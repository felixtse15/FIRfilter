#!usr/bin/env python3
# Generates test stimuli to verify the functionality of the FIR filter
# The resulting sine wave is quantized to 16-bit integers, and the result should be stored in a text file, serving as input to the filter
import numpy as np
import os
from scipy.signal import chirp


NUM_SAMPLES   = 512
SAMPLING_FREQ = 200e6           # Nyquist rate is 100MHz, oversample at 200MHz
PASSBAND_FREQ = 30e6            # 30MHz is well inside 0-45MHz passband
STOPBAND_FREQ = 70e6            # 70MHz is well inside 55-100MHz stopband
DURATION = NUM_SAMPLES / SAMPLING_FREQ
NYQUISTF = SAMPLING_FREQ / 2

DATA_WIDTH = 16

ref_dir = "/mnt/d/projects/FIRfilter/reference"
OUTPUT_FILE = os.path.join(ref_dir, "input_chirp_stimulus.txt")            # Sweep frequency/chirp test stimulus
# OUTPUT_FILE = os.path.join(ref_dir, "input_step_stimulus.txt")           # step response test stimulus
# OUTPUT_FILE = os.path.join(ref_dir, "input_twosine_stimulus.txt")        # Two sine wave test stimulus
# OUTPUT_FILE = os.path.join(ref_dir, "input_imp_stimulus.txt")            # Impulse test stimulus

# Sequence of samples, scaled to time of each sample
t = np.arange(NUM_SAMPLES) / SAMPLING_FREQ

# Generates two superimposed sine waves, one within the passband frequency and one within the stopband frequency
# Passband frequency sine wave
sine_pass = np.sin(2 * np.pi * PASSBAND_FREQ * t)

# Stopband frequency sine wave
sine_stop = np.sin(2 * np.pi * STOPBAND_FREQ * t)

# Superimpose
sine_comb_float = sine_pass + sine_stop

# Normalize the combined sine wave so that amplitude is between -1.0 and 1.0, prevents overflow for 16-bit integers later
# Divide all values in combined sine float wave by the absolute max value
sine_comb_norm = sine_comb_float / (np.max(sine_comb_float))

  

# Scaling factor (32767)
scale_factor = (2 ** (DATA_WIDTH - 1)) - 1

# Quantize the result, cast to int 
sine_quantized = np.round(sine_comb_norm * scale_factor).astype(int)

# Test stimulus array for an impulse test
impulse = np.zeros(512).astype(int)
impulse[0] = 1

# Test stimulus array for a step response test
impulse = np.zeros(512).astype(int)
impulse[:100] = 1

# Test stimulus array for frequency sweep (chirp) test, use chirp from scipy.signal
f_start = 0.0
f_end = NYQUISTF
t_chirp = np.linspace(0, DURATION, NUM_SAMPLES, endpoint=False)
chirp_signal = chirp(t_chirp, f0=f_start, t1=DURATION, f1=f_end,method='linear').astype(int)


# Write inputs as 4width hexadecimal number in text file separated by new line
with open(OUTPUT_FILE, 'w') as f:
    for sample in chirp_signal:
        hex_string = format(sample & 0xFFFF, '04x')
        f.write(f"{hex_string}\n")
    #for sample in impulse:
     #   hex_string = format(sample & 0xFFFF, '04x')
      #  f.write(f"{hex_string}\n")
    #for sample in sine_quantized:
     #   hex_string = format(sample & 0xFFFF, '04x')
      #  f.write(f"{hex_string}\n")
    #for sample in impulse:
     #   hex_string = format(sample & 0xFFFF, '04x')
      #  f.write(f"{hex_string}\n")





