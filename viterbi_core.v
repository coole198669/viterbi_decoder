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
module viterbi_core #(parameter WIDTH_BM = 9,SRC_ADDR_W = 12 , DST_ADDR_W = 12,W_TB_ADDR=6)(
    input clk_i,
    input rst_an_i,
    input rst_sync_i,
     
    input frame_start_i,// a pulse to trigger one frame decoding
   
    input [1:0] register_num_i,     //0: 64-state, 1: 32-state, 2: 16-state, 3: 8-state
    input [2:0] valid_polynomials_i,//0: R=1/2,  1: R=1/3,  2: R=1/4,  3: R=1/5,  4: R=1/6, Polynomials 1:2&3 are valid
    input  tail_biting_en_i,        //0: tail-bit 1: tail-biting
    input [7:0] polynomial1_i,
    input [7:0] polynomial2_i,
    input [7:0] polynomial3_i,
    input [7:0] polynomial4_i,
    input [7:0] polynomial5_i,
    input [7:0] polynomial6_i,
    input [10:0] infobit_length_i,
    input [11:0] decoding_length_i, //Valid when Tail-biting==1 and decodingLength>=InfoBitLength
    input [SRC_ADDR_W-1:0]  src_start_addr_i,
    input [DST_ADDR_W-1:0]  dst_start_addr_i,
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
    output [W_TB_ADDR-1:0]   tb_addr_o,
    output [63:0]            tb_wdata_o,
     input  [63:0]            tb_rdata_i
    );

wire [23:0] soft_data_s;
reg  soft_data_valid_r;
wire soft_data_valid_s;
//wire signed [WIDTH_BM-1:0] pm_r_s[63:0];

//wire signed [WIDTH_BM-1:0] bm_s[63:0];
wire bm_valid_s[63:0];
wire bmu_ready_s[63:0];

wire is_t0_s;
wire acs_en_s;
//wire signed [WIDTH_BM-1:0] pm_tmp_s[63:0];
wire survivor_path_s[63:0];
wire acs_valid_s[63:0];

wire pm_norm_en_s;
wire [5:0] max_state_index_s;  

wire [WIDTH_BM-1:0] bm_s_0  ,bm_s_1  ,bm_s_2  ,bm_s_3  ,bm_s_4  ,bm_s_5 , bm_s_6  ,bm_s_7  ,bm_s_8  ,bm_s_9 ; 
wire [WIDTH_BM-1:0] bm_s_10 ,bm_s_11 ,bm_s_12 ,bm_s_13 ,bm_s_14 ,bm_s_15, bm_s_16 ,bm_s_17 ,bm_s_18 ,bm_s_19; 
wire [WIDTH_BM-1:0] bm_s_20 ,bm_s_21 ,bm_s_22 ,bm_s_23 ,bm_s_24 ,bm_s_25, bm_s_26 ,bm_s_27 ,bm_s_28 ,bm_s_29; 
wire [WIDTH_BM-1:0] bm_s_30 ,bm_s_31 ,bm_s_32 ,bm_s_33 ,bm_s_34 ,bm_s_35, bm_s_36 ,bm_s_37 ,bm_s_38 ,bm_s_39; 
wire [WIDTH_BM-1:0] bm_s_40 ,bm_s_41 ,bm_s_42 ,bm_s_43 ,bm_s_44 ,bm_s_45, bm_s_46 ,bm_s_47 ,bm_s_48 ,bm_s_49;
wire [WIDTH_BM-1:0] bm_s_50 ,bm_s_51 ,bm_s_52 ,bm_s_53 ,bm_s_54 ,bm_s_55, bm_s_56 ,bm_s_57 ,bm_s_58 ,bm_s_59 ,bm_s_60 ,bm_s_61 ,bm_s_62, bm_s_63;

wire [WIDTH_BM-1:0] pm_tmp_s_0  ,pm_tmp_s_1  ,pm_tmp_s_2  ,pm_tmp_s_3  ,pm_tmp_s_4  ,pm_tmp_s_5  ,pm_tmp_s_6  ,pm_tmp_s_7  ,pm_tmp_s_8  ,pm_tmp_s_9 ;    
wire [WIDTH_BM-1:0] pm_tmp_s_10 ,pm_tmp_s_11 ,pm_tmp_s_12 ,pm_tmp_s_13 ,pm_tmp_s_14 ,pm_tmp_s_15 ,pm_tmp_s_16 ,pm_tmp_s_17 ,pm_tmp_s_18 ,pm_tmp_s_19;
wire [WIDTH_BM-1:0] pm_tmp_s_20 ,pm_tmp_s_21 ,pm_tmp_s_22 ,pm_tmp_s_23 ,pm_tmp_s_24 ,pm_tmp_s_25 ,pm_tmp_s_26 ,pm_tmp_s_27 ,pm_tmp_s_28 ,pm_tmp_s_29;
wire [WIDTH_BM-1:0] pm_tmp_s_30 ,pm_tmp_s_31 ,pm_tmp_s_32 ,pm_tmp_s_33 ,pm_tmp_s_34 ,pm_tmp_s_35 ,pm_tmp_s_36 ,pm_tmp_s_37 ,pm_tmp_s_38 ,pm_tmp_s_39;
wire [WIDTH_BM-1:0] pm_tmp_s_40 ,pm_tmp_s_41 ,pm_tmp_s_42 ,pm_tmp_s_43 ,pm_tmp_s_44 ,pm_tmp_s_45 ,pm_tmp_s_46 ,pm_tmp_s_47 ,pm_tmp_s_48 ,pm_tmp_s_49;
wire [WIDTH_BM-1:0] pm_tmp_s_50 ,pm_tmp_s_51 ,pm_tmp_s_52 ,pm_tmp_s_53 ,pm_tmp_s_54 ,pm_tmp_s_55 ,pm_tmp_s_56 ,pm_tmp_s_57 ,pm_tmp_s_58 ,pm_tmp_s_59, pm_tmp_s_60, pm_tmp_s_61, pm_tmp_s_62, pm_tmp_s_63;

wire [WIDTH_BM-1:0] pm_r_s_0  ,pm_r_s_1 , pm_r_s_2 , pm_r_s_3 , pm_r_s_4 , pm_r_s_5 , pm_r_s_6 , pm_r_s_7 , pm_r_s_8 , pm_r_s_9 ; 
wire [WIDTH_BM-1:0] pm_r_s_10 ,pm_r_s_11, pm_r_s_12, pm_r_s_13, pm_r_s_14, pm_r_s_15, pm_r_s_16, pm_r_s_17, pm_r_s_18, pm_r_s_19; 
wire [WIDTH_BM-1:0] pm_r_s_20 ,pm_r_s_21, pm_r_s_22, pm_r_s_23, pm_r_s_24, pm_r_s_25, pm_r_s_26, pm_r_s_27, pm_r_s_28, pm_r_s_29; 
wire [WIDTH_BM-1:0] pm_r_s_30 ,pm_r_s_31, pm_r_s_32, pm_r_s_33, pm_r_s_34, pm_r_s_35, pm_r_s_36, pm_r_s_37, pm_r_s_38, pm_r_s_39; 
wire [WIDTH_BM-1:0] pm_r_s_40 ,pm_r_s_41, pm_r_s_42, pm_r_s_43, pm_r_s_44, pm_r_s_45, pm_r_s_46, pm_r_s_47, pm_r_s_48, pm_r_s_49;
wire [WIDTH_BM-1:0] pm_r_s_50 ,pm_r_s_51, pm_r_s_52, pm_r_s_53, pm_r_s_54, pm_r_s_55, pm_r_s_56, pm_r_s_57, pm_r_s_58, pm_r_s_59, pm_r_s_60, pm_r_s_61, pm_r_s_62, pm_r_s_63;
    


 
reg frame_done_r;
reg busy_r;

parameter FULL_TRACEBAKE_LEN=64;
parameter HALF_TRACEBAKE_LEN=32;
parameter IDLE=3'd0, CHECK_REMIN=3'd1,RUN_FULL_TB=3'd2, RUN_HALF_TB=3'd3, FLUSH_ALL=3'd4;
/////////////////////////////////////////////////////////////////////////
//   
//
//
/////////////////////////////////////////////////////////////////////////
reg  bmu_ready_d1_r, decoding_start_r, is_t0_r;
wire decoding_start_s;
reg   [11:0]  trellis_idx_r;
wire   [11:0] ext_trellis_idx_s;
reg   [2:0]  state_r;
reg   full_tb_start_r,half_tb_start_r,flush_all_start_r;
reg   first_loop_r;
reg   last_loop_r;
reg  [SRC_ADDR_W-1:0]  fetch_src_cnt_r;

reg                    src_rd_r; 
reg [SRC_ADDR_W-1:0]   src_addr_r; 
reg [SRC_ADDR_W-1:0]   src_len_counter_r;

reg  traceback_start_r;
wire [5:0] start_state_index_s;


reg [W_TB_ADDR:0]    tb_len_r;
wire                   tb_wr_s;
reg [W_TB_ADDR-1:0]    tb_wr_addr_r;
wire [W_TB_ADDR-1:0]   tb_rd_addr_s;  
wire [W_TB_ADDR-1:0]   tb_start_addr_s;   
wire                   decoding_end_s;


reg                    dst_wr_r;
reg [DST_ADDR_W-1:0]   dst_addr_r;
reg [7:0]              dst_wdata_r;
reg [3:0] byte_idx_s;
reg [3:0] byte_idx_r;

wire [HALF_TRACEBAKE_LEN-1:0]   half_tb_bits_s;
wire [FULL_TRACEBAKE_LEN-1:0]   full_tb_bits_s; 
reg [HALF_TRACEBAKE_LEN-1:0]   half_tb_bits_tmp_r;
reg [FULL_TRACEBAKE_LEN-1:0]   full_tb_bits_tmp_r;   
wire tb_bits_valid_s;
always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i) 
     bmu_ready_d1_r  <= 1;     
  else if(rst_sync_i ) bmu_ready_d1_r  <= 1;  
  else bmu_ready_d1_r  <= bmu_ready_s[0]; 
end

always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i) 
     decoding_start_r  <= 0;     
  else if(rst_sync_i ) decoding_start_r  <= 0;  
  else decoding_start_r  <= decoding_start_s; 
end

assign decoding_start_s = bmu_ready_s[0] & ~bmu_ready_d1_r;
assign is_t0_s = is_t0_r;
always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)
    is_t0_r <= 0;   
  else if(rst_sync_i |frame_start_i )
    is_t0_r <= 1;   
  else if( bm_valid_s[10] ) begin  
    is_t0_r <= 0;    
  end 
end

assign busy_o = busy_r;
assign frame_done_o = frame_done_r;
assign acs_en_s =64'hFFFFFFFF_FFFFFFFF;
always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i) begin
     state_r  <= IDLE;
     full_tb_start_r <= 1'b0;
     half_tb_start_r <= 1'b0;
     flush_all_start_r<= 1'b0;
     trellis_idx_r   <= 0;
     tb_len_r         <= 0;
	  frame_done_r     <= 0;
	  busy_r           <= 0; 
	  first_loop_r     <= 0;
	  last_loop_r       <= 0;
  end     
  else if(rst_sync_i )begin
     state_r  <= IDLE;
     full_tb_start_r <= 1'b0;
     half_tb_start_r <= 1'b0;
     flush_all_start_r<= 1'b0;
     trellis_idx_r   <= 0;
     tb_len_r         <= 0;
	  frame_done_r     <= 0;
	  busy_r           <= 0; 
	  first_loop_r     <= 0;
	  last_loop_r       <= 0;
  end   
  else if(frame_start_i) begin
     trellis_idx_r   <= decoding_length_i;
	  state_r  <= IDLE;
     full_tb_start_r <= 1'b0;
     half_tb_start_r <= 1'b0;
     flush_all_start_r<= 1'b0;
	  first_loop_r     <= 0;
	  last_loop_r       <= 0;
	  tb_len_r         <= 0;
	  frame_done_r     <= 0;
	  busy_r           <= 1; 
  end  
  else begin
    case(state_r)
      IDLE:begin
        if(decoding_start_s)
          state_r  <= CHECK_REMIN;
			 
		  if(~dst_wr_r & last_loop_r) begin
		     busy_r     <= 0;
			  frame_done_r     <= 1;
			  last_loop_r  <= 0;
		  end
		  else if(~last_loop_r )begin 
			  frame_done_r     <= 0;
		  end
      end
      CHECK_REMIN:begin
        if(decoding_start_r) begin
            if(trellis_idx_r>FULL_TRACEBAKE_LEN) begin
              state_r  <= RUN_FULL_TB;
              full_tb_start_r <= 1'b1;			  
            end
            else begin
              state_r  <= FLUSH_ALL;
              flush_all_start_r <= 1'b1;
				  first_loop_r     <= 1;
            end
        end
        else begin
            if(trellis_idx_r>HALF_TRACEBAKE_LEN) begin
              state_r  <= RUN_HALF_TB;
              half_tb_start_r <= 1'b1;
            end
            else if(trellis_idx_r != 0) begin
              state_r  <= FLUSH_ALL;
              flush_all_start_r <= 1'b1;
            end 
            else 
              state_r  <= IDLE;     
        end
      end
      RUN_FULL_TB:begin
          if(tb_bits_valid_s ) begin
             state_r  <= CHECK_REMIN;
             trellis_idx_r <=trellis_idx_r - FULL_TRACEBAKE_LEN;
           end
          full_tb_start_r <= 1'b0;
           tb_len_r         <= FULL_TRACEBAKE_LEN;
        end
      RUN_HALF_TB:begin
          if(tb_bits_valid_s ) begin
             state_r  <= CHECK_REMIN;
             trellis_idx_r <=trellis_idx_r - HALF_TRACEBAKE_LEN;
           end
          half_tb_start_r <= 1'b0;
          tb_len_r         <= FULL_TRACEBAKE_LEN;
        end
      FLUSH_ALL:begin
          if(tb_bits_valid_s ) begin
             state_r  <= IDLE;
             trellis_idx_r <= 0;
				 first_loop_r  <=0;
				 last_loop_r <=1;
           end
          flush_all_start_r <= 1'b0;
			 if(first_loop_r) tb_len_r   <= trellis_idx_r;
          else  tb_len_r   <= trellis_idx_r + HALF_TRACEBAKE_LEN;
        end
      default:begin
       state_r  <= IDLE;
       full_tb_start_r <= 1'b0;
       half_tb_start_r <= 1'b0;
       flush_all_start_r<= 1'b0;
       trellis_idx_r   <= 0;
		 first_loop_r     <= 0;
      end  
    endcase   
  end //else begin
end // begin



always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)     fetch_src_cnt_r <= 0;
  else if(rst_sync_i )      fetch_src_cnt_r <= 0;
  else if(frame_start_i)      fetch_src_cnt_r <= 0;
  else if( full_tb_start_r)      fetch_src_cnt_r <= FULL_TRACEBAKE_LEN ;
  else if( half_tb_start_r)      fetch_src_cnt_r <= HALF_TRACEBAKE_LEN ;
  else if( flush_all_start_r)      fetch_src_cnt_r <= trellis_idx_r ;
  else if( src_rd_r ) fetch_src_cnt_r <= fetch_src_cnt_r -1;
 end
 

 
 assign  soft_data_s = src_rdata_i;
 assign  soft_data_valid_s = soft_data_valid_r;
 assign  src_rd_o   = src_rd_r; 
 assign  src_addr_o = src_addr_r;
 always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)     soft_data_valid_r <= 0;
  else if(rst_sync_i )      soft_data_valid_r <= 0;
  else soft_data_valid_r <= src_rd_r;
 end
 
 always@(posedge clk_i or negedge rst_an_i) begin
   if(!rst_an_i)   begin  
       src_rd_r <= 1'b0; 
       src_addr_r<= 0;
       src_len_counter_r <= 0;     
   end
   else if(rst_sync_i )     begin  
       src_rd_r <= 1'b0; 
       src_addr_r<= 0; 
       src_len_counter_r <= 0;  
   end
   else if(frame_start_i)  begin      
       src_addr_r<= src_start_addr_i; 
       src_len_counter_r <= 0;  
   end
   else if(full_tb_start_r | half_tb_start_r |flush_all_start_r) begin
       src_len_counter_r <= src_len_counter_r + 1;  
       src_rd_r <= 1'b1; 
       if(src_len_counter_r==infobit_length_i) src_addr_r<= src_start_addr_i; 
       else src_addr_r<= src_addr_r + 1;   
   
   end
   else if (pm_norm_en_s == 1 && fetch_src_cnt_r!=0 ) begin
       src_len_counter_r <= src_len_counter_r + 1;  
       src_rd_r <= 1'b1; 
       if(src_len_counter_r==infobit_length_i) src_addr_r<= src_start_addr_i; 
       else src_addr_r<= src_addr_r + 1;    
   end
   else src_rd_r <= 1'b0; 
 end
 
 

 
assign tb_wr_s = acs_valid_s[0];
assign tb_wr_o = tb_wr_s; 
assign tb_addr_o = tb_wr_s ? tb_wr_addr_r: tb_rd_addr_s;
 
 
always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)           tb_wr_addr_r <= 0;  
  else if(rst_sync_i)     tb_wr_addr_r <= 0;   
  else if(frame_start_i)  tb_wr_addr_r <= 0;
  else if(tb_wr_s)        tb_wr_addr_r <= tb_wr_addr_r + 1 ;
end

genvar i;
generate 
  for(i=0;i<64;i=i+1)
  begin:tbwdata
   assign tb_wdata_o[i] = survivor_path_s[i];
  end
endgenerate
  
  always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)          traceback_start_r      <= 1'b0;
  else if(rst_sync_i )   traceback_start_r      <= 1'b0;
  else if(fetch_src_cnt_r==0 && pm_norm_en_s==1'b1)  traceback_start_r      <= 1'b1;
  else traceback_start_r      <= 1'b0;
 end
 
 assign decoding_end_s = (state_r==FLUSH_ALL || last_loop_r==1) ? 1'b1 : 1'b0;
 
 assign start_state_index_s = (tail_biting_en_i==1'b0 &&  state_r == FLUSH_ALL) ? 0 : max_state_index_s ;
 assign tb_start_addr_s = tb_wr_addr_r-1;
  traceback traceback_ins ( 
    .clk_i               (  clk_i          ),              
    .rst_an_i            (  rst_an_i       ),       
    .rst_sync_i          (  rst_sync_i     ),                          
    .register_num_i      (  register_num_i ),       
    .segment_start_i     (  traceback_start_r ),
    .busy_o              (                 ),       
    .start_state_index_i ( start_state_index_s     ),
    .tb_start_addr_i     ( tb_wr_addr_r       ),
    .tb_len_i            ( tb_len_r      ),
    .decodeing_end_i     (  decoding_end_s      ),
    //out stream
    .half_tb_bits_o      ( half_tb_bits_s    ),
    .full_tb_bits_o      ( full_tb_bits_s    ),
    .tb_bits_valid_o     ( tb_bits_valid_s   ),
    //                  
    .tb_rd_o             (tb_rd_o    ),
    .tb_addr_o           (tb_rd_addr_s  ),
    .tb_rdata_i          (tb_rdata_i )

);   
 
 
assign  dst_wr_o    = dst_wr_r;
assign  dst_addr_o  = dst_addr_r;
assign  dst_wdata_o = dst_wdata_r;



assign ext_trellis_idx_s = trellis_idx_r + HALF_TRACEBAKE_LEN;
always@(*) begin
    if(decoding_end_s)  begin 
	    if( first_loop_r) begin
         if(trellis_idx_r >= 56) byte_idx_s =8;
         else if(trellis_idx_r >= 48) byte_idx_s =7;
         else if(trellis_idx_r >= 40) byte_idx_s =6;
         else if(trellis_idx_r >= 32) byte_idx_s =5;
         else if(trellis_idx_r >= 24) byte_idx_s =4;
         else if(trellis_idx_r >= 16) byte_idx_s =3;
         else if(trellis_idx_r >= 8)  byte_idx_s =2;
         else if(trellis_idx_r > 0)   byte_idx_s =1;
         else   byte_idx_s =0;
		 end
		 else begin
		  if(ext_trellis_idx_s >= 56) byte_idx_s =8;
         else if(ext_trellis_idx_s >= 48) byte_idx_s =7;
         else if(ext_trellis_idx_s >= 40) byte_idx_s =6;
         else if(ext_trellis_idx_s >= 32) byte_idx_s =5;
         else if(ext_trellis_idx_s >= 24) byte_idx_s =4;
         else if(ext_trellis_idx_s >= 16) byte_idx_s =3;
         else if(ext_trellis_idx_s >= 8)  byte_idx_s =2;
         else if(ext_trellis_idx_s > 0)   byte_idx_s =1;
         else   byte_idx_s =0;
		 end
      end
    else byte_idx_s = 4;
end 

always@(posedge clk_i or negedge rst_an_i) begin
   if(!rst_an_i)   begin 
     dst_wr_r  <= 1'b0;   
     dst_wdata_r <= 8'b0;   
     byte_idx_r <=0;    
     half_tb_bits_tmp_r <=0; 
     full_tb_bits_tmp_r <=0; 
   end   
   else if(rst_sync_i ) begin 
     dst_wr_r  <= 1'b0;   
     dst_wdata_r <= 8'b0;
     byte_idx_r <=0;
     half_tb_bits_tmp_r <=0; 
     full_tb_bits_tmp_r <=0;
   end  
   else if(frame_start_i) begin
     dst_wr_r  <= 1'b0;   
     dst_wdata_r <= 8'b0;
     byte_idx_r <=0;    
     half_tb_bits_tmp_r <=0; 
     full_tb_bits_tmp_r <=0;     
   end 
   else if(tb_bits_valid_s ) begin
     dst_wr_r    <= 1'b1;    
     dst_wdata_r <=  decoding_end_s ? full_tb_bits_s[7:0] : half_tb_bits_s[7:0];
     byte_idx_r <= byte_idx_s-1;  
     if(decoding_end_s) half_tb_bits_tmp_r  <= half_tb_bits_tmp_r>>8;
     else full_tb_bits_tmp_r <=full_tb_bits_tmp_r >> 8; 
	end
   else if(byte_idx_r>0) begin
     byte_idx_r <= byte_idx_r -1;
     dst_wr_r  <= 1'b1;   
     dst_wdata_r <= decoding_end_s ? full_tb_bits_tmp_r[7:0] : half_tb_bits_tmp_r[7:0];      
     if(decoding_end_s) half_tb_bits_tmp_r  <= half_tb_bits_tmp_r>>8;
     else full_tb_bits_tmp_r <=full_tb_bits_tmp_r >> 8; 
   end
   else begin
     dst_wr_r  <= 1'b0;   
     dst_wdata_r <= 8'b0;
     byte_idx_r <=0;    
     half_tb_bits_tmp_r <=0; 
     full_tb_bits_tmp_r <=0;    
   end
end   
 
 always@(posedge clk_i or negedge rst_an_i) begin
   if(!rst_an_i)  dst_addr_r<=  0;   
   else if(rst_sync_i )  dst_addr_r<=  0;       
   else if(frame_start_i) dst_addr_r<=  dst_start_addr_i;
	else if(dst_wr_r) dst_addr_r<= dst_addr_r +1 ; 
end
 
 assign pm_norm_en_s = acs_valid_s[0];
 
 pm_normalize pm_normalize_inst(
    .clk_i         (clk_i         ),
    .rst_an_i      (rst_an_i      ),
    .rst_sync_i    (rst_sync_i    ), 
    .en_i          (pm_norm_en_s  ),
    .register_num_i(register_num_i),
    .pm_tmp_0_i     ( pm_tmp_s_0 ),
    .pm_tmp_1_i     ( pm_tmp_s_1 ),
    .pm_tmp_2_i     ( pm_tmp_s_2 ),
    .pm_tmp_3_i     ( pm_tmp_s_3 ),
    .pm_tmp_4_i     ( pm_tmp_s_4 ),
    .pm_tmp_5_i     ( pm_tmp_s_5 ),
    .pm_tmp_6_i     ( pm_tmp_s_6 ),
    .pm_tmp_7_i     ( pm_tmp_s_7 ),
    .pm_tmp_8_i     ( pm_tmp_s_8 ),
    .pm_tmp_9_i     ( pm_tmp_s_9 ),    
    .pm_tmp_10_i    ( pm_tmp_s_10),
    .pm_tmp_11_i    ( pm_tmp_s_11),
    .pm_tmp_12_i    ( pm_tmp_s_12),
    .pm_tmp_13_i    ( pm_tmp_s_13),
    .pm_tmp_14_i    ( pm_tmp_s_14),
    .pm_tmp_15_i    ( pm_tmp_s_15),
    .pm_tmp_16_i    ( pm_tmp_s_16),
    .pm_tmp_17_i    ( pm_tmp_s_17),
    .pm_tmp_18_i    ( pm_tmp_s_18),
    .pm_tmp_19_i    ( pm_tmp_s_19),
    .pm_tmp_20_i    ( pm_tmp_s_20),
    .pm_tmp_21_i    ( pm_tmp_s_21),
    .pm_tmp_22_i    ( pm_tmp_s_22),
    .pm_tmp_23_i    ( pm_tmp_s_23),
    .pm_tmp_24_i    ( pm_tmp_s_24),
    .pm_tmp_25_i    ( pm_tmp_s_25),
    .pm_tmp_26_i    ( pm_tmp_s_26),
    .pm_tmp_27_i    ( pm_tmp_s_27),
    .pm_tmp_28_i    ( pm_tmp_s_28),
    .pm_tmp_29_i    ( pm_tmp_s_29),
    .pm_tmp_30_i    ( pm_tmp_s_30),
    .pm_tmp_31_i    ( pm_tmp_s_31),
    .pm_tmp_32_i    ( pm_tmp_s_32),
    .pm_tmp_33_i    ( pm_tmp_s_33),
    .pm_tmp_34_i    ( pm_tmp_s_34),
    .pm_tmp_35_i    ( pm_tmp_s_35),
    .pm_tmp_36_i    ( pm_tmp_s_36),
    .pm_tmp_37_i    ( pm_tmp_s_37),
    .pm_tmp_38_i    ( pm_tmp_s_38),
    .pm_tmp_39_i    ( pm_tmp_s_39),
    .pm_tmp_40_i    ( pm_tmp_s_40),
    .pm_tmp_41_i    ( pm_tmp_s_41),
    .pm_tmp_42_i    ( pm_tmp_s_42),
    .pm_tmp_43_i    ( pm_tmp_s_43),
    .pm_tmp_44_i    ( pm_tmp_s_44),
    .pm_tmp_45_i    ( pm_tmp_s_45),
    .pm_tmp_46_i    ( pm_tmp_s_46),
    .pm_tmp_47_i    ( pm_tmp_s_47),
    .pm_tmp_48_i    ( pm_tmp_s_48),
    .pm_tmp_49_i    ( pm_tmp_s_49),
    .pm_tmp_50_i    ( pm_tmp_s_50),
    .pm_tmp_51_i    ( pm_tmp_s_51),
    .pm_tmp_52_i    ( pm_tmp_s_52),
    .pm_tmp_53_i    ( pm_tmp_s_53),
    .pm_tmp_54_i    ( pm_tmp_s_54),
    .pm_tmp_55_i    ( pm_tmp_s_55),
    .pm_tmp_56_i    ( pm_tmp_s_56),
    .pm_tmp_57_i    ( pm_tmp_s_57),
    .pm_tmp_58_i    ( pm_tmp_s_58),
    .pm_tmp_59_i    ( pm_tmp_s_59),
    .pm_tmp_60_i    ( pm_tmp_s_60),
    .pm_tmp_61_i    ( pm_tmp_s_61),
    .pm_tmp_62_i    ( pm_tmp_s_62),
    .pm_tmp_63_i    ( pm_tmp_s_63),

    .pm_nom_0_o     ( pm_r_s_0  ),
    .pm_nom_1_o     ( pm_r_s_1  ),
    .pm_nom_2_o     ( pm_r_s_2  ),
    .pm_nom_3_o     ( pm_r_s_3  ),
    .pm_nom_4_o     ( pm_r_s_4  ),
    .pm_nom_5_o     ( pm_r_s_5  ),
    .pm_nom_6_o     ( pm_r_s_6  ),
    .pm_nom_7_o     ( pm_r_s_7  ),
    .pm_nom_8_o     ( pm_r_s_8  ),
    .pm_nom_9_o     ( pm_r_s_9  ), 
    .pm_nom_10_o    ( pm_r_s_10 ),
    .pm_nom_11_o    ( pm_r_s_11 ),
    .pm_nom_12_o    ( pm_r_s_12 ),
    .pm_nom_13_o    ( pm_r_s_13 ),
    .pm_nom_14_o    ( pm_r_s_14 ),
    .pm_nom_15_o    ( pm_r_s_15 ),
    .pm_nom_16_o    ( pm_r_s_16 ),
    .pm_nom_17_o    ( pm_r_s_17 ),
    .pm_nom_18_o    ( pm_r_s_18 ),
    .pm_nom_19_o    ( pm_r_s_19 ), 
    .pm_nom_20_o    ( pm_r_s_20 ),
    .pm_nom_21_o    ( pm_r_s_21 ),
    .pm_nom_22_o    ( pm_r_s_22 ),
    .pm_nom_23_o    ( pm_r_s_23 ),
    .pm_nom_24_o    ( pm_r_s_24 ),
    .pm_nom_25_o    ( pm_r_s_25 ),
    .pm_nom_26_o    ( pm_r_s_26 ),
    .pm_nom_27_o    ( pm_r_s_27 ),
    .pm_nom_28_o    ( pm_r_s_28 ),
    .pm_nom_29_o    ( pm_r_s_29 ), 
    .pm_nom_30_o    ( pm_r_s_30 ),
    .pm_nom_31_o    ( pm_r_s_31 ),
    .pm_nom_32_o    ( pm_r_s_32 ),
    .pm_nom_33_o    ( pm_r_s_33 ),
    .pm_nom_34_o    ( pm_r_s_34 ),
    .pm_nom_35_o    ( pm_r_s_35 ),
    .pm_nom_36_o    ( pm_r_s_36 ),
    .pm_nom_37_o    ( pm_r_s_37 ),
    .pm_nom_38_o    ( pm_r_s_38 ),
    .pm_nom_39_o    ( pm_r_s_39 ), 
    .pm_nom_40_o    ( pm_r_s_40 ),
    .pm_nom_41_o    ( pm_r_s_41 ),
    .pm_nom_42_o    ( pm_r_s_42 ),
    .pm_nom_43_o    ( pm_r_s_43 ),
    .pm_nom_44_o    ( pm_r_s_44 ),
    .pm_nom_45_o    ( pm_r_s_45 ),
    .pm_nom_46_o    ( pm_r_s_46 ),
    .pm_nom_47_o    ( pm_r_s_47 ),
    .pm_nom_48_o    ( pm_r_s_48 ),
    .pm_nom_49_o    ( pm_r_s_49 ),
    .pm_nom_50_o    ( pm_r_s_50 ),
    .pm_nom_51_o    ( pm_r_s_51 ),
    .pm_nom_52_o    ( pm_r_s_52 ),
    .pm_nom_53_o    ( pm_r_s_53 ),
    .pm_nom_54_o    ( pm_r_s_54 ),
    .pm_nom_55_o    ( pm_r_s_55 ),
    .pm_nom_56_o    ( pm_r_s_56 ),
    .pm_nom_57_o    ( pm_r_s_57 ),
    .pm_nom_58_o    ( pm_r_s_58 ),
    .pm_nom_59_o    ( pm_r_s_59 ),
    .pm_nom_60_o    ( pm_r_s_60 ),
    .pm_nom_61_o    ( pm_r_s_61 ),
    .pm_nom_62_o    ( pm_r_s_62 ),
    .pm_nom_63_o    ( pm_r_s_63 ),
    .max_state_index_o (max_state_index_s)
    );
 
  
  
 

BMU bmu_inst_0   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd0), 
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
        .ready_o            (bmu_ready_s[0]),
        .bm_o               (bm_s_0),
        .bm_valid_o         (bm_valid_s[0])
        ); 
BMU bmu_inst_1   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd1), 
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
        .ready_o            (bmu_ready_s[1]),
        .bm_o               (bm_s_1),
        .bm_valid_o         (bm_valid_s[1])
        ); 
BMU bmu_inst_2   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd2), 
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
        .ready_o            (bmu_ready_s[2]),
        .bm_o               (bm_s_2),
        .bm_valid_o         (bm_valid_s[2])
        ); 
BMU bmu_inst_3   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd3), 
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
        .ready_o            (bmu_ready_s[3]),
        .bm_o               (bm_s_3),
        .bm_valid_o         (bm_valid_s[3])
        ); 
BMU bmu_inst_4   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd4), 
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
        .ready_o            (bmu_ready_s[4]),
        .bm_o               (bm_s_4),
        .bm_valid_o         (bm_valid_s[4])
        ); 
BMU bmu_inst_5   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd5), 
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
        .ready_o            (bmu_ready_s[5]),
        .bm_o               (bm_s_5),
        .bm_valid_o         (bm_valid_s[5])
        ); 
BMU bmu_inst_6   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd6), 
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
        .ready_o            (bmu_ready_s[6]),
        .bm_o               (bm_s_6),
        .bm_valid_o         (bm_valid_s[6])
        ); 
BMU bmu_inst_7   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd7), 
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
        .ready_o            (bmu_ready_s[7]),
        .bm_o               (bm_s_7),
        .bm_valid_o         (bm_valid_s[7])
        ); 
BMU bmu_inst_8   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd8), 
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
        .ready_o            (bmu_ready_s[8]),
        .bm_o               (bm_s_8),
        .bm_valid_o         (bm_valid_s[8])
        ); 
BMU bmu_inst_9   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd9), 
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
        .ready_o            (bmu_ready_s[9]),
        .bm_o               (bm_s_9),
        .bm_valid_o         (bm_valid_s[9])
        ); 
BMU bmu_inst_10   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd10), 
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
        .ready_o            (bmu_ready_s[10]),
        .bm_o               (bm_s_10),
        .bm_valid_o         (bm_valid_s[10])
        ); 
BMU bmu_inst_11   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd11), 
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
        .ready_o            (bmu_ready_s[11]),
        .bm_o               (bm_s_11),
        .bm_valid_o         (bm_valid_s[11])
        ); 
BMU bmu_inst_12   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd12), 
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
        .ready_o            (bmu_ready_s[12]),
        .bm_o               (bm_s_12),
        .bm_valid_o         (bm_valid_s[12])
        ); 
BMU bmu_inst_13   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd13), 
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
        .ready_o            (bmu_ready_s[13]),
        .bm_o               (bm_s_13),
        .bm_valid_o         (bm_valid_s[13])
        ); 
BMU bmu_inst_14   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd14), 
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
        .ready_o            (bmu_ready_s[14]),
        .bm_o               (bm_s_14),
        .bm_valid_o         (bm_valid_s[14])
        ); 
BMU bmu_inst_15   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd15), 
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
        .ready_o            (bmu_ready_s[15]),
        .bm_o               (bm_s_15),
        .bm_valid_o         (bm_valid_s[15])
        ); 
BMU bmu_inst_16   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd16), 
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
        .ready_o            (bmu_ready_s[16]),
        .bm_o               (bm_s_16),
        .bm_valid_o         (bm_valid_s[16])
        ); 
BMU bmu_inst_17   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd17), 
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
        .ready_o            (bmu_ready_s[17]),
        .bm_o               (bm_s_17),
        .bm_valid_o         (bm_valid_s[17])
        ); 
BMU bmu_inst_18   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd18), 
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
        .ready_o            (bmu_ready_s[18]),
        .bm_o               (bm_s_18),
        .bm_valid_o         (bm_valid_s[18])
        ); 
BMU bmu_inst_19   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd19), 
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
        .ready_o            (bmu_ready_s[19]),
        .bm_o               (bm_s_19),
        .bm_valid_o         (bm_valid_s[19])
        ); 
BMU bmu_inst_20   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd20), 
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
        .ready_o            (bmu_ready_s[20]),
        .bm_o               (bm_s_20),
        .bm_valid_o         (bm_valid_s[20])
        ); 
BMU bmu_inst_21   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd21), 
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
        .ready_o            (bmu_ready_s[21]),
        .bm_o               (bm_s_21),
        .bm_valid_o         (bm_valid_s[21])
        ); 
BMU bmu_inst_22   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd22), 
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
        .ready_o            (bmu_ready_s[22]),
        .bm_o               (bm_s_22),
        .bm_valid_o         (bm_valid_s[22])
        ); 
BMU bmu_inst_23   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd23), 
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
        .ready_o            (bmu_ready_s[23]),
        .bm_o               (bm_s_23),
        .bm_valid_o         (bm_valid_s[23])
        ); 
BMU bmu_inst_24   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd24), 
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
        .ready_o            (bmu_ready_s[24]),
        .bm_o               (bm_s_24),
        .bm_valid_o         (bm_valid_s[24])
        ); 
BMU bmu_inst_25   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd25), 
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
        .ready_o            (bmu_ready_s[25]),
        .bm_o               (bm_s_25),
        .bm_valid_o         (bm_valid_s[25])
        ); 
BMU bmu_inst_26   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd26), 
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
        .ready_o            (bmu_ready_s[26]),
        .bm_o               (bm_s_26),
        .bm_valid_o         (bm_valid_s[26])
        ); 
BMU bmu_inst_27   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd27), 
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
        .ready_o            (bmu_ready_s[27]),
        .bm_o               (bm_s_27),
        .bm_valid_o         (bm_valid_s[27])
        ); 
BMU bmu_inst_28   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd28), 
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
        .ready_o            (bmu_ready_s[28]),
        .bm_o               (bm_s_28),
        .bm_valid_o         (bm_valid_s[28])
        ); 
BMU bmu_inst_29   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd29), 
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
        .ready_o            (bmu_ready_s[29]),
        .bm_o               (bm_s_29),
        .bm_valid_o         (bm_valid_s[29])
        ); 
BMU bmu_inst_30   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd30), 
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
        .ready_o            (bmu_ready_s[30]),
        .bm_o               (bm_s_30),
        .bm_valid_o         (bm_valid_s[30])
        ); 
BMU bmu_inst_31   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd31), 
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
        .ready_o            (bmu_ready_s[31]),
        .bm_o               (bm_s_31),
        .bm_valid_o         (bm_valid_s[31])
        ); 
BMU bmu_inst_32   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd32), 
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
        .ready_o            (bmu_ready_s[32]),
        .bm_o               (bm_s_32),
        .bm_valid_o         (bm_valid_s[32])
        ); 
BMU bmu_inst_33   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd33), 
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
        .ready_o            (bmu_ready_s[33]),
        .bm_o               (bm_s_33),
        .bm_valid_o         (bm_valid_s[33])
        ); 
BMU bmu_inst_34   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd34), 
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
        .ready_o            (bmu_ready_s[34]),
        .bm_o               (bm_s_34),
        .bm_valid_o         (bm_valid_s[34])
        ); 
BMU bmu_inst_35   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd35), 
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
        .ready_o            (bmu_ready_s[35]),
        .bm_o               (bm_s_35),
        .bm_valid_o         (bm_valid_s[35])
        ); 
BMU bmu_inst_36   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd36), 
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
        .ready_o            (bmu_ready_s[36]),
        .bm_o               (bm_s_36),
        .bm_valid_o         (bm_valid_s[36])
        ); 
BMU bmu_inst_37   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd37), 
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
        .ready_o            (bmu_ready_s[37]),
        .bm_o               (bm_s_37),
        .bm_valid_o         (bm_valid_s[37])
        ); 
BMU bmu_inst_38   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd38), 
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
        .ready_o            (bmu_ready_s[38]),
        .bm_o               (bm_s_38),
        .bm_valid_o         (bm_valid_s[38])
        ); 
BMU bmu_inst_39   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd39), 
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
        .ready_o            (bmu_ready_s[39]),
        .bm_o               (bm_s_39),
        .bm_valid_o         (bm_valid_s[39])
        ); 
BMU bmu_inst_40   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd40), 
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
        .ready_o            (bmu_ready_s[40]),
        .bm_o               (bm_s_40),
        .bm_valid_o         (bm_valid_s[40])
        ); 
BMU bmu_inst_41   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd41), 
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
        .ready_o            (bmu_ready_s[41]),
        .bm_o               (bm_s_41),
        .bm_valid_o         (bm_valid_s[41])
        ); 
BMU bmu_inst_42   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd42), 
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
        .ready_o            (bmu_ready_s[42]),
        .bm_o               (bm_s_42),
        .bm_valid_o         (bm_valid_s[42])
        ); 
BMU bmu_inst_43   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd43), 
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
        .ready_o            (bmu_ready_s[43]),
        .bm_o               (bm_s_43),
        .bm_valid_o         (bm_valid_s[43])
        ); 
BMU bmu_inst_44   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd44), 
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
        .ready_o            (bmu_ready_s[44]),
        .bm_o               (bm_s_44),
        .bm_valid_o         (bm_valid_s[44])
        ); 
BMU bmu_inst_45   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd45), 
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
        .ready_o            (bmu_ready_s[45]),
        .bm_o               (bm_s_45),
        .bm_valid_o         (bm_valid_s[45])
        ); 
BMU bmu_inst_46   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd46), 
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
        .ready_o            (bmu_ready_s[46]),
        .bm_o               (bm_s_46),
        .bm_valid_o         (bm_valid_s[46])
        ); 
BMU bmu_inst_47   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd47), 
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
        .ready_o            (bmu_ready_s[47]),
        .bm_o               (bm_s_47),
        .bm_valid_o         (bm_valid_s[47])
        ); 
BMU bmu_inst_48   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd48), 
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
        .ready_o            (bmu_ready_s[48]),
        .bm_o               (bm_s_48),
        .bm_valid_o         (bm_valid_s[48])
        ); 
BMU bmu_inst_49   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd49), 
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
        .ready_o            (bmu_ready_s[49]),
        .bm_o               (bm_s_49),
        .bm_valid_o         (bm_valid_s[49])
        ); 
BMU bmu_inst_50   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd50), 
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
        .ready_o            (bmu_ready_s[50]),
        .bm_o               (bm_s_50),
        .bm_valid_o         (bm_valid_s[50])
        ); 
BMU bmu_inst_51   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd51), 
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
        .ready_o            (bmu_ready_s[51]),
        .bm_o               (bm_s_51),
        .bm_valid_o         (bm_valid_s[51])
        ); 
BMU bmu_inst_52   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd52), 
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
        .ready_o            (bmu_ready_s[52]),
        .bm_o               (bm_s_52),
        .bm_valid_o         (bm_valid_s[52])
        ); 
BMU bmu_inst_53   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd53), 
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
        .ready_o            (bmu_ready_s[53]),
        .bm_o               (bm_s_53),
        .bm_valid_o         (bm_valid_s[53])
        ); 
BMU bmu_inst_54   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd54), 
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
        .ready_o            (bmu_ready_s[54]),
        .bm_o               (bm_s_54),
        .bm_valid_o         (bm_valid_s[54])
        ); 
BMU bmu_inst_55   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd55), 
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
        .ready_o            (bmu_ready_s[55]),
        .bm_o               (bm_s_55),
        .bm_valid_o         (bm_valid_s[55])
        ); 
BMU bmu_inst_56   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd56), 
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
        .ready_o            (bmu_ready_s[56]),
        .bm_o               (bm_s_56),
        .bm_valid_o         (bm_valid_s[56])
        ); 
BMU bmu_inst_57   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd57), 
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
        .ready_o            (bmu_ready_s[57]),
        .bm_o               (bm_s_57),
        .bm_valid_o         (bm_valid_s[57])
        ); 
BMU bmu_inst_58   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd58), 
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
        .ready_o            (bmu_ready_s[58]),
        .bm_o               (bm_s_58),
        .bm_valid_o         (bm_valid_s[58])
        ); 
BMU bmu_inst_59   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd59), 
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
        .ready_o            (bmu_ready_s[59]),
        .bm_o               (bm_s_59),
        .bm_valid_o         (bm_valid_s[59])
        ); 
BMU bmu_inst_60   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd60), 
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
        .ready_o            (bmu_ready_s[60]),
        .bm_o               (bm_s_60),
        .bm_valid_o         (bm_valid_s[60])
        ); 
BMU bmu_inst_61   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd61), 
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
        .ready_o            (bmu_ready_s[61]),
        .bm_o               (bm_s_61),
        .bm_valid_o         (bm_valid_s[61])
        ); 
BMU bmu_inst_62   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd62), 
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
        .ready_o            (bmu_ready_s[62]),
        .bm_o               (bm_s_62),
        .bm_valid_o         (bm_valid_s[62])
        ); 
BMU bmu_inst_63   ( 
        .clk_i              (clk_i), 
        .rst_an_i           (rst_an_i), 
        .rst_sync_i         (rst_sync_i),   
        .frame_start_i            (frame_start_i),    // a pulse to start 
        .state_x_i          (6'd63), 
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
        .ready_o            (bmu_ready_s[63]),
        .bm_o               (bm_s_63),
        .bm_valid_o         (bm_valid_s[63])
        ); 


ACS acs_inst_0  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_0), 
             .bm_valid_i     (bm_valid_s[0]), 
             .prev_low_i     (pm_r_s_0),  
             .prev_high1_i   (pm_r_s_4),  
             .prev_high2_i   (pm_r_s_8),   
             .prev_high3_i   (pm_r_s_16),   
             .prev_high4_i   (pm_r_s_32),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd0 ), 
             .pm_o           (pm_tmp_s_0), 
             .survivor_path_o(survivor_path_s[0]), 
              .valid_o        (acs_valid_s[0]) 
             );

ACS acs_inst_1  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_1), 
             .bm_valid_i     (bm_valid_s[1]), 
             .prev_low_i     (pm_r_s_0),  
             .prev_high1_i   (pm_r_s_4),  
             .prev_high2_i   (pm_r_s_8),   
             .prev_high3_i   (pm_r_s_16),   
             .prev_high4_i   (pm_r_s_32),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd1 ), 
             .pm_o           (pm_tmp_s_1), 
             .survivor_path_o(survivor_path_s[1]), 
              .valid_o        (acs_valid_s[1]) 
             );

ACS acs_inst_2  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_2), 
             .bm_valid_i     (bm_valid_s[2]), 
             .prev_low_i     (pm_r_s_1),  
             .prev_high1_i   (pm_r_s_5),  
             .prev_high2_i   (pm_r_s_9),   
             .prev_high3_i   (pm_r_s_17),   
             .prev_high4_i   (pm_r_s_33),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd2 ), 
             .pm_o           (pm_tmp_s_2), 
             .survivor_path_o(survivor_path_s[2]), 
              .valid_o        (acs_valid_s[2]) 
             );

ACS acs_inst_3  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_3), 
             .bm_valid_i     (bm_valid_s[3]), 
             .prev_low_i     (pm_r_s_1),  
             .prev_high1_i   (pm_r_s_5),  
             .prev_high2_i   (pm_r_s_9),   
             .prev_high3_i   (pm_r_s_17),   
             .prev_high4_i   (pm_r_s_33),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd3 ), 
             .pm_o           (pm_tmp_s_3), 
             .survivor_path_o(survivor_path_s[3]), 
              .valid_o        (acs_valid_s[3]) 
             );

ACS acs_inst_4  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_4), 
             .bm_valid_i     (bm_valid_s[4]), 
             .prev_low_i     (pm_r_s_2),  
             .prev_high1_i   (pm_r_s_6),  
             .prev_high2_i   (pm_r_s_10),   
             .prev_high3_i   (pm_r_s_18),   
             .prev_high4_i   (pm_r_s_34),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd4 ), 
             .pm_o           (pm_tmp_s_4), 
             .survivor_path_o(survivor_path_s[4]), 
              .valid_o        (acs_valid_s[4]) 
             );

ACS acs_inst_5  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_5), 
             .bm_valid_i     (bm_valid_s[5]), 
             .prev_low_i     (pm_r_s_2),  
             .prev_high1_i   (pm_r_s_6),  
             .prev_high2_i   (pm_r_s_10),   
             .prev_high3_i   (pm_r_s_18),   
             .prev_high4_i   (pm_r_s_34),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd5 ), 
             .pm_o           (pm_tmp_s_5), 
             .survivor_path_o(survivor_path_s[5]), 
              .valid_o        (acs_valid_s[5]) 
             );

ACS acs_inst_6  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_6), 
             .bm_valid_i     (bm_valid_s[6]), 
             .prev_low_i     (pm_r_s_3),  
             .prev_high1_i   (pm_r_s_7),  
             .prev_high2_i   (pm_r_s_11),   
             .prev_high3_i   (pm_r_s_19),   
             .prev_high4_i   (pm_r_s_35),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd6 ), 
             .pm_o           (pm_tmp_s_6), 
             .survivor_path_o(survivor_path_s[6]), 
              .valid_o        (acs_valid_s[6]) 
             );

ACS acs_inst_7  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_7), 
             .bm_valid_i     (bm_valid_s[7]), 
             .prev_low_i     (pm_r_s_3),  
             .prev_high1_i   (pm_r_s_7),  
             .prev_high2_i   (pm_r_s_11),   
             .prev_high3_i   (pm_r_s_19),   
             .prev_high4_i   (pm_r_s_35),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd7 ), 
             .pm_o           (pm_tmp_s_7), 
             .survivor_path_o(survivor_path_s[7]), 
              .valid_o        (acs_valid_s[7]) 
             );

ACS acs_inst_8  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_8), 
             .bm_valid_i     (bm_valid_s[8]), 
             .prev_low_i     (pm_r_s_4),  
             .prev_high1_i   (pm_r_s_8),  
             .prev_high2_i   (pm_r_s_12),   
             .prev_high3_i   (pm_r_s_20),   
             .prev_high4_i   (pm_r_s_36),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd8 ), 
             .pm_o           (pm_tmp_s_8), 
             .survivor_path_o(survivor_path_s[8]), 
              .valid_o        (acs_valid_s[8]) 
             );

ACS acs_inst_9  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_9), 
             .bm_valid_i     (bm_valid_s[9]), 
             .prev_low_i     (pm_r_s_4),  
             .prev_high1_i   (pm_r_s_8),  
             .prev_high2_i   (pm_r_s_12),   
             .prev_high3_i   (pm_r_s_20),   
             .prev_high4_i   (pm_r_s_36),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd9 ), 
             .pm_o           (pm_tmp_s_9), 
             .survivor_path_o(survivor_path_s[9]), 
              .valid_o        (acs_valid_s[9]) 
             );

ACS acs_inst_10  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_10), 
             .bm_valid_i     (bm_valid_s[10]), 
             .prev_low_i     (pm_r_s_5),  
             .prev_high1_i   (pm_r_s_9),  
             .prev_high2_i   (pm_r_s_13),   
             .prev_high3_i   (pm_r_s_21),   
             .prev_high4_i   (pm_r_s_37),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd10 ), 
             .pm_o           (pm_tmp_s_10), 
             .survivor_path_o(survivor_path_s[10]), 
              .valid_o        (acs_valid_s[10]) 
             );

ACS acs_inst_11  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_11), 
             .bm_valid_i     (bm_valid_s[11]), 
             .prev_low_i     (pm_r_s_5),  
             .prev_high1_i   (pm_r_s_9),  
             .prev_high2_i   (pm_r_s_13),   
             .prev_high3_i   (pm_r_s_21),   
             .prev_high4_i   (pm_r_s_37),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd11 ), 
             .pm_o           (pm_tmp_s_11), 
             .survivor_path_o(survivor_path_s[11]), 
              .valid_o        (acs_valid_s[11]) 
             );

ACS acs_inst_12  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_12), 
             .bm_valid_i     (bm_valid_s[12]), 
             .prev_low_i     (pm_r_s_6),  
             .prev_high1_i   (pm_r_s_10),  
             .prev_high2_i   (pm_r_s_14),   
             .prev_high3_i   (pm_r_s_22),   
             .prev_high4_i   (pm_r_s_38),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd12 ), 
             .pm_o           (pm_tmp_s_12), 
             .survivor_path_o(survivor_path_s[12]), 
              .valid_o        (acs_valid_s[12]) 
             );

ACS acs_inst_13  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_13), 
             .bm_valid_i     (bm_valid_s[13]), 
             .prev_low_i     (pm_r_s_6),  
             .prev_high1_i   (pm_r_s_10),  
             .prev_high2_i   (pm_r_s_14),   
             .prev_high3_i   (pm_r_s_22),   
             .prev_high4_i   (pm_r_s_38),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd13 ), 
             .pm_o           (pm_tmp_s_13), 
             .survivor_path_o(survivor_path_s[13]), 
              .valid_o        (acs_valid_s[13]) 
             );

ACS acs_inst_14  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_14), 
             .bm_valid_i     (bm_valid_s[14]), 
             .prev_low_i     (pm_r_s_7),  
             .prev_high1_i   (pm_r_s_11),  
             .prev_high2_i   (pm_r_s_15),   
             .prev_high3_i   (pm_r_s_23),   
             .prev_high4_i   (pm_r_s_39),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd14 ), 
             .pm_o           (pm_tmp_s_14), 
             .survivor_path_o(survivor_path_s[14]), 
              .valid_o        (acs_valid_s[14]) 
             );

ACS acs_inst_15  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_15), 
             .bm_valid_i     (bm_valid_s[15]), 
             .prev_low_i     (pm_r_s_7),  
             .prev_high1_i   (pm_r_s_11),  
             .prev_high2_i   (pm_r_s_15),   
             .prev_high3_i   (pm_r_s_23),   
             .prev_high4_i   (pm_r_s_39),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd15 ), 
             .pm_o           (pm_tmp_s_15), 
             .survivor_path_o(survivor_path_s[15]), 
              .valid_o        (acs_valid_s[15]) 
             );

ACS acs_inst_16  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_16), 
             .bm_valid_i     (bm_valid_s[16]), 
             .prev_low_i     (pm_r_s_8),  
             .prev_high1_i   (pm_r_s_12),  
             .prev_high2_i   (pm_r_s_16),   
             .prev_high3_i   (pm_r_s_24),   
             .prev_high4_i   (pm_r_s_40),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd16 ), 
             .pm_o           (pm_tmp_s_16), 
             .survivor_path_o(survivor_path_s[16]), 
              .valid_o        (acs_valid_s[16]) 
             );

ACS acs_inst_17  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_17), 
             .bm_valid_i     (bm_valid_s[17]), 
             .prev_low_i     (pm_r_s_8),  
             .prev_high1_i   (pm_r_s_12),  
             .prev_high2_i   (pm_r_s_16),   
             .prev_high3_i   (pm_r_s_24),   
             .prev_high4_i   (pm_r_s_40),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd17 ), 
             .pm_o           (pm_tmp_s_17), 
             .survivor_path_o(survivor_path_s[17]), 
              .valid_o        (acs_valid_s[17]) 
             );

ACS acs_inst_18  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_18), 
             .bm_valid_i     (bm_valid_s[18]), 
             .prev_low_i     (pm_r_s_9),  
             .prev_high1_i   (pm_r_s_13),  
             .prev_high2_i   (pm_r_s_17),   
             .prev_high3_i   (pm_r_s_25),   
             .prev_high4_i   (pm_r_s_41),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd18 ), 
             .pm_o           (pm_tmp_s_18), 
             .survivor_path_o(survivor_path_s[18]), 
              .valid_o        (acs_valid_s[18]) 
             );

ACS acs_inst_19  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_19), 
             .bm_valid_i     (bm_valid_s[19]), 
             .prev_low_i     (pm_r_s_9),  
             .prev_high1_i   (pm_r_s_13),  
             .prev_high2_i   (pm_r_s_17),   
             .prev_high3_i   (pm_r_s_25),   
             .prev_high4_i   (pm_r_s_41),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd19 ), 
             .pm_o           (pm_tmp_s_19), 
             .survivor_path_o(survivor_path_s[19]), 
              .valid_o        (acs_valid_s[19]) 
             );

ACS acs_inst_20  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_20), 
             .bm_valid_i     (bm_valid_s[20]), 
             .prev_low_i     (pm_r_s_10),  
             .prev_high1_i   (pm_r_s_14),  
             .prev_high2_i   (pm_r_s_18),   
             .prev_high3_i   (pm_r_s_26),   
             .prev_high4_i   (pm_r_s_42),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd20 ), 
             .pm_o           (pm_tmp_s_20), 
             .survivor_path_o(survivor_path_s[20]), 
              .valid_o        (acs_valid_s[20]) 
             );

ACS acs_inst_21  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_21), 
             .bm_valid_i     (bm_valid_s[21]), 
             .prev_low_i     (pm_r_s_10),  
             .prev_high1_i   (pm_r_s_14),  
             .prev_high2_i   (pm_r_s_18),   
             .prev_high3_i   (pm_r_s_26),   
             .prev_high4_i   (pm_r_s_42),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd21 ), 
             .pm_o           (pm_tmp_s_21), 
             .survivor_path_o(survivor_path_s[21]), 
              .valid_o        (acs_valid_s[21]) 
             );

ACS acs_inst_22  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_22), 
             .bm_valid_i     (bm_valid_s[22]), 
             .prev_low_i     (pm_r_s_11),  
             .prev_high1_i   (pm_r_s_15),  
             .prev_high2_i   (pm_r_s_19),   
             .prev_high3_i   (pm_r_s_27),   
             .prev_high4_i   (pm_r_s_43),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd22 ), 
             .pm_o           (pm_tmp_s_22), 
             .survivor_path_o(survivor_path_s[22]), 
              .valid_o        (acs_valid_s[22]) 
             );

ACS acs_inst_23  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_23), 
             .bm_valid_i     (bm_valid_s[23]), 
             .prev_low_i     (pm_r_s_11),  
             .prev_high1_i   (pm_r_s_15),  
             .prev_high2_i   (pm_r_s_19),   
             .prev_high3_i   (pm_r_s_27),   
             .prev_high4_i   (pm_r_s_43),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd23 ), 
             .pm_o           (pm_tmp_s_23), 
             .survivor_path_o(survivor_path_s[23]), 
              .valid_o        (acs_valid_s[23]) 
             );

ACS acs_inst_24  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_24), 
             .bm_valid_i     (bm_valid_s[24]), 
             .prev_low_i     (pm_r_s_12),  
             .prev_high1_i   (pm_r_s_16),  
             .prev_high2_i   (pm_r_s_20),   
             .prev_high3_i   (pm_r_s_28),   
             .prev_high4_i   (pm_r_s_44),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd24 ), 
             .pm_o           (pm_tmp_s_24), 
             .survivor_path_o(survivor_path_s[24]), 
              .valid_o        (acs_valid_s[24]) 
             );

ACS acs_inst_25  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_25), 
             .bm_valid_i     (bm_valid_s[25]), 
             .prev_low_i     (pm_r_s_12),  
             .prev_high1_i   (pm_r_s_16),  
             .prev_high2_i   (pm_r_s_20),   
             .prev_high3_i   (pm_r_s_28),   
             .prev_high4_i   (pm_r_s_44),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd25 ), 
             .pm_o           (pm_tmp_s_25), 
             .survivor_path_o(survivor_path_s[25]), 
              .valid_o        (acs_valid_s[25]) 
             );

ACS acs_inst_26  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_26), 
             .bm_valid_i     (bm_valid_s[26]), 
             .prev_low_i     (pm_r_s_13),  
             .prev_high1_i   (pm_r_s_17),  
             .prev_high2_i   (pm_r_s_21),   
             .prev_high3_i   (pm_r_s_29),   
             .prev_high4_i   (pm_r_s_45),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd26 ), 
             .pm_o           (pm_tmp_s_26), 
             .survivor_path_o(survivor_path_s[26]), 
              .valid_o        (acs_valid_s[26]) 
             );

ACS acs_inst_27  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_27), 
             .bm_valid_i     (bm_valid_s[27]), 
             .prev_low_i     (pm_r_s_13),  
             .prev_high1_i   (pm_r_s_17),  
             .prev_high2_i   (pm_r_s_21),   
             .prev_high3_i   (pm_r_s_29),   
             .prev_high4_i   (pm_r_s_45),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd27 ), 
             .pm_o           (pm_tmp_s_27), 
             .survivor_path_o(survivor_path_s[27]), 
              .valid_o        (acs_valid_s[27]) 
             );

ACS acs_inst_28  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_28), 
             .bm_valid_i     (bm_valid_s[28]), 
             .prev_low_i     (pm_r_s_14),  
             .prev_high1_i   (pm_r_s_18),  
             .prev_high2_i   (pm_r_s_22),   
             .prev_high3_i   (pm_r_s_30),   
             .prev_high4_i   (pm_r_s_46),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd28 ), 
             .pm_o           (pm_tmp_s_28), 
             .survivor_path_o(survivor_path_s[28]), 
              .valid_o        (acs_valid_s[28]) 
             );

ACS acs_inst_29  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_29), 
             .bm_valid_i     (bm_valid_s[29]), 
             .prev_low_i     (pm_r_s_14),  
             .prev_high1_i   (pm_r_s_18),  
             .prev_high2_i   (pm_r_s_22),   
             .prev_high3_i   (pm_r_s_30),   
             .prev_high4_i   (pm_r_s_46),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd29 ), 
             .pm_o           (pm_tmp_s_29), 
             .survivor_path_o(survivor_path_s[29]), 
              .valid_o        (acs_valid_s[29]) 
             );

ACS acs_inst_30  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_30), 
             .bm_valid_i     (bm_valid_s[30]), 
             .prev_low_i     (pm_r_s_15),  
             .prev_high1_i   (pm_r_s_19),  
             .prev_high2_i   (pm_r_s_23),   
             .prev_high3_i   (pm_r_s_31),   
             .prev_high4_i   (pm_r_s_47),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd30 ), 
             .pm_o           (pm_tmp_s_30), 
             .survivor_path_o(survivor_path_s[30]), 
              .valid_o        (acs_valid_s[30]) 
             );

ACS acs_inst_31  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_31), 
             .bm_valid_i     (bm_valid_s[31]), 
             .prev_low_i     (pm_r_s_15),  
             .prev_high1_i   (pm_r_s_19),  
             .prev_high2_i   (pm_r_s_23),   
             .prev_high3_i   (pm_r_s_31),   
             .prev_high4_i   (pm_r_s_47),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd31 ), 
             .pm_o           (pm_tmp_s_31), 
             .survivor_path_o(survivor_path_s[31]), 
              .valid_o        (acs_valid_s[31]) 
             );

ACS acs_inst_32  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_32), 
             .bm_valid_i     (bm_valid_s[32]), 
             .prev_low_i     (pm_r_s_16),  
             .prev_high1_i   (pm_r_s_20),  
             .prev_high2_i   (pm_r_s_24),   
             .prev_high3_i   (pm_r_s_32),   
             .prev_high4_i   (pm_r_s_48),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd32 ), 
             .pm_o           (pm_tmp_s_32), 
             .survivor_path_o(survivor_path_s[32]), 
              .valid_o        (acs_valid_s[32]) 
             );

ACS acs_inst_33  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_33), 
             .bm_valid_i     (bm_valid_s[33]), 
             .prev_low_i     (pm_r_s_16),  
             .prev_high1_i   (pm_r_s_20),  
             .prev_high2_i   (pm_r_s_24),   
             .prev_high3_i   (pm_r_s_32),   
             .prev_high4_i   (pm_r_s_48),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd33 ), 
             .pm_o           (pm_tmp_s_33), 
             .survivor_path_o(survivor_path_s[33]), 
              .valid_o        (acs_valid_s[33]) 
             );

ACS acs_inst_34  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_34), 
             .bm_valid_i     (bm_valid_s[34]), 
             .prev_low_i     (pm_r_s_17),  
             .prev_high1_i   (pm_r_s_21),  
             .prev_high2_i   (pm_r_s_25),   
             .prev_high3_i   (pm_r_s_33),   
             .prev_high4_i   (pm_r_s_49),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd34 ), 
             .pm_o           (pm_tmp_s_34), 
             .survivor_path_o(survivor_path_s[34]), 
              .valid_o        (acs_valid_s[34]) 
             );

ACS acs_inst_35  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_35), 
             .bm_valid_i     (bm_valid_s[35]), 
             .prev_low_i     (pm_r_s_17),  
             .prev_high1_i   (pm_r_s_21),  
             .prev_high2_i   (pm_r_s_25),   
             .prev_high3_i   (pm_r_s_33),   
             .prev_high4_i   (pm_r_s_49),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd35 ), 
             .pm_o           (pm_tmp_s_35), 
             .survivor_path_o(survivor_path_s[35]), 
              .valid_o        (acs_valid_s[35]) 
             );

ACS acs_inst_36  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_36), 
             .bm_valid_i     (bm_valid_s[36]), 
             .prev_low_i     (pm_r_s_18),  
             .prev_high1_i   (pm_r_s_22),  
             .prev_high2_i   (pm_r_s_26),   
             .prev_high3_i   (pm_r_s_34),   
             .prev_high4_i   (pm_r_s_50),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd36 ), 
             .pm_o           (pm_tmp_s_36), 
             .survivor_path_o(survivor_path_s[36]), 
              .valid_o        (acs_valid_s[36]) 
             );

ACS acs_inst_37  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_37), 
             .bm_valid_i     (bm_valid_s[37]), 
             .prev_low_i     (pm_r_s_18),  
             .prev_high1_i   (pm_r_s_22),  
             .prev_high2_i   (pm_r_s_26),   
             .prev_high3_i   (pm_r_s_34),   
             .prev_high4_i   (pm_r_s_50),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd37 ), 
             .pm_o           (pm_tmp_s_37), 
             .survivor_path_o(survivor_path_s[37]), 
              .valid_o        (acs_valid_s[37]) 
             );

ACS acs_inst_38  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_38), 
             .bm_valid_i     (bm_valid_s[38]), 
             .prev_low_i     (pm_r_s_19),  
             .prev_high1_i   (pm_r_s_23),  
             .prev_high2_i   (pm_r_s_27),   
             .prev_high3_i   (pm_r_s_35),   
             .prev_high4_i   (pm_r_s_51),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd38 ), 
             .pm_o           (pm_tmp_s_38), 
             .survivor_path_o(survivor_path_s[38]), 
              .valid_o        (acs_valid_s[38]) 
             );

ACS acs_inst_39  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_39), 
             .bm_valid_i     (bm_valid_s[39]), 
             .prev_low_i     (pm_r_s_19),  
             .prev_high1_i   (pm_r_s_23),  
             .prev_high2_i   (pm_r_s_27),   
             .prev_high3_i   (pm_r_s_35),   
             .prev_high4_i   (pm_r_s_51),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd39 ), 
             .pm_o           (pm_tmp_s_39), 
             .survivor_path_o(survivor_path_s[39]), 
              .valid_o        (acs_valid_s[39]) 
             );

ACS acs_inst_40  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_40), 
             .bm_valid_i     (bm_valid_s[40]), 
             .prev_low_i     (pm_r_s_20),  
             .prev_high1_i   (pm_r_s_24),  
             .prev_high2_i   (pm_r_s_28),   
             .prev_high3_i   (pm_r_s_36),   
             .prev_high4_i   (pm_r_s_52),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd40 ), 
             .pm_o           (pm_tmp_s_40), 
             .survivor_path_o(survivor_path_s[40]), 
              .valid_o        (acs_valid_s[40]) 
             );

ACS acs_inst_41  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_41), 
             .bm_valid_i     (bm_valid_s[41]), 
             .prev_low_i     (pm_r_s_20),  
             .prev_high1_i   (pm_r_s_24),  
             .prev_high2_i   (pm_r_s_28),   
             .prev_high3_i   (pm_r_s_36),   
             .prev_high4_i   (pm_r_s_52),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd41 ), 
             .pm_o           (pm_tmp_s_41), 
             .survivor_path_o(survivor_path_s[41]), 
              .valid_o        (acs_valid_s[41]) 
             );

ACS acs_inst_42  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_42), 
             .bm_valid_i     (bm_valid_s[42]), 
             .prev_low_i     (pm_r_s_21),  
             .prev_high1_i   (pm_r_s_25),  
             .prev_high2_i   (pm_r_s_29),   
             .prev_high3_i   (pm_r_s_37),   
             .prev_high4_i   (pm_r_s_53),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd42 ), 
             .pm_o           (pm_tmp_s_42), 
             .survivor_path_o(survivor_path_s[42]), 
              .valid_o        (acs_valid_s[42]) 
             );

ACS acs_inst_43  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_43), 
             .bm_valid_i     (bm_valid_s[43]), 
             .prev_low_i     (pm_r_s_21),  
             .prev_high1_i   (pm_r_s_25),  
             .prev_high2_i   (pm_r_s_29),   
             .prev_high3_i   (pm_r_s_37),   
             .prev_high4_i   (pm_r_s_53),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd43 ), 
             .pm_o           (pm_tmp_s_43), 
             .survivor_path_o(survivor_path_s[43]), 
              .valid_o        (acs_valid_s[43]) 
             );

ACS acs_inst_44  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_44), 
             .bm_valid_i     (bm_valid_s[44]), 
             .prev_low_i     (pm_r_s_22),  
             .prev_high1_i   (pm_r_s_26),  
             .prev_high2_i   (pm_r_s_30),   
             .prev_high3_i   (pm_r_s_38),   
             .prev_high4_i   (pm_r_s_54),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd44 ), 
             .pm_o           (pm_tmp_s_44), 
             .survivor_path_o(survivor_path_s[44]), 
              .valid_o        (acs_valid_s[44]) 
             );

ACS acs_inst_45  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_45), 
             .bm_valid_i     (bm_valid_s[45]), 
             .prev_low_i     (pm_r_s_22),  
             .prev_high1_i   (pm_r_s_26),  
             .prev_high2_i   (pm_r_s_30),   
             .prev_high3_i   (pm_r_s_38),   
             .prev_high4_i   (pm_r_s_54),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd45 ), 
             .pm_o           (pm_tmp_s_45), 
             .survivor_path_o(survivor_path_s[45]), 
              .valid_o        (acs_valid_s[45]) 
             );

ACS acs_inst_46  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_46), 
             .bm_valid_i     (bm_valid_s[46]), 
             .prev_low_i     (pm_r_s_23),  
             .prev_high1_i   (pm_r_s_27),  
             .prev_high2_i   (pm_r_s_31),   
             .prev_high3_i   (pm_r_s_39),   
             .prev_high4_i   (pm_r_s_55),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd46 ), 
             .pm_o           (pm_tmp_s_46), 
             .survivor_path_o(survivor_path_s[46]), 
              .valid_o        (acs_valid_s[46]) 
             );

ACS acs_inst_47  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_47), 
             .bm_valid_i     (bm_valid_s[47]), 
             .prev_low_i     (pm_r_s_23),  
             .prev_high1_i   (pm_r_s_27),  
             .prev_high2_i   (pm_r_s_31),   
             .prev_high3_i   (pm_r_s_39),   
             .prev_high4_i   (pm_r_s_55),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd47 ), 
             .pm_o           (pm_tmp_s_47), 
             .survivor_path_o(survivor_path_s[47]), 
              .valid_o        (acs_valid_s[47]) 
             );

ACS acs_inst_48  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_48), 
             .bm_valid_i     (bm_valid_s[48]), 
             .prev_low_i     (pm_r_s_24),  
             .prev_high1_i   (pm_r_s_28),  
             .prev_high2_i   (pm_r_s_32),   
             .prev_high3_i   (pm_r_s_40),   
             .prev_high4_i   (pm_r_s_56),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd48 ), 
             .pm_o           (pm_tmp_s_48), 
             .survivor_path_o(survivor_path_s[48]), 
              .valid_o        (acs_valid_s[48]) 
             );

ACS acs_inst_49  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_49), 
             .bm_valid_i     (bm_valid_s[49]), 
             .prev_low_i     (pm_r_s_24),  
             .prev_high1_i   (pm_r_s_28),  
             .prev_high2_i   (pm_r_s_32),   
             .prev_high3_i   (pm_r_s_40),   
             .prev_high4_i   (pm_r_s_56),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd49 ), 
             .pm_o           (pm_tmp_s_49), 
             .survivor_path_o(survivor_path_s[49]), 
              .valid_o        (acs_valid_s[49]) 
             );

ACS acs_inst_50  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_50), 
             .bm_valid_i     (bm_valid_s[50]), 
             .prev_low_i     (pm_r_s_25),  
             .prev_high1_i   (pm_r_s_29),  
             .prev_high2_i   (pm_r_s_33),   
             .prev_high3_i   (pm_r_s_41),   
             .prev_high4_i   (pm_r_s_57),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd50 ), 
             .pm_o           (pm_tmp_s_50), 
             .survivor_path_o(survivor_path_s[50]), 
              .valid_o        (acs_valid_s[50]) 
             );

ACS acs_inst_51  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_51), 
             .bm_valid_i     (bm_valid_s[51]), 
             .prev_low_i     (pm_r_s_25),  
             .prev_high1_i   (pm_r_s_29),  
             .prev_high2_i   (pm_r_s_33),   
             .prev_high3_i   (pm_r_s_41),   
             .prev_high4_i   (pm_r_s_57),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd51 ), 
             .pm_o           (pm_tmp_s_51), 
             .survivor_path_o(survivor_path_s[51]), 
              .valid_o        (acs_valid_s[51]) 
             );

ACS acs_inst_52  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_52), 
             .bm_valid_i     (bm_valid_s[52]), 
             .prev_low_i     (pm_r_s_26),  
             .prev_high1_i   (pm_r_s_30),  
             .prev_high2_i   (pm_r_s_34),   
             .prev_high3_i   (pm_r_s_42),   
             .prev_high4_i   (pm_r_s_58),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd52 ), 
             .pm_o           (pm_tmp_s_52), 
             .survivor_path_o(survivor_path_s[52]), 
              .valid_o        (acs_valid_s[52]) 
             );

ACS acs_inst_53  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_53), 
             .bm_valid_i     (bm_valid_s[53]), 
             .prev_low_i     (pm_r_s_26),  
             .prev_high1_i   (pm_r_s_30),  
             .prev_high2_i   (pm_r_s_34),   
             .prev_high3_i   (pm_r_s_42),   
             .prev_high4_i   (pm_r_s_58),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd53 ), 
             .pm_o           (pm_tmp_s_53), 
             .survivor_path_o(survivor_path_s[53]), 
              .valid_o        (acs_valid_s[53]) 
             );

ACS acs_inst_54  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_54), 
             .bm_valid_i     (bm_valid_s[54]), 
             .prev_low_i     (pm_r_s_27),  
             .prev_high1_i   (pm_r_s_31),  
             .prev_high2_i   (pm_r_s_35),   
             .prev_high3_i   (pm_r_s_43),   
             .prev_high4_i   (pm_r_s_59),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd54 ), 
             .pm_o           (pm_tmp_s_54), 
             .survivor_path_o(survivor_path_s[54]), 
              .valid_o        (acs_valid_s[54]) 
             );

ACS acs_inst_55  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_55), 
             .bm_valid_i     (bm_valid_s[55]), 
             .prev_low_i     (pm_r_s_27),  
             .prev_high1_i   (pm_r_s_31),  
             .prev_high2_i   (pm_r_s_35),   
             .prev_high3_i   (pm_r_s_43),   
             .prev_high4_i   (pm_r_s_59),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd55 ), 
             .pm_o           (pm_tmp_s_55), 
             .survivor_path_o(survivor_path_s[55]), 
              .valid_o        (acs_valid_s[55]) 
             );

ACS acs_inst_56  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_56), 
             .bm_valid_i     (bm_valid_s[56]), 
             .prev_low_i     (pm_r_s_28),  
             .prev_high1_i   (pm_r_s_32),  
             .prev_high2_i   (pm_r_s_36),   
             .prev_high3_i   (pm_r_s_44),   
             .prev_high4_i   (pm_r_s_60),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd56 ), 
             .pm_o           (pm_tmp_s_56), 
             .survivor_path_o(survivor_path_s[56]), 
              .valid_o        (acs_valid_s[56]) 
             );

ACS acs_inst_57  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_57), 
             .bm_valid_i     (bm_valid_s[57]), 
             .prev_low_i     (pm_r_s_28),  
             .prev_high1_i   (pm_r_s_32),  
             .prev_high2_i   (pm_r_s_36),   
             .prev_high3_i   (pm_r_s_44),   
             .prev_high4_i   (pm_r_s_60),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd57 ), 
             .pm_o           (pm_tmp_s_57), 
             .survivor_path_o(survivor_path_s[57]), 
              .valid_o        (acs_valid_s[57]) 
             );

ACS acs_inst_58  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_58), 
             .bm_valid_i     (bm_valid_s[58]), 
             .prev_low_i     (pm_r_s_29),  
             .prev_high1_i   (pm_r_s_33),  
             .prev_high2_i   (pm_r_s_37),   
             .prev_high3_i   (pm_r_s_45),   
             .prev_high4_i   (pm_r_s_61),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd58 ), 
             .pm_o           (pm_tmp_s_58), 
             .survivor_path_o(survivor_path_s[58]), 
              .valid_o        (acs_valid_s[58]) 
             );

ACS acs_inst_59  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_59), 
             .bm_valid_i     (bm_valid_s[59]), 
             .prev_low_i     (pm_r_s_29),  
             .prev_high1_i   (pm_r_s_33),  
             .prev_high2_i   (pm_r_s_37),   
             .prev_high3_i   (pm_r_s_45),   
             .prev_high4_i   (pm_r_s_61),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd59 ), 
             .pm_o           (pm_tmp_s_59), 
             .survivor_path_o(survivor_path_s[59]), 
              .valid_o        (acs_valid_s[59]) 
             );

ACS acs_inst_60  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s ),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_60), 
             .bm_valid_i     (bm_valid_s[60]), 
             .prev_low_i     (pm_r_s_30),  
             .prev_high1_i   (pm_r_s_34),  
             .prev_high2_i   (pm_r_s_38),   
             .prev_high3_i   (pm_r_s_46),   
             .prev_high4_i   (pm_r_s_62),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd60 ), 
             .pm_o           (pm_tmp_s_60), 
             .survivor_path_o(survivor_path_s[60]), 
              .valid_o        (acs_valid_s[60]) 
             );

ACS acs_inst_61  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s ),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_61), 
             .bm_valid_i     (bm_valid_s[61]), 
             .prev_low_i     (pm_r_s_30),  
             .prev_high1_i   (pm_r_s_34),  
             .prev_high2_i   (pm_r_s_38),   
             .prev_high3_i   (pm_r_s_46),   
             .prev_high4_i   (pm_r_s_62),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd61 ), 
             .pm_o           (pm_tmp_s_61), 
             .survivor_path_o(survivor_path_s[61]), 
              .valid_o        (acs_valid_s[61]) 
             );

ACS acs_inst_62  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s ),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_62), 
             .bm_valid_i     (bm_valid_s[62]), 
             .prev_low_i     (pm_r_s_31),  
             .prev_high1_i   (pm_r_s_35),  
             .prev_high2_i   (pm_r_s_39),   
             .prev_high3_i   (pm_r_s_47),   
             .prev_high4_i   (pm_r_s_63),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd62 ), 
             .pm_o           (pm_tmp_s_62), 
             .survivor_path_o(survivor_path_s[62]), 
              .valid_o        (acs_valid_s[62]) 
             );

ACS acs_inst_63  (
             .clk_i          (clk_i),
             .rst_an_i       (rst_an_i),
             .rst_sync_i     (rst_sync_i),
             .en_i           (acs_en_s ),
             .is_t0_i        (is_t0_s),
             .bm_i           (bm_s_63), 
             .bm_valid_i     (bm_valid_s[63]), 
             .prev_low_i     (pm_r_s_31),  
             .prev_high1_i   (pm_r_s_35),  
             .prev_high2_i   (pm_r_s_39),   
             .prev_high3_i   (pm_r_s_47),   
             .prev_high4_i   (pm_r_s_63),   
             .tail_biting_en_i (tail_biting_en_i),
             .state_k_i      ( 6'd63 ), 
             .pm_o           (pm_tmp_s_63), 
             .survivor_path_o(survivor_path_s[63]), 
              .valid_o        (acs_valid_s[63]) 
             );





endmodule
