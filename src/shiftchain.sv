module shiftchain #(parameter DATA_WIDTH = 16,									// work with 16-bit word
				    parameter CHAIN_DEPTH = 53)									// 53 registers for 53 taps
				
				   (input  logic en,											// shift enable
					input  logic clk,											// clock
					input  logic resetn,										// async active low reset
					input  logic signed [DATA_WIDTH - 1:0] d,							// data in
					output logic signed [DATA_WIDTH - 1:0] q [CHAIN_DEPTH - 1:0]);	// data out
	
	logic signed [DATA_WIDTH - 1:0] regchain [CHAIN_DEPTH-1:0] ;
	
	always_ff @ (posedge clk or negedge resetn) begin
		if (!resetn) 											
			// on reset, clear all registers in the chain
			for (int i = 0; i < CHAIN_DEPTH; i = i + 1) 
				regchain[i] <= '0;
		else
			if (en) begin
				regchain[0] <= d;
				
				for (int i = 1; i < CHAIN_DEPTH; i = i + 1) 
					regchain[i] <= regchain[i - 1];
			end
	end
	
	assign q = regchain;
endmodule