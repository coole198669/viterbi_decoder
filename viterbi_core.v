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
module viterbi_core #(parameter WIDTH_BM = 8,SRC_ADDR_W = 12 , DST_ADDR_W = 12)(
    input clk_i,
    input rst_an_i,
    input rst_sync_i,
     
    input start_i,
   
    input [1:0] register_num_i,     //0: 64-state, 1: 32-state, 2: 16-state, 3: 8-state
    input [2:0] valid_polynomials_i,//0: R=1/2,  1: R=1/3,  2: R=1/4,  3: R=1/5,  4: R=1/6, Polynomials 1,2&3 are valid
    input  tail_biting_en_i,        //0: tail-bit 1: tail-biting
    input [7:0] polynomial1_i,
    input [7:0] polynomial2_i,
    input [7:0] polynomial3_i,
    input [7:0] polynomial4_i,
    input [7:0] polynomial5_i,
    input [7:0] polynomial6_i,
	 input [9:0] infobit_length_i,
    input [9:0] decoding_length_i, //Valid when Tail-biting==1 and decodingLength>=InfoBitLength

	 //status output
	 output frame_done_o, // a pulse after one fream decoding done
	 output busy_o, // one frame is not finish
	 // sram read port for fetching softbits from input buffer
    output                   src_rd_o,
    output [SRC_ADDR_W-1:0]  src_addr_o,
	 input  [23:0]            src_rdata_i,
	  // sram write port to output buffer
	 output                   dst_wr_o,
    output [DST_ADDR_W-1:0]    dst_addr_o,
	 output [7:0]             dst_wdata_o,
	 //sram wr/rd port to traceback buffer(survival path buffer)
    output                   tb_wr_o,
    output                   tb_rd_o,
    output [5:0]             tb_addr_o,
    output [63:0]            tb_wdata_o,
	 output [63:0]            tb_rdata_i
    );

wire [23:0] soft_data_s;
wire soft_data_valid_s;
wire signed [WIDTH_BM-1:0] pm_r_s[63:0];

wire signed [WIDTH_BM-1:0] bm_s[63:0];
wire bm_valid_s[63:0];
wire bmu_ready_s[63:0];

wire is_t0_s;
wire acs_en_s[63:0];
wire signed [WIDTH_BM-1:0] pm_tmp_s[63:0];
wire survivor_path_s[63:0];
wire acs_valid_s[63:0];

wire pm_norm_en_s;
wire [5:0] max_state_index_s;
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
         .soft_data_i        (soft_data_s),
         .soft_data_valid_i  (soft_data_valid_s),
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
     
 
     
  end
 endgenerate
 
 pm_normalize pm_normalize_inst(
    .clk_i         (clk_i         ),
    .rst_an_i      (rst_an_i      ),
    .rst_sync_i    (rst_sync_i    ), 
    .en_i          (pm_norm_en_s  ),
    .register_num_i(register_num_i),
    .pm_tmp_0_i     ( pm_tms_s[0 ]),
    .pm_tmp_1_i     ( pm_tms_s[1 ]),
    .pm_tmp_2_i     ( pm_tms_s[2 ]),
    .pm_tmp_3_i     ( pm_tms_s[3 ]),
    .pm_tmp_4_i     ( pm_tms_s[4 ]),
    .pm_tmp_5_i     ( pm_tms_s[5 ]),
    .pm_tmp_6_i     ( pm_tms_s[6 ]),
    .pm_tmp_7_i     ( pm_tms_s[7 ]),
    .pm_tmp_8_i     ( pm_tms_s[8 ]),
    .pm_tmp_9_i     ( pm_tms_s[9 ]),    
    .pm_tmp_10_i    ( pm_tms_s[10]),
    .pm_tmp_11_i    ( pm_tms_s[11]),
    .pm_tmp_12_i    ( pm_tms_s[12]),
    .pm_tmp_13_i    ( pm_tms_s[13]),
    .pm_tmp_14_i    ( pm_tms_s[14]),
    .pm_tmp_15_i    ( pm_tms_s[15]),
    .pm_tmp_16_i    ( pm_tms_s[16]),
    .pm_tmp_17_i    ( pm_tms_s[17]),
    .pm_tmp_18_i    ( pm_tms_s[18]),
    .pm_tmp_19_i    ( pm_tms_s[19]),
    .pm_tmp_20_i    ( pm_tms_s[20]),
    .pm_tmp_21_i    ( pm_tms_s[21]),
    .pm_tmp_22_i    ( pm_tms_s[22]),
    .pm_tmp_23_i    ( pm_tms_s[23]),
    .pm_tmp_24_i    ( pm_tms_s[24]),
    .pm_tmp_25_i    ( pm_tms_s[25]),
    .pm_tmp_26_i    ( pm_tms_s[26]),
    .pm_tmp_27_i    ( pm_tms_s[27]),
    .pm_tmp_28_i    ( pm_tms_s[28]),
    .pm_tmp_29_i    ( pm_tms_s[29]),
    .pm_tmp_30_i    ( pm_tms_s[30]),
    .pm_tmp_31_i    ( pm_tms_s[31]),
    .pm_tmp_32_i    ( pm_tms_s[32]),
    .pm_tmp_33_i    ( pm_tms_s[33]),
    .pm_tmp_34_i    ( pm_tms_s[34]),
    .pm_tmp_35_i    ( pm_tms_s[35]),
    .pm_tmp_36_i    ( pm_tms_s[36]),
    .pm_tmp_37_i    ( pm_tms_s[37]),
    .pm_tmp_38_i    ( pm_tms_s[38]),
    .pm_tmp_39_i    ( pm_tms_s[39]),
    .pm_tmp_40_i    ( pm_tms_s[40]),
    .pm_tmp_41_i    ( pm_tms_s[41]),
    .pm_tmp_42_i    ( pm_tms_s[42]),
    .pm_tmp_43_i    ( pm_tms_s[43]),
    .pm_tmp_44_i    ( pm_tms_s[44]),
    .pm_tmp_45_i    ( pm_tms_s[45]),
    .pm_tmp_46_i    ( pm_tms_s[46]),
    .pm_tmp_47_i    ( pm_tms_s[47]),
    .pm_tmp_48_i    ( pm_tms_s[48]),
    .pm_tmp_49_i    ( pm_tms_s[49]),
    .pm_tmp_50_i    ( pm_tms_s[50]),
    .pm_tmp_51_i    ( pm_tms_s[51]),
    .pm_tmp_52_i    ( pm_tms_s[52]),
    .pm_tmp_53_i    ( pm_tms_s[53]),
    .pm_tmp_54_i    ( pm_tms_s[54]),
    .pm_tmp_55_i    ( pm_tms_s[55]),
    .pm_tmp_56_i    ( pm_tms_s[56]),
    .pm_tmp_57_i    ( pm_tms_s[57]),
    .pm_tmp_58_i    ( pm_tms_s[58]),
    .pm_tmp_59_i    ( pm_tms_s[59]),
    .pm_tmp_60_i    ( pm_tms_s[60]),
    .pm_tmp_61_i    ( pm_tms_s[61]),
    .pm_tmp_62_i    ( pm_tms_s[62]),
    .pm_tmp_63_i    ( pm_tms_s[63]),

    .pm_nom_0_o     ( pm_r_s[0 ] ),
    .pm_nom_1_o     ( pm_r_s[1 ] ),
    .pm_nom_2_o     ( pm_r_s[2 ] ),
    .pm_nom_3_o     ( pm_r_s[3 ] ),
    .pm_nom_4_o     ( pm_r_s[4 ] ),
    .pm_nom_5_o     ( pm_r_s[5 ] ),
    .pm_nom_6_o     ( pm_r_s[6 ] ),
    .pm_nom_7_o     ( pm_r_s[7 ] ),
    .pm_nom_8_o     ( pm_r_s[8 ] ),
    .pm_nom_9_o     ( pm_r_s[9 ] ), 
    .pm_nom_10_o    ( pm_r_s[10] ),
    .pm_nom_11_o    ( pm_r_s[11] ),
    .pm_nom_12_o    ( pm_r_s[12] ),
    .pm_nom_13_o    ( pm_r_s[13] ),
    .pm_nom_14_o    ( pm_r_s[14] ),
    .pm_nom_15_o    ( pm_r_s[15] ),
    .pm_nom_16_o    ( pm_r_s[16] ),
    .pm_nom_17_o    ( pm_r_s[17] ),
    .pm_nom_18_o    ( pm_r_s[18] ),
    .pm_nom_19_o    ( pm_r_s[19] ), 
    .pm_nom_20_o    ( pm_r_s[20] ),
    .pm_nom_21_o    ( pm_r_s[21] ),
    .pm_nom_22_o    ( pm_r_s[22] ),
    .pm_nom_23_o    ( pm_r_s[23] ),
    .pm_nom_24_o    ( pm_r_s[24] ),
    .pm_nom_25_o    ( pm_r_s[25] ),
    .pm_nom_26_o    ( pm_r_s[26] ),
    .pm_nom_27_o    ( pm_r_s[27] ),
    .pm_nom_28_o    ( pm_r_s[28] ),
    .pm_nom_29_o    ( pm_r_s[29] ), 
    .pm_nom_30_o    ( pm_r_s[30] ),
    .pm_nom_31_o    ( pm_r_s[31] ),
    .pm_nom_32_o    ( pm_r_s[32] ),
    .pm_nom_33_o    ( pm_r_s[33] ),
    .pm_nom_34_o    ( pm_r_s[34] ),
    .pm_nom_35_o    ( pm_r_s[35] ),
    .pm_nom_36_o    ( pm_r_s[36] ),
    .pm_nom_37_o    ( pm_r_s[37] ),
    .pm_nom_38_o    ( pm_r_s[38] ),
    .pm_nom_39_o    ( pm_r_s[39] ), 
    .pm_nom_40_o    ( pm_r_s[40] ),
    .pm_nom_41_o    ( pm_r_s[41] ),
    .pm_nom_42_o    ( pm_r_s[42] ),
    .pm_nom_43_o    ( pm_r_s[43] ),
    .pm_nom_44_o    ( pm_r_s[44] ),
    .pm_nom_45_o    ( pm_r_s[45] ),
    .pm_nom_46_o    ( pm_r_s[46] ),
    .pm_nom_47_o    ( pm_r_s[47] ),
    .pm_nom_48_o    ( pm_r_s[48] ),
    .pm_nom_49_o    ( pm_r_s[49] ),
    .pm_nom_50_o    ( pm_r_s[50] ),
    .pm_nom_51_o    ( pm_r_s[51] ),
    .pm_nom_52_o    ( pm_r_s[52] ),
    .pm_nom_53_o    ( pm_r_s[53] ),
    .pm_nom_54_o    ( pm_r_s[54] ),
    .pm_nom_55_o    ( pm_r_s[55] ),
    .pm_nom_56_o    ( pm_r_s[56] ),
    .pm_nom_57_o    ( pm_r_s[57] ),
    .pm_nom_58_o    ( pm_r_s[58] ),
    .pm_nom_59_o    ( pm_r_s[59] ),
    .pm_nom_60_o    ( pm_r_s[60] ),
    .pm_nom_61_o    ( pm_r_s[61] ),
    .pm_nom_62_o    ( pm_r_s[62] ),
    .pm_nom_63_o    ( pm_r_s[63] ),
    .max_state_index_o (max_state_index_s)
    );
 
endmodule
