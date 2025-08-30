#!usr/bin/env python3
# Golden reference model, calculates the same convolution as firfilter.sv hardware module using Python integer arithmetic
# Takes the same coefficient file and stimulus file as inputs, outputs a text file which is read into firfilter_tb and directly compare


import numpy as np
import os

# Declare some constants
BITS = 16

# Convert a hex string to a signed integer
def twos_complement(hexstr):
    value = int(hexstr, 16)
    if value & (1 << (BITS - 1)):
        value -= 1 << BITS
    return value
    


# Input and output files
ref_dir = "/mnt/d/projects/FIRfilter/reference"
COEFF_INPUT    = os.path.join(ref_dir, "fir_coeff.txt")
STIMULUS_INPUT = os.path.join(ref_dir, "input_chirp_stimulus.txt") 
# "input_step_stimulus.txt"
# "input_imp_stimulus.txt"  
# "input_twosine_stimulus.txt"    

OUTPUT_FILE    = os.path.join(ref_dir, "refmodel_chirp_output.txt")
# "refmodel_step_output.txt" 
# "refmodel_twosine_output.txt"
# "refmodel_impulse_output.txt"

# Load text files into a numpy array for processing using np.loadtxt, specify data type as string
input_stimulus  = np.loadtxt(STIMULUS_INPUT, dtype=str)
coeffs = np.loadtxt(COEFF_INPUT, dtype=str)

# int(value, base) converts a value of base into an integer number
input_array = np.array([twos_complement(h) for h in input_stimulus], dtype=np.int64)
coeff_array = np.array([twos_complement(h) for h in coeffs], dtype=np.int64)

# Implement full convolution, which pads input data with zeroes
# Create an output array of zeroes, set as 64bit int to buffer large numbers
N = len(input_array)        #512
M = len(coeff_array)        #53
num_outputs = N + M - 1     #564
output_array = np.zeros(num_outputs, dtype=np.int64)

# Outer loop iterates through each output sample (512)
# Inner loop iterates through coefficients 
# Calculate the index of the input sample needed, if less than 0, no multiplication (essentially zero padding)
for n in range(num_outputs):
    sum = 0
    for m in range(M):
        index = n - m
        
        if index >= 0 and index < N:
            sum += coeff_array[m] * input_array[index]
    output_array[n] = sum


with open(OUTPUT_FILE, 'w') as f:
    for sum in output_array:
        hex_string = format(sum & 0xFFFFFFFFFF, '010x')
        f.write(f"{hex_string}\n")

