module firfilter #(parameter NUM_TAPS = 53,
				   parameter DATA_WIDTH = 16,
				   parameter COEFF_WIDTH = 16,
				   
				   // Derived parameters
				   localparam PRODUCT_WIDTH = DATA_WIDTH + COEFF_WIDTH,
				   localparam NUM_STAGES = $clog2(NUM_TAPS),
				   localparam NUM_INPUTS_REQ = 2 ** NUM_STAGES,
				   localparam OUTPUT_WIDTH = PRODUCT_WIDTH + NUM_STAGES,
				   localparam LATENCY = NUM_STAGES + 2)				// Pipeline latency
				   
				  (input  logic clk,
				   input  logic resetn,
				   input  logic i_valid,
				   input  logic signed [DATA_WIDTH - 1:0] i_data,
				   output logic o_valid,
				   output logic signed [OUTPUT_WIDTH - 1:0] o_data);
	
	// ROM to store filter coefficients from Python script
	logic signed [COEFF_WIDTH - 1:0] COEFFS [NUM_TAPS - 1:0];	
	
	initial begin
		$readmemh("D:/projects/FIRfilter/reference/fir_coeff.txt", COEFFS);
	end
	
	// Internal logic signals
	logic signed [DATA_WIDTH - 1:0]    shift_data   [NUM_TAPS - 1:0] ;				// Output from shiftchain.sv
	logic signed [PRODUCT_WIDTH - 1:0] product      [NUM_TAPS - 1:0] ;
	logic signed [PRODUCT_WIDTH - 1:0] reg_products [NUM_TAPS - 1:0] ;
	
	// Shiftchain instantiation
	shiftchain #(.DATA_WIDTH(DATA_WIDTH), 
				 .CHAIN_DEPTH(NUM_TAPS))
     shiftchain (.en(i_valid), 
				 .clk(clk), 
				 .resetn(resetn), 
				 .d(i_data), 
				 .q(shift_data));
	
	// Multiplier generation
	genvar i;
	generate
		for (i = 0; i < NUM_TAPS; i++) begin
			multiplier #(.DATA_WIDTH(DATA_WIDTH), 
						 .COEFF_WIDTH(COEFF_WIDTH))
			 multiplier (.din(shift_data[i]), 
					     .coeff(COEFFS[i]), 
						 .product(product[i]));
		end
	endgenerate
	
	// Addertree instantiation
	addertree #(.INPUT_WIDTH(PRODUCT_WIDTH), 
				.NUM_INPUTS(NUM_TAPS))
	 addertree (.clk(clk), 
			    .resetn(resetn), 
				.inputd(reg_products), 
				.sum(o_data));
			  
	// Pipeline and validity logic
	// Move results from multipliers into a pipeline register
	always_ff @ (posedge clk or negedge resetn) begin
		if (!resetn)
			for (int j = 0; j < NUM_TAPS; j++)
				reg_products[j] <= '0;
		else
			for (int j = 0; j < NUM_TAPS; j++)
				reg_products[j] <= product[j];
	end
	
	 // This shift register delays the input valid signal by the total
    // arithmetic latency to align it with the output data.
    logic [LATENCY-1:0] valid_pipe;
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) 
            valid_pipe <= '0;
        else 
            valid_pipe <= {valid_pipe[LATENCY-2:0], i_valid};
        
    end
    
    assign o_valid = valid_pipe[LATENCY-1];
	
endmodule