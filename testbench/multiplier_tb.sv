module multiplier_tb ();
	localparam WORD_WIDTH = 16;
	localparam COEFF_WIDTH = 16;
	
	logic signed [WORD_WIDTH - 1:0] d;
	logic signed [COEFF_WIDTH - 1:0] coeff;
	logic signed [WORD_WIDTH + COEFF_WIDTH - 1:0] product;
	
	multiplier #(.WORD_WIDTH(WORD_WIDTH),
				 .COEFF_WIDTH(COEFF_WIDTH))
			dut (.d(d),
				 .coeff(coeff),
				 .product(product));
	
	initial begin
		$display("Starting Testbench...");

		// Test some edge cases
		// Multiplication by 0
		d = '0; coeff = '0; #10;
		assert (product === '0) else begin
			$error("Expected 0, got %0d", product);
			$stop;
		end
		d = 1; coeff = '0; #10;
		assert (product === '0) else begin
			$error("Expected 0, got %0d", product);
			$stop;
		end
	
		// Multiplication by 1
		d = 20; coeff = 1; #10;
		assert (product === 20) else begin
			$error("Expected 20, got %0d", product);
			$stop;
		end
		// Multiplication of max negative bound by max negative bound
		d = -16384; coeff = -16384; #10;
		assert (product === 268435456) else begin
			$error("Expected 268435456, got %0d", product);
			$stop;
		end
		// Multiplication by max negative bound by max positive bound
		d = -16384; coeff = 16384; #10;
		assert (product === -268435456) else begin
			$error("Expected -268435456, got %0d", product);
			$stop;
		end
		// Multiplication by max positive bound by max positive bound
		d = 16384; coeff = 16384; #10;
		assert (product === 268435456) else begin
			$error("Expected 268435456, got %0d", product);
			$stop;
		end
		// Multiplication overflow
		
	end
endmodule
	