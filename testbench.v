`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:10:53 09/28/2018
// Design Name:   tb
// Module Name:   C:/Users/Administrator/Desktop/Viterbi Decoder/code/viterbi_decoder/testbench.v
// Project Name:  viterbi_decoder
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: tb
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module tb(
    );
reg clk;
reg a,b;

always #10 clk=~clk;

initial begin
   clk=0;
	a=0;
	b=1;
	#100 a=1;
	b=0;
	#1000;
	$finish;

end

endmodule

/*
module testbench;

	// Outputs
	wire ;

	// Instantiate the Unit Under Test (UUT)
	tb uut (
		.()
	);

	initial begin
		// Initialize Inputs

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

*/