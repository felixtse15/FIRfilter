module addertree #(parameter INPUT_WIDTH = 32,										// input data width
				   parameter NUM_INPUTS = 53,										// number of data inputs	
				   
				   localparam NUM_STAGES = $clog2(NUM_INPUTS),						// number of stages required, use $clog2
				   localparam NUM_INPUTS_REQ = 2 ** NUM_STAGES,						// number of inputs in hardware
				   localparam OUTPUT_WIDTH = INPUT_WIDTH + NUM_STAGES)				// output data width, each time number of sums doubles, increase output width by 1 bit

				  (input  logic clk,
				   input  logic resetn,
				   input  logic signed [INPUT_WIDTH - 1:0] inputd [NUM_INPUTS - 1:0] ,			// 2D array to hold input data
				   output logic signed [OUTPUT_WIDTH - 1:0] sum);
	
	logic signed [OUTPUT_WIDTH - 1:0] tree [NUM_STAGES:0] [NUM_INPUTS_REQ - 1:0] ;		// 3D array that represents adder tree structure
	
	// generate a series of stages and adders
	// stage 0 organizes inputs
		// first, move input data "d" into stage 0 of the tree
		// Check if the number of inputs from d is less than the number of inputs in hardware.
		// If yes, pad the remaining unused slots with zeroes
	// each stage after that consists of a bank of adders and a bank of registers
	
	genvar stage, adder;
	generate
		for (stage = 0; stage <= NUM_STAGES; stage++) begin: gen_stages
			// At each stage, the number of required hardware inputs are halved
			localparam STAGE_NUM_ADDERS = NUM_INPUTS_REQ >> stage;
			
			// At each stage, the width of the sums increases by 1 bit to account for overflow
			localparam STAGE_WIDTH = INPUT_WIDTH + stage;
			
			// Check if the number of inputs from d is less than hardware inputs
			localparam NUM_PAD = NUM_INPUTS_REQ - NUM_INPUTS;
			// Stage 0 inputs data, initial data width is INPUT_WIDTH
			// Pads unused hardware with zeroes 
			if (stage == 0) begin: gen_stage0
				always_comb begin
					// Assign data inputs to stage 0 of tree
					// Sign extension is automatic for assignment
					for (int i = 0; i < NUM_INPUTS; i++)
						tree[0][i] = inputd[i];
					
					// Check if you need to pad unused slots with zeroes
					if (NUM_PAD > 0)
						for (int i = NUM_INPUTS; i < NUM_INPUTS_REQ; i++) 
							tree[0][i] = '0;

				end //alwayscomb
			end
			
			// At all other stages, generate STAGE_INPUT adders, which should add i and i + 1 inputs, and i increments by 2 each time.
			// Pipeline the addition
			else begin: gen_adder_stages
				for (adder = 0; adder < STAGE_NUM_ADDERS; adder++) begin: gen_adders
					always_ff @ (posedge clk or negedge resetn) begin
						if(!resetn)
							tree[stage][adder] <= '0;
						else 
							// tree[stage][adder] <= $signed(tree[stage - 1][adder * 2]) + $signed(tree[stage - 1][(adder * 2) + 1]);
							tree[stage][adder] <= $signed({tree[stage - 1][adder * 2][OUTPUT_WIDTH-1], tree[stage - 1][adder * 2]}) + tree[stage - 1][(adder * 2) + 1];
					end
				end
			end
			
		end //for
	endgenerate
	
	assign sum = tree[NUM_STAGES][0];
endmodule