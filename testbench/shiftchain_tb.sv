module shiftchain_tb();
	localparam WORD_WIDTH = 16;
	localparam CHAIN_DEPTH = 53;
	
	logic clk, resetn, en;
	logic signed [WORD_WIDTH - 1:0] d;
	logic signed [CHAIN_DEPTH-1:0] [WORD_WIDTH - 1:0] q ;
	
	shiftchain #(.WORD_WIDTH(WORD_WIDTH),
				 .CHAIN_DEPTH(CHAIN_DEPTH))
			dut (.en(en),
				 .clk(clk),
				 .resetn(resetn),
				 .d(d),
				 .q(q));

	
	always begin
		clk = 1;
		#10;
		clk = 0;
		#10;
	end
	
	initial begin
		$display("Starting Testbench....");
		
		// Initialize signals
		resetn = 0;
		en = 0;
		d = '0;
		
		// Deassert reset, assert enable
		#10;
		resetn = 1;
		en = 1;
		
		for (int i = 1; i < CHAIN_DEPTH; i = i + 1)
			assert(q[i] === '0) else $error("Tap %0d was not zero after reset", i);
		
		
		for (int i = 0; i > -60; i = i - 1) begin
			d = i;
			@ (posedge clk);
			
			if (i > 1) 
				assert(q[0] === (i - 1)) else $error("q[0] mismatch, expected %0d, got %0d", i - 1, q[0]);
				
		end
		
		$display("Finished data, final value in q[0] should be -58.");
		assert($signed(q[0]) === -58) else begin
			$error("q[0] mismatch, expected -58, got %0d", $signed(q[0]));
			$stop;
		end 
		$display("Final value in q[52] should be -6");
		assert($signed(q[52]) === -6) else begin
			$error ("q[52] mismatch, expected -6, got %0d", $signed(q[52]));
			$stop;
		end
		$display("Test Passed");
		$stop;
	end

endmodule