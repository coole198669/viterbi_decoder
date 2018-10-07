`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:06:23 09/28/2018 
// Design Name: 
// Module Name:    pm_normalize
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
module pm_normalize (parameter WIDTH_BM = 8)(
    input clk_i,
    input rst_an_i,
    input rst_sync_i,
	input en_i,
	input [1:0] register_num_i,
    input [WIDTH_BM-1:0] pm_tmp_0_i,
    input [WIDTH_BM-1:0] pm_tmp_1_i,
    input [WIDTH_BM-1:0] pm_tmp_2_i,
    input [WIDTH_BM-1:0] pm_tmp_3_i,
	input [WIDTH_BM-1:0] pm_tmp_4_i,
    input [WIDTH_BM-1:0] pm_tmp_5_i,
    input [WIDTH_BM-1:0] pm_tmp_6_i,
    input [WIDTH_BM-1:0] pm_tmp_7_i,
	input [WIDTH_BM-1:0] pm_tmp_8_i,
    input [WIDTH_BM-1:0] pm_tmp_9_i,
	
    input [WIDTH_BM-1:0] pm_tmp_10_i,
    input [WIDTH_BM-1:0] pm_tmp_11_i,
    input [WIDTH_BM-1:0] pm_tmp_12_i,
    input [WIDTH_BM-1:0] pm_tmp_13_i,
	input [WIDTH_BM-1:0] pm_tmp_14_i,
    input [WIDTH_BM-1:0] pm_tmp_15_i,
    input [WIDTH_BM-1:0] pm_tmp_16_i,
    input [WIDTH_BM-1:0] pm_tmp_17_i,
	input [WIDTH_BM-1:0] pm_tmp_18_i,
    input [WIDTH_BM-1:0] pm_tmp_19_i,
	
	input [WIDTH_BM-1:0] pm_tmp_20_i,
    input [WIDTH_BM-1:0] pm_tmp_21_i,
    input [WIDTH_BM-1:0] pm_tmp_22_i,
    input [WIDTH_BM-1:0] pm_tmp_23_i,
	input [WIDTH_BM-1:0] pm_tmp_24_i,
    input [WIDTH_BM-1:0] pm_tmp_25_i,
    input [WIDTH_BM-1:0] pm_tmp_26_i,
    input [WIDTH_BM-1:0] pm_tmp_27_i,
	input [WIDTH_BM-1:0] pm_tmp_28_i,
    input [WIDTH_BM-1:0] pm_tmp_29_i,
	
	input [WIDTH_BM-1:0] pm_tmp_30_i,
    input [WIDTH_BM-1:0] pm_tmp_31_i,
    input [WIDTH_BM-1:0] pm_tmp_32_i,
    input [WIDTH_BM-1:0] pm_tmp_33_i,
	input [WIDTH_BM-1:0] pm_tmp_34_i,
    input [WIDTH_BM-1:0] pm_tmp_35_i,
    input [WIDTH_BM-1:0] pm_tmp_36_i,
    input [WIDTH_BM-1:0] pm_tmp_37_i,
	input [WIDTH_BM-1:0] pm_tmp_38_i,
    input [WIDTH_BM-1:0] pm_tmp_39_i,
	
	input [WIDTH_BM-1:0] pm_tmp_40_i,
    input [WIDTH_BM-1:0] pm_tmp_41_i,
    input [WIDTH_BM-1:0] pm_tmp_42_i,
    input [WIDTH_BM-1:0] pm_tmp_43_i,
	input [WIDTH_BM-1:0] pm_tmp_44_i,
    input [WIDTH_BM-1:0] pm_tmp_45_i,
    input [WIDTH_BM-1:0] pm_tmp_46_i,
    input [WIDTH_BM-1:0] pm_tmp_47_i,
	input [WIDTH_BM-1:0] pm_tmp_48_i,
    input [WIDTH_BM-1:0] pm_tmp_49_i,
	
    input [WIDTH_BM-1:0] pm_tmp_50_i,
    input [WIDTH_BM-1:0] pm_tmp_51_i,
    input [WIDTH_BM-1:0] pm_tmp_52_i,
    input [WIDTH_BM-1:0] pm_tmp_53_i,
	input [WIDTH_BM-1:0] pm_tmp_54_i,
    input [WIDTH_BM-1:0] pm_tmp_55_i,
    input [WIDTH_BM-1:0] pm_tmp_56_i,
    input [WIDTH_BM-1:0] pm_tmp_57_i,
	input [WIDTH_BM-1:0] pm_tmp_58_i,
    input [WIDTH_BM-1:0] pm_tmp_59_i,
	
    input [WIDTH_BM-1:0] pm_tmp_60_i,
    input [WIDTH_BM-1:0] pm_tmp_61_i,
    input [WIDTH_BM-1:0] pm_tmp_62_i,
    input [WIDTH_BM-1:0] pm_tmp_63_i,

    output [WIDTH_BM-1:0] pm_nom_0_o,
    output [WIDTH_BM-1:0] pm_nom_1_o,
    output [WIDTH_BM-1:0] pm_nom_2_o,
    output [WIDTH_BM-1:0] pm_nom_3_o,
	output [WIDTH_BM-1:0] pm_nom_4_o,
    output [WIDTH_BM-1:0] pm_nom_5_o,
    output [WIDTH_BM-1:0] pm_nom_6_o,
    output [WIDTH_BM-1:0] pm_nom_7_o,
	output [WIDTH_BM-1:0] pm_nom_8_o,
    output [WIDTH_BM-1:0] pm_nom_9_o,
	
    output [WIDTH_BM-1:0] pm_nom_10_o,
    output [WIDTH_BM-1:0] pm_nom_11_o,
    output [WIDTH_BM-1:0] pm_nom_12_o,
    output [WIDTH_BM-1:0] pm_nom_13_o,
	output [WIDTH_BM-1:0] pm_nom_14_o,
    output [WIDTH_BM-1:0] pm_nom_15_o,
    output [WIDTH_BM-1:0] pm_nom_16_o,
    output [WIDTH_BM-1:0] pm_nom_17_o,
	output [WIDTH_BM-1:0] pm_nom_18_o,
    output [WIDTH_BM-1:0] pm_nom_19_o,
	
	output [WIDTH_BM-1:0] pm_nom_20_o,
    output [WIDTH_BM-1:0] pm_nom_21_o,
    output [WIDTH_BM-1:0] pm_nom_22_o,
    output [WIDTH_BM-1:0] pm_nom_23_o,
	output [WIDTH_BM-1:0] pm_nom_24_o,
    output [WIDTH_BM-1:0] pm_nom_25_o,
    output [WIDTH_BM-1:0] pm_nom_26_o,
    output [WIDTH_BM-1:0] pm_nom_27_o,
	output [WIDTH_BM-1:0] pm_nom_28_o,
    output [WIDTH_BM-1:0] pm_nom_29_o,
	
	output [WIDTH_BM-1:0] pm_nom_30_o,
    output [WIDTH_BM-1:0] pm_nom_31_o,
    output [WIDTH_BM-1:0] pm_nom_32_o,
    output [WIDTH_BM-1:0] pm_nom_33_o,
	output [WIDTH_BM-1:0] pm_nom_34_o,
    output [WIDTH_BM-1:0] pm_nom_35_o,
    output [WIDTH_BM-1:0] pm_nom_36_o,
    output [WIDTH_BM-1:0] pm_nom_37_o,
	output [WIDTH_BM-1:0] pm_nom_38_o,
    output [WIDTH_BM-1:0] pm_nom_39_o,
	
	output [WIDTH_BM-1:0] pm_nom_40_o,
    output [WIDTH_BM-1:0] pm_nom_41_o,
    output [WIDTH_BM-1:0] pm_nom_42_o,
    output [WIDTH_BM-1:0] pm_nom_43_o,
	output [WIDTH_BM-1:0] pm_nom_44_o,
    output [WIDTH_BM-1:0] pm_nom_45_o,
    output [WIDTH_BM-1:0] pm_nom_46_o,
    output [WIDTH_BM-1:0] pm_nom_47_o,
	output [WIDTH_BM-1:0] pm_nom_48_o,
    output [WIDTH_BM-1:0] pm_nom_49_o,
	
    output [WIDTH_BM-1:0] pm_nom_50_o,
    output [WIDTH_BM-1:0] pm_nom_51_o,
    output [WIDTH_BM-1:0] pm_nom_52_o,
    output [WIDTH_BM-1:0] pm_nom_53_o,
	output [WIDTH_BM-1:0] pm_nom_54_o,
    output [WIDTH_BM-1:0] pm_nom_55_o,
    output [WIDTH_BM-1:0] pm_nom_56_o,
    output [WIDTH_BM-1:0] pm_nom_57_o,
	output [WIDTH_BM-1:0] pm_nom_58_o,
    output [WIDTH_BM-1:0] pm_nom_59_o,
	
    output [WIDTH_BM-1:0] pm_nom_60_o,
    output [WIDTH_BM-1:0] pm_nom_61_o,
    output [WIDTH_BM-1:0] pm_nom_62_o,
    output [WIDTH_BM-1:0] pm_nom_63_o,
	
	output [5:0] max_state_index_o,
	
);

	parameter  Initial_Lower = -128;   
	parameter  Initial_Upper = 127;

	wire signed [WIDTH_BM-1:0] pm_i_signed_s[63:0];
	
	
reg signed [WIDTH_BM-1:0] pm_nom_r[63:0];
reg [63:0] pm_update_en_s;
reg signed [WIDTH_BM-1:0] final_max_matric_s;
reg [5:0]  final_state_index_s;
reg [5:0] max_state_index_r,
wire [5:0] state_8_0_s , state_8_1_s ,  state_8_2_s ,  state_8_3_s ; 
wire [5:0] state_16_0_s, state_16_1_s,  state_16_2_s,  state_16_3_s ; 
wire [5:0] state_24_0_s, state_24_1_s,  state_24_2_s,  state_24_3_s ; 
wire [5:0] state_32_0_s, state_32_1_s,  state_32_2_s,  state_32_3_s ; 
wire [5:0] state_40_0_s, state_40_1_s,  state_40_2_s,  state_40_3_s ; 
wire [5:0] state_48_0_s, state_48_1_s,  state_48_2_s,  state_48_3_s ; 
wire [5:0] state_56_0_s, state_56_1_s,  state_56_2_s,  state_56_3_s ; 
wire [5:0] state_64_0_s, state_64_1_s,  state_64_2_s,  state_64_3_s ; 


wire [5:0] state_8_00_s ,  state_8_01_s , state_16_00_s,  state_16_01_s; 
wire [5:0] state_24_00_s,  state_24_01_s, state_32_00_s,  state_32_01_s; 
wire [5:0] state_40_00_s,  state_40_01_s, state_48_00_s,  state_48_01_s; 
wire [5:0] state_56_00_s,  state_56_01_s, state_64_00_s,  state_64_01_s; 

wire signed [WIDTH_BM-1:0] max_matric_8_0_s ,  max_matric_8_1_s ,  max_matric_8_2_s , max_matric_8_3_s ; 
wire signed [WIDTH_BM-1:0] max_matric_16_0_s,  max_matric_16_1_s,  max_matric_16_2_s, max_matric_16_3_s ; 
wire signed [WIDTH_BM-1:0] max_matric_24_0_s,  max_matric_24_1_s,  max_matric_24_2_s, max_matric_24_3_s ; 
wire signed [WIDTH_BM-1:0] max_matric_32_0_s,  max_matric_32_1_s,  max_matric_32_2_s, max_matric_32_3_s ;   
wire signed [WIDTH_BM-1:0] max_matric_40_0_s,  max_matric_40_1_s,  max_matric_40_2_s, max_matric_40_3_s ; 
wire signed [WIDTH_BM-1:0] max_matric_48_0_s,  max_matric_48_1_s,  max_matric_48_2_s, max_matric_48_3_s ; 
wire signed [WIDTH_BM-1:0] max_matric_56_0_s,  max_matric_56_1_s,  max_matric_56_2_s, max_matric_56_3_s ; 
wire signed [WIDTH_BM-1:0] max_matric_64_0_s,  max_matric_64_1_s,  max_matric_64_2_s, max_matric_64_3_s ;                 


wire signed [WIDTH_BM-1:0] max_matric_8_00_s , max_matric_8_01_s , max_matric_16_00_s, max_matric_16_01_s ;
wire signed [WIDTH_BM-1:0] max_matric_24_00_s, max_matric_24_01_s, max_matric_32_00_s, max_matric_32_01_s ;
wire signed [WIDTH_BM-1:0] max_matric_40_00_s, max_matric_40_01_s, max_matric_48_00_s, max_matric_48_01_s ;
wire signed [WIDTH_BM-1:0] max_matric_56_00_s, max_matric_56_01_s, max_matric_64_00_s, max_matric_64_01_s ;

wire [5:0] state_8_s, state_16_s, state_24_s, state_32_s, state_40_s, state_48_s, state_56_s, state_64_s ; 
wire signed [WIDTH_BM-1:0] max_matric_8_s, max_matric_16_s, max_matric_24_s, max_matric_32_s, max_matric_40_s, max_matric_48_s, max_matric_56_s, max_matric_64_s ;

wire [5:0]  state_2nd_0_s, state_2nd_1_s, state_2nd_2_s, state_2nd_3_s;
wire [5:0] state_2nd_00_s,state_2nd_01_s, max_state_s ;
wire signed [WIDTH_BM-1:0] max_matric_2nd_0_s, max_matric_2nd_1_s,max_matric_2nd_2_s,max_matric_2nd_3_s;
wire signed [WIDTH_BM-1:0] max_matric_2nd_00_s,max_matric_2nd_01_s,max_matric_s;

wire [5:0] max_state_8_s,  max_state_16_s,max_state_32_s,  max_state_64_s;
wire signed [WIDTH_BM-1:0]   nom_matric_8_s,  nom_matric_16_s, nom_matric_32_s,  nom_matric_64_s;
 
assign max_state_8_s = state_8_s;
assign max_state_16_s = state_2nd_0_s;
assign max_state_32_s = state_2nd_00_s;
assign max_state_64_s = max_state_s;

assign nom_matric_8_s = max_matric_8_s;
assign nom_matric_16_s = max_matric_2nd_0_s ;
assign nom_matric_32_s = max_matric_2nd_00_s;
assign nom_matric_64_s = max_matric_s;
	
assign pm_i_signed_s[0] = $signed(pm_tmp_0_i);
assign pm_i_signed_s[1] = $signed(pm_tmp_1_i);
assign pm_i_signed_s[2] = $signed(pm_tmp_2_i);
assign pm_i_signed_s[3] = $signed(pm_tmp_3_i);
assign pm_i_signed_s[4] = $signed(pm_tmp_4_i);
assign pm_i_signed_s[5] = $signed(pm_tmp_5_i);
assign pm_i_signed_s[6] = $signed(pm_tmp_6_i);
assign pm_i_signed_s[7] = $signed(pm_tmp_7_i);
assign pm_i_signed_s[8] = $signed(pm_tmp_8_i);
assign pm_i_signed_s[9] = $signed(pm_tmp_9_i);

assign pm_i_signed_s[10] = $signed(pm_tmp_10_i);
assign pm_i_signed_s[11] = $signed(pm_tmp_11_i);
assign pm_i_signed_s[12] = $signed(pm_tmp_12_i);
assign pm_i_signed_s[13] = $signed(pm_tmp_13_i);
assign pm_i_signed_s[14] = $signed(pm_tmp_14_i);
assign pm_i_signed_s[15] = $signed(pm_tmp_15_i);
assign pm_i_signed_s[16] = $signed(pm_tmp_16_i);
assign pm_i_signed_s[17] = $signed(pm_tmp_17_i);
assign pm_i_signed_s[18] = $signed(pm_tmp_18_i);
assign pm_i_signed_s[19] = $signed(pm_tmp_19_i);
                                      
assign pm_i_signed_s[20] = $signed(pm_tmp_20_i);
assign pm_i_signed_s[21] = $signed(pm_tmp_21_i);
assign pm_i_signed_s[22] = $signed(pm_tmp_22_i);
assign pm_i_signed_s[23] = $signed(pm_tmp_23_i);
assign pm_i_signed_s[24] = $signed(pm_tmp_24_i);
assign pm_i_signed_s[25] = $signed(pm_tmp_25_i);
assign pm_i_signed_s[26] = $signed(pm_tmp_26_i);
assign pm_i_signed_s[27] = $signed(pm_tmp_27_i);
assign pm_i_signed_s[28] = $signed(pm_tmp_28_i);
assign pm_i_signed_s[29] = $signed(pm_tmp_29_i);
                                        
assign pm_i_signed_s[30] = $signed(pm_tmp_30_i);
assign pm_i_signed_s[31] = $signed(pm_tmp_31_i);
assign pm_i_signed_s[32] = $signed(pm_tmp_32_i);
assign pm_i_signed_s[33] = $signed(pm_tmp_33_i);
assign pm_i_signed_s[34] = $signed(pm_tmp_34_i);
assign pm_i_signed_s[35] = $signed(pm_tmp_35_i);
assign pm_i_signed_s[36] = $signed(pm_tmp_36_i);
assign pm_i_signed_s[37] = $signed(pm_tmp_37_i);
assign pm_i_signed_s[38] = $signed(pm_tmp_38_i);
assign pm_i_signed_s[39] = $signed(pm_tmp_39_i);
                                      
assign pm_i_signed_s[40] = $signed(pm_tmp_40_i);
assign pm_i_signed_s[41] = $signed(pm_tmp_41_i);
assign pm_i_signed_s[42] = $signed(pm_tmp_42_i);
assign pm_i_signed_s[43] = $signed(pm_tmp_43_i);
assign pm_i_signed_s[44] = $signed(pm_tmp_44_i);
assign pm_i_signed_s[45] = $signed(pm_tmp_45_i);
assign pm_i_signed_s[46] = $signed(pm_tmp_46_i);
assign pm_i_signed_s[47] = $signed(pm_tmp_47_i);
assign pm_i_signed_s[48] = $signed(pm_tmp_48_i);
assign pm_i_signed_s[49] = $signed(pm_tmp_49_i);
                                       
assign pm_i_signed_s[50] = $signed(pm_tmp_50_i);
assign pm_i_signed_s[51] = $signed(pm_tmp_51_i);
assign pm_i_signed_s[52] = $signed(pm_tmp_52_i);
assign pm_i_signed_s[53] = $signed(pm_tmp_53_i);
assign pm_i_signed_s[54] = $signed(pm_tmp_54_i);
assign pm_i_signed_s[55] = $signed(pm_tmp_55_i);
assign pm_i_signed_s[56] = $signed(pm_tmp_56_i);
assign pm_i_signed_s[57] = $signed(pm_tmp_57_i);
assign pm_i_signed_s[58] = $signed(pm_tmp_58_i);
assign pm_i_signed_s[59] = $signed(pm_tmp_59_i);
                                        
assign pm_i_signed_s[60] = $signed(pm_tmp_60_i);
assign pm_i_signed_s[61] = $signed(pm_tmp_61_i);
assign pm_i_signed_s[62] = $signed(pm_tmp_62_i);
assign pm_i_signed_s[63] = $signed(pm_tmp_63_i);	

assign pm_nom_0_o  = pm_nom_r[0];
assign pm_nom_1_o  = pm_nom_r[1];
assign pm_nom_2_o  = pm_nom_r[2];
assign pm_nom_3_o  = pm_nom_r[3];
assign pm_nom_4_o  = pm_nom_r[4];
assign pm_nom_5_o  = pm_nom_r[5];
assign pm_nom_6_o  = pm_nom_r[6];
assign pm_nom_7_o  = pm_nom_r[7];
assign pm_nom_8_o  = pm_nom_r[8];
assign pm_nom_9_o  = pm_nom_r[9];
assign pm_nom_10_o = pm_nom_r[10];
assign pm_nom_11_o = pm_nom_r[11];
assign pm_nom_12_o = pm_nom_r[12];
assign pm_nom_13_o = pm_nom_r[13];
assign pm_nom_14_o = pm_nom_r[14];
assign pm_nom_15_o = pm_nom_r[15];
assign pm_nom_16_o = pm_nom_r[16];
assign pm_nom_17_o = pm_nom_r[17];
assign pm_nom_18_o = pm_nom_r[18];
assign pm_nom_19_o = pm_nom_r[19];
assign pm_nom_20_o = pm_nom_r[20];
assign pm_nom_21_o = pm_nom_r[21];
assign pm_nom_22_o = pm_nom_r[22];
assign pm_nom_23_o = pm_nom_r[23];
assign pm_nom_24_o = pm_nom_r[24];
assign pm_nom_25_o = pm_nom_r[25];
assign pm_nom_26_o = pm_nom_r[26];
assign pm_nom_27_o = pm_nom_r[27];
assign pm_nom_28_o = pm_nom_r[28];
assign pm_nom_29_o = pm_nom_r[29];
assign pm_nom_30_o = pm_nom_r[30];
assign pm_nom_31_o = pm_nom_r[31];
assign pm_nom_32_o = pm_nom_r[32];
assign pm_nom_33_o = pm_nom_r[33];
assign pm_nom_34_o = pm_nom_r[34];
assign pm_nom_35_o = pm_nom_r[35];
assign pm_nom_36_o = pm_nom_r[36];
assign pm_nom_37_o = pm_nom_r[37];
assign pm_nom_38_o = pm_nom_r[38];
assign pm_nom_39_o = pm_nom_r[39];
assign pm_nom_40_o = pm_nom_r[40];
assign pm_nom_41_o = pm_nom_r[41];
assign pm_nom_42_o = pm_nom_r[42];
assign pm_nom_43_o = pm_nom_r[43];
assign pm_nom_44_o = pm_nom_r[44];
assign pm_nom_45_o = pm_nom_r[45];
assign pm_nom_46_o = pm_nom_r[46];
assign pm_nom_47_o = pm_nom_r[47];
assign pm_nom_48_o = pm_nom_r[48];
assign pm_nom_49_o = pm_nom_r[49];
assign pm_nom_50_o = pm_nom_r[50];
assign pm_nom_51_o = pm_nom_r[51];
assign pm_nom_52_o = pm_nom_r[52];
assign pm_nom_53_o = pm_nom_r[53];
assign pm_nom_54_o = pm_nom_r[54];
assign pm_nom_55_o = pm_nom_r[55];
assign pm_nom_56_o = pm_nom_r[56];
assign pm_nom_57_o = pm_nom_r[57];
assign pm_nom_58_o = pm_nom_r[58];
assign pm_nom_59_o = pm_nom_r[59];
assign pm_nom_60_o = pm_nom_r[60];
assign pm_nom_61_o = pm_nom_r[61];
assign pm_nom_62_o = pm_nom_r[62];
assign pm_nom_63_o = pm_nom_r[63]; 
 
genvar i;
generate
   for(i=0;i<64;i=i+1)
   begin:pm_reg
     always@(posedge clk_i or negedge rst_an_i) begin
	   if(!rst_an_i) 
	     pm_nom_r[i] <= 0; 	  
      else if(rst_sync_i) 
	     pm_nom_r[i] <= 0; 
      else if(en_i & pm_update_en_s[i])	begin 
         if((pm_i_signed_s[i]-final_max_matric_s)>Initial_Upper)	  
	        pm_nom_r[i] <= Initial_Upper;
		 else if((pm_i_signed_s[i]-final_max_matric_s)<Initial_Lower)
            pm_nom_r[i] <= Initial_Lower;	
         else			
		    pm_nom_r[i] <=pm_i_signed_s[i]-final_max_matric_s;
		 end
	 end	 
   end
endgenerate

assign max_state_index_o = max_state_index_r;

always@(posedge clk_i or negedge rst_an_i) begin
	   if(!rst_an_i) 
	     max_state_index_r <= 0; 	  
      else if(rst_sync_i) 
	     max_state_index_r <= 0; 
      else if(en_i)	 
         max_state_index_r <=  final_state_index_s;
   end
   
 always@(*) begin
   case(register_num_i)
   2'b00: final_max_matric_s = nom_matric_64_s ;
   2'b01: final_max_matric_s = nom_matric_32_s ;
   2'b10: final_max_matric_s = nom_matric_16_s ;
   default: final_max_matric_s = nom_matric_8_s ;
   endcase
 end
 
  always@(*) begin
   case(register_num_i)
   2'b00: final_state_index_s = max_state_64_s  ;
   2'b01: final_state_index_s = max_state_32_s  ;
   2'b10: final_state_index_s = max_state_16_s  ;
   default: final_state_index_s = max_state_8_s ;
   endcase
 end
 
  always@(*) begin
   case(register_num_i)
   2'b00:   pm_update_en_s = 64'hFFFFFFFF_FFFFFFFF ;
   2'b01:   pm_update_en_s = 64'h00000000_FFFFFFFF  ;
   2'b10:   pm_update_en_s = 64'h00000000_0000FFFF  ;
   default: pm_update_en_s = 64'h00000000_000000FF  ;
   endcase
 end
//---------------------------------------------------------------------
//      select the max metric of state 0 ~ 7
//---------------------------------------------------------------------	
	assign state_8_0_s =  pm_i_signed_s[0] >= pm_i_signed_s[1] ? 6'h0 : 6'h1;
	assign state_8_1_s =  pm_i_signed_s[2] >= pm_i_signed_s[3] ? 6'h2 : 6'h3;
	assign state_8_2_s =  pm_i_signed_s[4] >= pm_i_signed_s[5] ? 6'h4 : 6'h5;
	assign state_8_3_s =  pm_i_signed_s[6] >= pm_i_signed_s[7] ? 6'h6 : 6'h7;
	
	assign max_matric_8_0_s =  pm_i_signed_s[0]>=pm_i_signed_s[1] ? pm_i_signed_s[0] : pm_i_signed_s[1];
    assign max_matric_8_1_s =  pm_i_signed_s[2]>=pm_i_signed_s[3] ? pm_i_signed_s[2] : pm_i_signed_s[3];
	assign max_matric_8_2_s =  pm_i_signed_s[4]>=pm_i_signed_s[5] ? pm_i_signed_s[4] : pm_i_signed_s[5];
	assign max_matric_8_3_s =  pm_i_signed_s[6]>=pm_i_signed_s[7] ? pm_i_signed_s[6] : pm_i_signed_s[7];
	
	assign state_8_00_s = max_matric_8_0_s >= max_matric_8_1_s ? state_8_0_s : state_8_1_s;
	assign state_8_01_s = max_matric_8_2_s >= max_matric_8_3_s ? state_8_2_s : state_8_3_s;
	
	assign max_matric_8_00_s =  max_matric_8_0_s>=max_matric_8_1_s ? max_matric_8_0_s : max_matric_8_1_s;
	assign max_matric_8_01_s =  max_matric_8_2_s>=max_matric_8_3_s ? max_matric_8_2_s : max_matric_8_3_s;
	
	assign state_8_s = max_matric_8_00_s  >= max_matric_8_01_s  ? state_8_00_s : state_8_01_s;
	assign max_matric_8_s = mmax_matric_8_00_s >= max_matric_8_01_s ? max_matric_8_00_s : max_matric_8_01_s;
	
//---------------------------------------------------------------------
//      select the max metric of state 8 ~ 15
//---------------------------------------------------------------------	
	assign state_16_0_s =  pm_i_signed_s[8] >=pm_i_signed_s[9] ? 6'h8 : 6'h9;
	assign state_16_1_s =  pm_i_signed_s[10]>=pm_tmp_11_s ? 6'ha : 6'hb;
	assign state_16_2_s =  pm_tmp_12_s>=pm_tmp_13_s ? 6'hc : 6'hd;
	assign state_16_3_s =  pm_tmp_14_s>=pm_tmp_15_s ? 6'he : 6'hf;
	
	assign max_matric_16_0_s =  pm_i_signed_s[8] >=pm_i_signed_s[9]  ? pm_i_signed_s[8] : pm_i_signed_s[9];
    assign max_matric_16_1_s =  pm_i_signed_s[10]>=pm_i_signed_s[11] ? pm_i_signed_s[10] : pm_i_signed_s[11];
	assign max_matric_16_2_s =  pm_i_signed_s[12]>=pm_i_signed_s[13] ? pm_i_signed_s[12] : pm_i_signed_s[13];
	assign max_matric_16_3_s =  pm_i_signed_s[14]>=pm_i_signed_s[15] ? pm_i_signed_s[14] : pm_i_signed_s[15];
	
	assign state_16_00_s = max_matric_16_0_s >= max_matric_16_1_s ? state_16_0_s : state_16_1_s;
	assign state_16_01_s = max_matric_16_2_s >= max_matric_16_3_s ? state_16_2_s : state_16_3_s;
	
	assign max_matric_16_00_s =  max_matric_16_0_s>=max_matric_16_1_s ? max_matric_16_0_s : max_matric_16_1_s;
	assign max_matric_16_01_s =  max_matric_16_2_s>=max_matric_16_3_s ? max_matric_16_2_s : max_matric_16_3_s;
	
	assign state_16_s = max_matric_16_00_s  >= max_matric_16_01_s  ? state_16_00_s : state_16_01_s;
	assign max_matric_16_s = mmax_matric_16_00_s >= max_matric_16_01_s ? max_matric_16_00_s : max_matric_16_01_s;	
	
//---------------------------------------------------------------------
//      select the max metric of state 16 ~ 23
//---------------------------------------------------------------------	
	assign state_24_0_s =  pm_i_signed_s[16]>=pm_i_signed_s[17] ? 6'h10 : 6'h11;
	assign state_24_1_s =  pm_i_signed_s[18]>=pm_i_signed_s[19] ? 6'h12 : 6'h13;
	assign state_24_2_s =  pm_i_signed_s[20]>=pm_i_signed_s[21] ? 6'h14 : 6'h15;
	assign state_24_3_s =  pm_i_signed_s[22]>=pm_i_signed_s[23] ? 6'h16 : 6'h17;
	
	assign max_matric_24_0_s =  pm_i_signed_s[16]>=pm_i_signed_s[17]  ? pm_i_signed_s[16] : pm_i_signed_s[17] ;
    assign max_matric_24_1_s =  pm_i_signed_s[18]>=pm_i_signed_s[19]  ? pm_i_signed_s[18] : pm_i_signed_s[19] ;
	assign max_matric_24_2_s =  pm_i_signed_s[20]>=pm_i_signed_s[21]  ? pm_i_signed_s[20] : pm_i_signed_s[21] ;
	assign max_matric_24_3_s =  pm_i_signed_s[22]>=pm_i_signed_s[23]  ? pm_i_signed_s[22] : pm_i_signed_s[23] ;
	
	assign state_24_00_s = max_matric_24_0_s >= max_matric_24_1_s ? state_24_0_s : state_24_1_s;
	assign state_24_01_s = max_matric_24_2_s >= max_matric_24_3_s ? state_24_2_s : state_24_3_s;
	
	assign max_matric_24_00_s =  max_matric_24_0_s>=max_matric_24_1_s ? max_matric_24_0_s : max_matric_24_1_s;
	assign max_matric_24_01_s =  max_matric_24_2_s>=max_matric_24_3_s ? max_matric_24_2_s : max_matric_24_3_s;
	
	assign state_24_s = max_matric_24_00_s  >= max_matric_24_01_s  ? state_24_00_s : state_24_01_s;
	assign max_matric_24_s = mmax_matric_24_00_s >= max_matric_24_01_s ? max_matric_24_00_s : max_matric_24_01_s;

//---------------------------------------------------------------------
//      select the max metric of state 24 ~ 31
//---------------------------------------------------------------------	
	assign state_32_0_s =  pm_i_signed_s[24]>=pm_i_signed_s[25] ? 6'h18 : 6'h19;
	assign state_32_1_s =  pm_i_signed_s[26]>=pm_i_signed_s[27] ? 6'h1a : 6'h1b;
	assign state_32_2_s =  pm_i_signed_s[28]>=pm_i_signed_s[29] ? 6'h1c : 6'h1d;
	assign state_32_3_s =  pm_i_signed_s[30]>=pm_i_signed_s[31] ? 6'h1e : 6'h1f;
	
	assign max_matric_32_0_s =  pm_i_signed_s[24]>=pm_i_signed_s[25] ? pm_i_signed_s[24]: pm_i_signed_s[25];
    assign max_matric_32_1_s =  pm_i_signed_s[26]>=pm_i_signed_s[27] ? pm_i_signed_s[26]: pm_i_signed_s[27];
	assign max_matric_32_2_s =  pm_i_signed_s[28]>=pm_i_signed_s[29] ? pm_i_signed_s[28]: pm_i_signed_s[29];
	assign max_matric_32_3_s =  pm_i_signed_s[30]>=pm_i_signed_s[31] ? pm_i_signed_s[30]: pm_i_signed_s[31];
	
	assign state_32_00_s = max_matric_32_0_s >= max_matric_32_1_s ? state_32_0_s : state_32_1_s;
	assign state_32_01_s = max_matric_32_2_s >= max_matric_32_3_s ? state_32_2_s : state_32_3_s;
	
	assign max_matric_32_00_s =  max_matric_32_0_s>=max_matric_32_1_s ? max_matric_32_0_s : max_matric_32_1_s;
	assign max_matric_32_01_s =  max_matric_32_2_s>=max_matric_32_3_s ? max_matric_32_2_s : max_matric_32_3_s;
	
	assign state_32_s = max_matric_32_00_s  >= max_matric_32_01_s  ? state_32_00_s : state_32_01_s;
	assign max_matric_32_s = mmax_matric_32_00_s >= max_matric_32_01_s ? max_matric_32_00_s : max_matric_32_01_s;

//---------------------------------------------------------------------
//      select the max metric of state 32 ~ 39
//---------------------------------------------------------------------	
	assign state_40_0_s =  pm_i_signed_s[32] >= pm_i_signed_s[33] ? 6'd32 : 6'd33;
	assign state_40_1_s =  pm_i_signed_s[34] >= pm_i_signed_s[35] ? 6'd34 : 6'd35;
	assign state_40_2_s =  pm_i_signed_s[36] >= pm_i_signed_s[37] ? 6'd36 : 6'd37;
	assign state_40_3_s =  pm_i_signed_s[38] >= pm_i_signed_s[39] ? 6'd38 : 6'd39;
	
	assign max_matric_40_0_s =  pm_i_signed_s[32] >= pm_i_signed_s[33] ? pm_i_signed_s[32] : pm_i_signed_s[33];
    assign max_matric_40_1_s =  pm_i_signed_s[34] >= pm_i_signed_s[35] ? pm_i_signed_s[34] : pm_i_signed_s[35];
	assign max_matric_40_2_s =  pm_i_signed_s[36] >= pm_i_signed_s[37] ? pm_i_signed_s[36] : pm_i_signed_s[37];
	assign max_matric_40_3_s =  pm_i_signed_s[38] >= pm_i_signed_s[39] ? pm_i_signed_s[38] : pm_i_signed_s[39];
	
	assign state_40_00_s = max_matric_40_0_s >= max_matric_40_1_s ? state_40_0_s : state_40_1_s;
	assign state_40_01_s = max_matric_40_2_s >= max_matric_40_3_s ? state_40_2_s : state_40_3_s;
	
	assign max_matric_40_00_s =  max_matric_40_0_s>=max_matric_40_1_s ? max_matric_40_0_s : max_matric_40_1_s;
	assign max_matric_40_01_s =  max_matric_40_2_s>=max_matric_40_3_s ? max_matric_40_2_s : max_matric_40_3_s;
	
	assign state_40_s = max_matric_40_00_s  >= max_matric_40_01_s  ? state_40_00_s : state_40_01_s;
	assign max_matric_40_s = mmax_matric_40_00_s >= max_matric_40_01_s ? max_matric_40_00_s : max_matric_40_01_s;
	
//---------------------------------------------------------------------
//      select the max metric of state 40 ~ 47
//---------------------------------------------------------------------	
	assign state_48_0_s =  pm_i_signed_s[40]>=pm_i_signed_s[41] ? 6'd40 : 6'd41;
	assign state_48_1_s =  pm_i_signed_s[42]>=pm_i_signed_s[43] ? 6'd42 : 6'd43;
	assign state_48_2_s =  pm_i_signed_s[44]>=pm_i_signed_s[45] ? 6'd44 : 6'd45;
	assign state_48_3_s =  pm_i_signed_s[46]>=pm_i_signed_s[47] ? 6'd46 : 6'd47;
	
	assign max_matric_48_0_s =  pm_i_signed_s[40]>=pm_i_signed_s[41] ? pm_i_signed_s[40] : pm_i_signed_s[41];
    assign max_matric_48_1_s =  pm_i_signed_s[42]>=pm_i_signed_s[43] ? pm_i_signed_s[42] : pm_i_signed_s[43];
	assign max_matric_48_2_s =  pm_i_signed_s[44]>=pm_i_signed_s[45] ? pm_i_signed_s[44] : pm_i_signed_s[45];
	assign max_matric_48_3_s =  pm_i_signed_s[46]>=pm_i_signed_s[47] ? pm_i_signed_s[46] : pm_i_signed_s[47];
	
	assign state_48_00_s = max_matric_48_0_s >= max_matric_48_1_s ? state_48_0_s : state_48_1_s;
	assign state_48_01_s = max_matric_48_2_s >= max_matric_48_3_s ? state_48_2_s : state_48_3_s;
	
	assign max_matric_48_00_s =  max_matric_48_0_s>=max_matric_48_1_s ? max_matric_48_0_s : max_matric_48_1_s;
	assign max_matric_48_01_s =  max_matric_48_2_s>=max_matric_48_3_s ? max_matric_48_2_s : max_matric_48_3_s;
	
	assign state_48_s = max_matric_48_00_s  >= max_matric_48_01_s  ? state_48_00_s : state_48_01_s;
	assign max_matric_48_s = mmax_matric_48_00_s >= max_matric_48_01_s ? max_matric_48_00_s : max_matric_48_01_s;	
	
//---------------------------------------------------------------------
//      select the max metric of state 48 ~ 55
//---------------------------------------------------------------------	
	assign state_56_0_s =  pm_i_signed_s[48]>=pm_i_signed_s[49] ? 6'd48 : 6'd49;
	assign state_56_1_s =  pm_i_signed_s[50]>=pm_i_signed_s[51] ? 6'd50 : 6'd51;
	assign state_56_2_s =  pm_i_signed_s[52]>=pm_i_signed_s[53] ? 6'd52 : 6'd53;
	assign state_56_3_s =  pm_i_signed_s[54]>=pm_i_signed_s[55] ? 6'd54 : 6'd55;
	
	assign max_matric_56_0_s =  pm_i_signed_s[48]>=pm_i_signed_s[49] ? pm_i_signed_s[48] : pm_i_signed_s[49];
    assign max_matric_56_1_s =  pm_i_signed_s[50]>=pm_i_signed_s[51] ? pm_i_signed_s[50] : pm_i_signed_s[51];
	assign max_matric_56_2_s =  pm_i_signed_s[52]>=pm_i_signed_s[53] ? pm_i_signed_s[52] : pm_i_signed_s[53];
	assign max_matric_56_3_s =  pm_i_signed_s[54]>=pm_i_signed_s[55] ? pm_i_signed_s[54] : pm_i_signed_s[55];
	
	assign state_56_00_s = max_matric_56_0_s >= max_matric_56_1_s ? state_56_0_s : state_56_1_s;
	assign state_56_01_s = max_matric_56_2_s >= max_matric_56_3_s ? state_56_2_s : state_56_3_s;
	
	assign max_matric_56_00_s =  max_matric_56_0_s>=max_matric_56_1_s ? max_matric_56_0_s : max_matric_56_1_s;
	assign max_matric_56_01_s =  max_matric_56_2_s>=max_matric_56_3_s ? max_matric_56_2_s : max_matric_56_3_s;
	
	assign state_56_s = max_matric_56_00_s  >= max_matric_56_01_s  ? state_56_00_s : state_56_01_s;
	assign max_matric_56_s = mmax_matric_56_00_s >= max_matric_56_01_s ? max_matric_56_00_s : max_matric_56_01_s;

//---------------------------------------------------------------------
//      select the max metric of state 56 ~ 63
//---------------------------------------------------------------------	
	assign state_64_0_s =  pm_i_signed_s[56]>=pm_i_signed_s[57] ? 6'd56 : 6'd57;
	assign state_64_1_s =  pm_i_signed_s[58]>=pm_i_signed_s[59] ? 6'd58 : 6'd59;
	assign state_64_2_s =  pm_i_signed_s[60]>=pm_i_signed_s[61] ? 6'd60 : 6'd61;
	assign state_64_3_s =  pm_i_signed_s[62]>=pm_i_signed_s[63] ? 6'd62 : 6'd63;
	
	assign max_matric_64_0_s =  pm_i_signed_s[56]>=pm_i_signed_s[57] ? pm_i_signed_s[56]>=pm_i_signed_s[57];
    assign max_matric_64_1_s =  pm_i_signed_s[58]>=pm_i_signed_s[59] ? pm_i_signed_s[58]>=pm_i_signed_s[59];
	assign max_matric_64_2_s =  pm_i_signed_s[60]>=pm_i_signed_s[61] ? pm_i_signed_s[60]>=pm_i_signed_s[61];
	assign max_matric_64_3_s =  pm_i_signed_s[62]>=pm_i_signed_s[63] ? pm_i_signed_s[62]>=pm_i_signed_s[63];
	
	assign state_64_00_s = max_matric_64_0_s >= max_matric_64_1_s ? state_64_0_s : state_64_1_s;
	assign state_64_01_s = max_matric_64_2_s >= max_matric_64_3_s ? state_64_2_s : state_64_3_s;
	
	assign max_matric_64_00_s =  max_matric_64_0_s>=max_matric_64_1_s ? max_matric_64_0_s : max_matric_64_1_s;
	assign max_matric_64_01_s =  max_matric_64_2_s>=max_matric_64_3_s ? max_matric_64_2_s : max_matric_64_3_s;
	
	assign state_64_s = max_matric_64_00_s  >= max_matric_64_01_s  ? state_64_00_s : state_64_01_s;
	assign max_matric_64_s = mmax_matric_64_00_s >= max_matric_64_01_s ? max_matric_64_00_s : max_matric_64_01_s;
 
//---------------------------------------------------------------------
//      select the max metric of second level 
//---------------------------------------------------------------------	
	assign state_2nd_0_s =  max_matric_8_s  >= max_matric_16_s ? state_8_s : state_16_s;
	assign state_2nd_1_s =  max_matric_24_s >= max_matric_32_s ? state_24_s : state_32_s;
	assign state_2nd_2_s =  max_matric_40_s >= max_matric_48_s ? state_40_s : state_48_s;
	assign state_2nd_3_s =  max_matric_56_s >= max_matric_64_s ? state_56_s : state_64_s;
	
	assign max_matric_2nd_0_s =  max_matric_8_s  >= max_matric_16_s ? max_matric_8_s  : max_matric_16_s ?;
    assign max_matric_2nd_1_s =  max_matric_24_s >= max_matric_32_s ? max_matric_24_s : max_matric_32_s ?;
	assign max_matric_2nd_2_s =  max_matric_40_s >= max_matric_48_s ? max_matric_40_s : max_matric_48_s ?;
	assign max_matric_2nd_3_s =  max_matric_56_s >= max_matric_64_s ? max_matric_56_s : max_matric_64_s ?;
	
	assign state_2nd_00_s = max_matric_2nd_0_s >= max_matric_2nd_1_s ? state_2nd_0_s : state_2nd_2_s;
	assign state_2nd_01_s = max_matric_2nd_2_s >= max_matric_2nd_3_s ? state_2nd_2_s : state_2nd_3_s;
	
	assign max_matric_2nd_00_s =  max_matric_2nd_0_s >= max_matric_2nd_1_s  ? max_matric_2nd_0_s : max_matric_2nd_1_s 
	assign max_matric_2nd_01_s =  max_matric_2nd_2_s >= max_matric_2nd_3_s  ? max_matric_2nd_2_s : max_matric_2nd_3_s 
	
	assign max_state_s = max_matric_2nd_00_s  >= max_matric_2nd_01_s  ? state_2nd_00_s : state_2nd_01_s;
	assign max_matric_s = max_matric_2nd_00_s >= max_matric_2nd_01_s ? max_matric_2nd_00_s : max_matric_2nd_01_s ;
endmodule	 