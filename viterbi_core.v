`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:06:23 09/28/2018 
// Design Name: 
// Module Name:    viterbi_core 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module viterbi_core #(parameter WIDTH_BM = 20)(
    input clk_i,
    input rst_an_i,
    input rst_sync_i,
	 
	 input start_i,
	 input [23:0] soft_data_i,
	 input soft_data_valid_i,
    input [1:0] register_num_i,
    input [2:0] valid_polynomials_i,
	 input  tail_biting_en_i,
    input [7:0] polynomial1_i,
    input [7:0] polynomial2_i,
    input [7:0] polynomial3_i,
    input [7:0] polynomial4_i,
    input [7:0] polynomial5_i,
    input [7:0] polynomial6_i
    );


reg [WIDTH_BM-1:0] pm_r[63:0];

wire signed [WIDTH_BM-1:0] bm_s[63:0];
wire bm_valid_s[63:0];
wire bmu_ready_s[63:0];

wire is_t0_s;
wire acs_en_s[63:0];
wire signed [WIDTH_BM-1:0] pm_tmp_s[63:0];
wire survivor_path_s[63:0];
wire acs_valid_s[63:0];

assign is_t0_s = 0;

genvar i;
generate
   for(i=0;i<64;i=i+1)
   begin:state_trellis
	  assign acs_en_s[i] = 1'b1;
     BMU bmu_inst   (
         .clk_i              (clk_i),
         .rst_an_i           (rst_an_i),
         .rst_sync_i         (rst_sync_i),    
	     .start_i            (start_i),    // a pulse to start
         .state_x_i          (i),
         .soft_data_i        (soft_data_i),
	     .soft_data_valid_i  (soft_data_valid_i),
         .register_num_i     (register_num_i),
         .valid_polynomials_i(valid_polynomials_i),
         .polynomial1_i      (polynomial1_i),
         .polynomial2_i      (polynomial2_i),
         .polynomial3_i      (polynomial3_i),
         .polynomial4_i      (polynomial4_i),
         .polynomial5_i      (polynomial5_i),
         .polynomial6_i      (polynomial6_i),
         .ready_o            (bmu_ready_s[i]),
         .bm_o               (bm_s[i]),
         .bm_valid_o         (bm_valid_s[i])
         );
	
	ACS acs_inst  (
    .clk_i          (clk_i),
    .rst_an_i       (rst_an_i),
    .rst_sync_i     (rst_sync_i),
	.en_i           (acs_en_s[i]),
    .is_t0_i        (is_t0_s),
    .bm_i           (bm_s[i]),
    .bm_valid_i     (bm_valid_s[i]),
    .prev_low_i     (pm_r[i>>1]),
    .prev_high1_i   (pm_r[4+i>>1]),
    .prev_high2_i   (pm_r[8+i>>1]),
    .prev_high3_i   (pm_r[16+i>>1]),
    .prev_high4_i   (pm_r[32+i>>1]),
	.tail_biting_en (tail_biting_en_i),
    .state_k_i      (i),
    .pm_o           (pm_tmp_s[i]),
    .survivor_path_o(survivor_path_s[i]),
	.valid_o        (acs_valid_s[i])
    );
	 
	 always@(posedge clk_i or negedge rst_an_i) begin
	   if(!rst_an_i) 
	     pm_r[i] <= 0; 	  
      else if(rst_sync_i) 
	     pm_r[i] <= 0; 
      else if(acs_valid_s[i])	  
	     pm_r[i] <= pm_tmp_s[i];
	 end
	 
  end
 endgenerate
 
endmodule
