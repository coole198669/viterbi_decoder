`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:06:49 09/28/2018 
// Design Name: 
// Module Name:    tb 
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
module tb_tcase4(    );
	 
	 parameter WIDTH_BM = 9,SRC_ADDR_W = 12 , DST_ADDR_W = 12,W_TB_ADDR=6;
 
	 reg clk_i;
    reg rst_an_i;
    reg rst_sync_i;   
    reg frame_start_i; 
    reg [1:0] register_num_i;      
    reg [2:0] valid_polynomials_i; 
    reg        tail_biting_en_i;         
    reg [7:0] polynomial1_i;
    reg [7:0] polynomial2_i;
    reg [7:0] polynomial3_i;
    reg [7:0] polynomial4_i;
    reg [7:0] polynomial5_i;
    reg [7:0] polynomial6_i;
    reg [11:0] infobit_length_i;
    reg [12:0] decoding_length_i;  
    reg [SRC_ADDR_W-1:0]  src_start_addr_i;
    reg [DST_ADDR_W-1:0]  dst_start_addr_i;
     //status output
    wire frame_done_o; // a pulse after one fream decoding done
    wire busy_o; // one frame is not finish
     // sram read port for fetching softbits from input buffer
    wire                   src_rd_o;
    wire [SRC_ADDR_W-1:0]  src_addr_o;
    wire  [23:0]            src_rdata_i;
      // sram write port to output buffer
     wire                   dst_wr_o;
     wire [DST_ADDR_W-1:0]    dst_addr_o;
     wire [7:0]             dst_wdata_o;
     //sram wr/rd port to traceback buffer(survival path buffer)
     wire                   tb_wr_o;
     wire                   tb_rd_o;
     wire [W_TB_ADDR-1:0]   tb_addr_o;
     wire [63:0]            tb_wdata_o;
     wire [63:0]            tb_rdata_i;
	  
	  reg  [7:0]             idx;
	  reg                      inject_wr;
	  reg  [23:0]              inject_wdata;
	  reg  [SRC_ADDR_W-1:0]    inject_wr_idx;
	  reg  [SRC_ADDR_W-1:0]    inject_wr_addr;
	  reg  [15:0]              inject_rd_idx;
	  reg  [23:0]              inject_buffer[35000:0];
	  
	  wire [SRC_ADDR_W-1:0]  src_addr_mux_s;
     integer fp_w,fp_state_w;// file hander
	  
	  wire  state_update;
	  wire decoding_end,traceback_start;	 
/////////////////////////////////////////////////////////////////////////////////////////
//
//       TESTBENCH BODY START
//
/////////////////////////////////////////////////////////////////////////////////////////	  
	  
//assign src_rdata_i =24'hFFFFFF;
always #10 clk_i=~clk_i;

assign src_addr_mux_s = inject_wr ? inject_wr_addr : src_addr_o;

initial begin
   clk_i=0;
	rst_an_i=0;
	rst_sync_i =0;   
   frame_start_i=0; 
    register_num_i = 2;      
   valid_polynomials_i = 1 ; 
   tail_biting_en_i =0;         
   infobit_length_i='h98;
   decoding_length_i=0;  
   src_start_addr_i=0;
   dst_start_addr_i=0;
   polynomial1_i = 8'b00011011;
   polynomial2_i = 8'b00010101;
   polynomial3_i = 8'b00011111;
   polynomial4_i = 8'o0;
   polynomial5_i = 8'o0;
   polynomial6_i = 8'o0; 
	
	
	 inject_wr = 0;
	 inject_wdata = 0;
	 inject_wr_idx = 0;
	 inject_wr_addr = 0;
	 inject_rd_idx = 0;
	fp_w=$fopen("case4_tv_data_out.txt","w"); 
	fp_state_w=$fopen("case4_state_out.txt","w"); 
	$readmemh("testvectors/case4_tv/input.txt", inject_buffer);
	#161;
	rst_an_i=1;
	#40;
	
	#80;
	
	for(idx=0;idx<100;idx=idx+1) begin
	  //inject source data to input mem
	  
	  for( inject_wr_idx = 0; inject_wr_idx<'h98; inject_wr_idx=inject_wr_idx+1) begin
	    inject_wr      = 1;
	    inject_wr_addr = inject_wr_idx;
	    inject_wdata   = inject_buffer[inject_rd_idx];
	    inject_rd_idx  = inject_rd_idx+1;
	    #20;
	  end
	  inject_wr = 0;
	  inject_wdata = 0;
     
	  #200;
  
	  frame_start_i=1; 
	  #20;
	  frame_start_i=0; 
	  #200;
     wait(frame_done_o);
	  #100;
	end
	//repeat 8000 @(posedge clk_i);
	#800;
	$fclose(fp_w);	
	$fclose(fp_state_w);	
   #100;	
	$finish;

end

always@(posedge clk_i)begin

if(dst_wr_o) begin
  $display("%b",dst_wdata_o[0]);
  $display("%b",dst_wdata_o[1]);
  $display("%b",dst_wdata_o[2]);
  $display("%b",dst_wdata_o[3]);
  $display("%b",dst_wdata_o[4]);
  $display("%b",dst_wdata_o[5]);
  $display("%b",dst_wdata_o[6]);
  $display("%b",dst_wdata_o[7]);
  $fwrite(fp_w,"%b\n",dst_wdata_o[0]);
  $fwrite(fp_w,"%b\n",dst_wdata_o[1]);
  $fwrite(fp_w,"%b\n",dst_wdata_o[2]);
  $fwrite(fp_w,"%b\n",dst_wdata_o[3]);
  $fwrite(fp_w,"%b\n",dst_wdata_o[4]);
  $fwrite(fp_w,"%b\n",dst_wdata_o[5]);
  $fwrite(fp_w,"%b\n",dst_wdata_o[6]);
  $fwrite(fp_w,"%b\n",dst_wdata_o[7]); 

end

end

assign state_update = dut.bmu_inst_0.bm_valid_o;
assign decoding_end =  dut.decoding_end_s;
assign traceback_start = dut.traceback_start_r;


always@(posedge clk_i)begin

if(state_update|(decoding_end&traceback_start)  ) begin
  
 $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_0) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_1) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_2) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_3) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_4) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_5) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_6) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_7) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_8) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_9) );

  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_10) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_11) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_12) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_13) );
  $fwrite(fp_state_w,"%d\n", $signed( dut.pm_r_s_14) );
  $fwrite(fp_state_w,"%d\n\n", $signed( dut.pm_r_s_15) );
  
end

end

 
 viterbi_core dut  (
     .clk_i              (  clk_i                 ),
     .rst_an_i           (  rst_an_i                 ),
     .rst_sync_i         (  rst_sync_i                    ),
     .frame_start_i      (  frame_start_i                  ),
     .register_num_i     (  register_num_i                      ), 
     .valid_polynomials_i(  valid_polynomials_i                 ), 
     .tail_biting_en_i   (  tail_biting_en_i                    ),      
     .polynomial1_i      (  polynomial1_i                 ),
     .polynomial2_i      (  polynomial2_i                 ),
     .polynomial3_i      (  polynomial3_i                 ),
     .polynomial4_i      (  polynomial4_i                 ),
     .polynomial5_i      (  polynomial5_i                 ),
     .polynomial6_i      (  polynomial6_i                 ),
     .infobit_length_i   (  infobit_length_i                 ),
     .decoding_length_i  (  decoding_length_i                   ),
     .src_start_addr_i   (  src_start_addr_i                 ),
     .dst_start_addr_i   (  dst_start_addr_i                 ),
     //status output
     .frame_done_o       (  frame_done_o             ),                             // a pulse after one fream decoding done
     .busy_o             (  busy_o                   ),                      // one frame is not finish
     // sram read port for fetching softbits from input buffer
    .src_rd_o            (  src_rd_o        ),                                
    .src_addr_o          (  src_addr_o      ),                                  
    .src_rdata_i         (  src_rdata_i     ),                                   
      // sram write port to output buffer
    .dst_wr_o            (dst_wr_o      ),                                
    .dst_addr_o          (dst_addr_o    ),                                  
    .dst_wdata_o         (dst_wdata_o   ),                                   
     //sram wr/rd port to traceback buffer(survival path buffer)
    .tb_wr_o             (    tb_wr_o    ),                           
    .tb_rd_o             (    tb_rd_o    ),                          
    .tb_addr_o           (    tb_addr_o  ),                            
    .tb_wdata_o          (    tb_wdata_o ),                             
    .tb_rdata_i          (    tb_rdata_i )

    );
sram_24x4096 in_buf(
    .clk_i  ( clk_i ),
    .rst_i  ( rst_an_i ),
    .wr_en_i( inject_wr ),
    .rd_en_i( src_rd_o ),
    .addr_i ( src_addr_mux_s ),
    .wdata_i( inject_wdata ),
	 .rdata_o( src_rdata_i ) 
);	 
	 
 sram_64x64	 sram_64x64_inst(
    .clk_i(clk_i),
    .rst_i(rst_an_i),
    .wr_en_i(tb_wr_o),
    .rd_en_i(tb_rd_o),
    .addr_i(tb_addr_o),
    .wdata_i(tb_wdata_o),
	 .rdata_o(tb_rdata_i)
);
endmodule
