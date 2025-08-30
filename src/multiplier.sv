module multiplier #(parameter DATA_WIDTH = 16,
					parameter COEFF_WIDTH = 16)
					
				   (input  logic signed [DATA_WIDTH - 1:0] din,
				    input  logic signed [COEFF_WIDTH - 1:0] coeff,
					output logic signed [DATA_WIDTH + COEFF_WIDTH - 1:0] product);
					
	
	assign product = din * coeff;

endmodule