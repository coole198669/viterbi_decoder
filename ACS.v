`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:16:28 10/03/2018 
// Design Name: 
// Module Name:    ACS 
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
module ACS #(parameter WIDTH_BM = 9) (
    input clk_i,
    input rst_an_i,
    input rst_sync_i,
    input en_i,
	 input [1:0] register_num_i,
    //input is_t0_i,
    input [WIDTH_BM-1:0] bm_i,
    input bm_valid_i,
    input [WIDTH_BM-1:0] prev_low_i,
    input [WIDTH_BM-1:0] prev_high1_i,
    input [WIDTH_BM-1:0] prev_high2_i,
    input [WIDTH_BM-1:0] prev_high3_i,
    input [WIDTH_BM-1:0] prev_high4_i,
    input tail_biting_en_i,
    input [5:0] state_k_i,
    output [WIDTH_BM-1:0] pm_o,
    output survivor_path_o,
    output valid_o
    );

    parameter  Initial_Lower = -128;   
    parameter  Initial_Upper = 127;

    reg  [WIDTH_BM-1:0] prev_high_s;
    wire signed [WIDTH_BM-1:0] prev_high_tmp_s;
    wire signed [WIDTH_BM-1:0] prev_low_tmp_s;
    wire signed [WIDTH_BM-1:0] pm_high_s;
    wire signed [WIDTH_BM-1:0] pm_low_s;
    wire signed [WIDTH_BM-1:0] bm_s;
    //wire signed [WIDTH_BM-1:0] init_prev_s;
    //wire signed [WIDTH_BM-1:0] init_state0_s;
    
    
    reg valid_r;
    reg survivor_path_r;
    reg signed [WIDTH_BM-1:0] pm_r;

    assign valid_o = valid_r;
    assign survivor_path_o = survivor_path_r;
    assign pm_o = pm_r;
    
    always@( state_k_i or register_num_i or prev_high1_i or prev_high2_i or prev_high3_i or prev_high4_i ) begin
	     case(register_num_i)
		    2'b00: prev_high_s = prev_high4_i;
          2'b01: prev_high_s = prev_high3_i;
          2'b10: prev_high_s = prev_high2_i;
          2'b11: prev_high_s = prev_high1_i;
		    default: prev_high_s = 0;
		  endcase
    end
    
	 //assign init_state0_s = state_k_i==0 ? 0 :Initial_Lower;
    //assign init_prev_s = tail_biting_en_i ? 0 : init_state0_s;    
    //assign prev_low_tmp_s  = i s_t0_i ? init_prev_s : $signed(prev_low_i);
    //assign prev_high_tmp_s = is_t0_i ? init_prev_s : $signed(prev_high_s);
	 assign prev_low_tmp_s  =  $signed(prev_low_i);
    assign prev_high_tmp_s =  $signed(prev_high_s);
    assign bm_s        = $signed(bm_i);
    assign pm_low_s    = prev_low_tmp_s + bm_s;
    assign pm_high_s   = prev_high_tmp_s - bm_s;
    
    
    
    //generate pm and survivor path
    always@(posedge clk_i or negedge rst_an_i) begin
      if(!rst_an_i) begin 
        valid_r <= 1'b0;
        survivor_path_r <= 1'b0;
        pm_r <= 0;    
      end
      else if(rst_sync_i | ~en_i) begin 
        valid_r <= 1'b0;
        survivor_path_r <= 1'b0;
        pm_r <= 0;       
      end
      else if( bm_valid_i ) begin 
        valid_r <= 1'b1;
        if( pm_low_s >= pm_high_s ) begin
          survivor_path_r <= 1'b0;
          pm_r <= pm_low_s;  
        end 
        else begin
          survivor_path_r <= 1'b1;
          pm_r <= pm_high_s;     
        end     
      end
      else begin
        valid_r <= 1'b0;
        survivor_path_r <= 1'b0;
        pm_r <= 0;
      end
    end
    
endmodule
