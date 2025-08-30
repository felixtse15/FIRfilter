module firfilter_tb();
	
	localparam NUM_TAPS = 53;
	localparam DATA_WIDTH = 16;
	localparam COEFF_WIDTH = 16;
	localparam NUM_SAMPLES = 512;
	
	// Some derived parameters
	localparam PRODUCT_WIDTH = DATA_WIDTH + COEFF_WIDTH;
	localparam NUM_STAGES = $clog2(NUM_TAPS);
	localparam OUTPUT_WIDTH = PRODUCT_WIDTH + NUM_STAGES;
	localparam TOTAL_SUMS = NUM_SAMPLES + NUM_TAPS - 1;
	
	// Testbench signals
	logic 							  clk;
	logic 							  resetn;
	logic 							  i_valid;
	logic signed [DATA_WIDTH - 1:0]   i_data;
	logic 							  o_valid;
	logic signed [OUTPUT_WIDTH - 1:0] o_data;
	
	int errors = 0;
	int output_idx = 0;
	
	// Signals to loop through test vectors
	// logic [DATA_WIDTH - 1:0]   stim;
	// logic [OUTPUT_WIDTH - 1:0] result_act, result_exp;
	

	
	// Test vector memories
	logic signed [DATA_WIDTH - 1:0]   stimulus_mem [NUM_SAMPLES - 1:0] ;
	logic signed [OUTPUT_WIDTH - 1:0] expected_mem [TOTAL_SUMS - 1:0] ;
	logic signed [OUTPUT_WIDTH - 1:0] actual_mem   [TOTAL_SUMS - 1:0] ;
	
	firfilter #(.NUM_TAPS(NUM_TAPS),
				.DATA_WIDTH(DATA_WIDTH),
				.COEFF_WIDTH(COEFF_WIDTH))
		   dut (.clk(clk),
				.resetn(resetn),
				.i_valid(i_valid),
				.i_data(i_data),
				.o_valid(o_valid),
				.o_data(o_data));
			
	always begin
		clk = 0;
		#5;
		clk = 1;
		#5;
	end
	
	initial begin
		$display("Starting Simulation...");
		
		// Load test vectors
		$readmemh("D:/projects/FIRfilter/reference/input_stimulus.txt", stimulus_mem);
		$readmemh("D:/projects/FIRfilter/reference/refmodel_output.txt", expected_mem);
		
		// Initialize inputs
		resetn = 0;
		i_valid = 0;
		i_data = 0;
		#5;
		resetn = 1;
		@(posedge clk);
		
		// Drive the stimulus stream
		for (int i = 0; i < NUM_SAMPLES; i++) begin
			i_valid <= 1'b1;
			i_data  <= stimulus_mem[i];
			@(posedge clk);
		end
		i_valid <= 1'b0; // Stop sending new data
		
		// Wait for the pipeline to completely flush out the last results
		repeat(NUM_TAPS + 20) @(posedge clk);
		
		// Compare all captured results at the end
		$display("--- Comparing %0d Captured Samples ---", output_idx);
		for (int i = 0; i < output_idx; i++) begin
			if ((actual_mem[i] - expected_mem[i]) > 2 || (actual_mem[i] - expected_mem[i]) < -2 ) begin
				$display("ERROR at sample %0d: Expected %d, Got %d", i, expected_mem[i], actual_mem[i]);
				errors++;
			end
		end
					
		if (errors == 0) begin
			$display("SUCCESS: All %0d output samples matched!", output_idx);
		end else begin
			$display("FAILURE: Found %0d mismatches.", errors);
		end
		
		if (output_idx == NUM_SAMPLES)
			$stop;
	end
	
	// --- Output Capture Logic ---
	// This block runs in parallel, watching for valid data from the DUT
	always @(posedge clk) begin
		if (resetn && o_valid) begin
			if (output_idx < TOTAL_SUMS) begin
				actual_mem[output_idx] <= o_data;
				output_idx <= output_idx + 1;
			end
		end
	end
	
endmodule
	