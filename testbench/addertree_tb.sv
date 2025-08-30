// A simple testbench for the addertree module.
module addertree_tb();

    // Use localparams to define test configuration for clarity.
    // These must match the DUT's parameters.
    localparam INPUT_WIDTH = 16;
    localparam NUM_INPUTS  = 53;
	localparam NUM_STAGES = $clog2(NUM_INPUTS);						// number of stages required, use $clog2
				   

	localparam OUTPUT_WIDTH = INPUT_WIDTH + NUM_STAGES;

    // Signals to connect to the DUT (Device Under Test)
    logic clk;
    logic resetn;
    logic signed [NUM_INPUTS - 1:0][INPUT_WIDTH - 1:0] inputd;
    logic signed [OUTPUT_WIDTH - 1:0] sum; // Automatically calculate sum width

    // Instantiate the addertree module
    addertree #(.INPUT_WIDTH(INPUT_WIDTH),
				.NUM_INPUTS(NUM_INPUTS))
		   dut (.clk(clk),
				.resetn(resetn),
				.inputd(inputd),
				.sum(sum));

    // 1. Clock Generator
    // This block will generate a continuous clock signal.
    always begin
        clk = 0;
        #10;
        clk = 1;
        #10;
    end

    // 2. Test Sequence
    // This block defines the single test case.
    initial begin
        $display("Starting simulation...");

        // Initialize inputs
        resetn = 0; // Assert reset
        for (int i = 0; i < NUM_INPUTS; i++) 
			inputd[i] = '0;

        #10;
		resetn = 1;

        $display("Reset released. Applying test vectors.");

        // --- TEST CASE ---
        // Set all 53 inputs to the value 1.
        for (int i = 0; i < NUM_INPUTS; i++) 
            inputd[i] = 1;
        $display("Waiting for %0d pipeline stages ...", NUM_STAGES);
		repeat (NUM_STAGES + 1) @ (posedge clk);
		


        // --- VERIFICATION ---
        // At this point, the 'sum' output should be stable with the result.
        $display("-------------------------------------------");
        $display("Test Complete.");
        $display("Final Sum from DUT: %0d", sum);
        $display("Expected Sum:       53");

        // Check if the result is correct
        assert(sum === 53) else begin
            $display("FAILURE: Result does NOT match expected value.");
			$stop;
        end
		$display("Test Passed");
		$stop;
        
    end

endmodule
