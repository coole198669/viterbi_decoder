`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:08:34 10/03/2018 
// Design Name: 
// Module Name:    BMU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: BMU,Branch Metric Unit
// The trellis current state is x, the previous states are x>>1 and 2^k+x>>1,
// The BMU can genteated the Branch Metrics of low path and high path.
// Low path: x>>1 --> x
// High Path: 2^k+x --> x
// Dependencies: 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module BMU  #(parameter WIDTH_BM = 8 ) (
    input clk_i,
    input rst_an_i,
    input rst_sync_i,    
    input frame_start_i,    // a pulse to start
    input [5:0] state_x_i,
    input [23:0] soft_data_i,
    input soft_data_valid_i,
    input [1:0] register_num_i,
    input [2:0] valid_polynomials_i,
    input [7:0] polynomial1_i,
    input [7:0] polynomial2_i,
    input [7:0] polynomial3_i,
    input [7:0] polynomial4_i,
    input [7:0] polynomial5_i,
    input [7:0] polynomial6_i,

    output ready_o,
    output [WIDTH_BM-1:0] bm_o,
    output  bm_valid_o
    );

reg ready_r;    
reg calc_polyn_en, calc_codeword_en;
reg [5:0] low_codeword_tmp,low_codeword;
 

wire [5:0] half_polyn_tmp;

wire [3:0] soft_bit0,soft_bit1,soft_bit2,soft_bit3,soft_bit4,soft_bit5; 
wire signed [3:0] x_soft_bit0,x_soft_bit1,x_soft_bit2,x_soft_bit3,x_soft_bit4,x_soft_bit5; 

reg signed [WIDTH_BM-1:0] bm_r;
reg bm_valid_r;

assign bm_o =  bm_r;
assign bm_valid_o = bm_valid_r;
assign ready_o = ready_r;
//generate initiation control signals' pulse
always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i) begin 
      calc_polyn_en    <= 1'b0; 
      calc_codeword_en <= 1'b0;       
    end
  else if(rst_sync_i) begin 
      calc_polyn_en    <= 1'b0; 
      calc_codeword_en <= 1'b0;      
    end
  else begin 
      calc_polyn_en    <= frame_start_i; 
      calc_codeword_en <= calc_polyn_en;      
    end
end


always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i) 
      ready_r    <= 1'b0;     
  else if(rst_sync_i|frame_start_i) 
      ready_r    <= 1'b0;       
  else if(calc_codeword_en)  
      ready_r    <= 1'b1; 
end

// gen the code word of the low path 
  assign half_polyn_tmp[0] = ( state_x_i[2] & polynomial1_i[2] ) ^ ( state_x_i[1] & polynomial1_i[1] ) ^ ( state_x_i[0] & polynomial1_i[0] ) ;
  assign half_polyn_tmp[1] = ( state_x_i[2] & polynomial2_i[2] ) ^ ( state_x_i[1] & polynomial2_i[1] ) ^ ( state_x_i[0] & polynomial2_i[0] ) ;
  assign half_polyn_tmp[2] = ( state_x_i[2] & polynomial3_i[2] ) ^ ( state_x_i[1] & polynomial3_i[1] ) ^ ( state_x_i[0] & polynomial3_i[0] ) ;
  assign half_polyn_tmp[3] = ( state_x_i[2] & polynomial4_i[2] ) ^ ( state_x_i[1] & polynomial4_i[1] ) ^ ( state_x_i[0] & polynomial4_i[0] ) ;
  assign half_polyn_tmp[4] = ( state_x_i[2] & polynomial5_i[2] ) ^ ( state_x_i[1] & polynomial5_i[1] ) ^ ( state_x_i[0] & polynomial5_i[0] ) ;
  assign half_polyn_tmp[5] = ( state_x_i[2] & polynomial6_i[2] ) ^ ( state_x_i[1] & polynomial6_i[1] ) ^ ( state_x_i[0] & polynomial6_i[0] ) ;      

always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)
    low_codeword_tmp <= 6'h0;
  else if(rst_sync_i)
    low_codeword_tmp <= 6'h0;
  else if(calc_polyn_en) begin
    case(register_num_i)
      2'b00: begin
        low_codeword_tmp[0] <= ( state_x_i[5] & polynomial1_i[5] ) ^ ( state_x_i[4] & polynomial1_i[4] ) ^ ( state_x_i[3] & polynomial1_i[3] ) ^ half_polyn_tmp[0] ;
        low_codeword_tmp[1] <= ( state_x_i[5] & polynomial2_i[5] ) ^ ( state_x_i[4] & polynomial2_i[4] ) ^ ( state_x_i[3] & polynomial2_i[3] ) ^ half_polyn_tmp[1] ;
        low_codeword_tmp[2] <= ( state_x_i[5] & polynomial3_i[5] ) ^ ( state_x_i[4] & polynomial3_i[4] ) ^ ( state_x_i[3] & polynomial3_i[3] ) ^ half_polyn_tmp[2] ;
        low_codeword_tmp[3] <= ( state_x_i[5] & polynomial4_i[5] ) ^ ( state_x_i[4] & polynomial4_i[4] ) ^ ( state_x_i[3] & polynomial4_i[3] ) ^ half_polyn_tmp[3] ;
        low_codeword_tmp[4] <= ( state_x_i[5] & polynomial5_i[5] ) ^ ( state_x_i[4] & polynomial5_i[4] ) ^ ( state_x_i[3] & polynomial5_i[3] ) ^ half_polyn_tmp[4] ;
        low_codeword_tmp[5] <= ( state_x_i[5] & polynomial6_i[5] ) ^ ( state_x_i[4] & polynomial6_i[4] ) ^ ( state_x_i[3] & polynomial6_i[3] ) ^ half_polyn_tmp[5] ;        
      end
      2'b01: begin
        low_codeword_tmp[0] <= ( state_x_i[4] & polynomial1_i[4] ) ^ ( state_x_i[3] & polynomial1_i[3] ) ^ half_polyn_tmp[0] ;
        low_codeword_tmp[1] <= ( state_x_i[4] & polynomial2_i[4] ) ^ ( state_x_i[3] & polynomial2_i[3] ) ^ half_polyn_tmp[1] ;
        low_codeword_tmp[2] <= ( state_x_i[4] & polynomial3_i[4] ) ^ ( state_x_i[3] & polynomial3_i[3] ) ^ half_polyn_tmp[2] ;
        low_codeword_tmp[3] <= ( state_x_i[4] & polynomial4_i[4] ) ^ ( state_x_i[3] & polynomial4_i[3] ) ^ half_polyn_tmp[3] ;
        low_codeword_tmp[4] <= ( state_x_i[4] & polynomial5_i[4] ) ^ ( state_x_i[3] & polynomial5_i[3] ) ^ half_polyn_tmp[4] ;
        low_codeword_tmp[5] <= ( state_x_i[4] & polynomial6_i[4] ) ^ ( state_x_i[3] & polynomial6_i[3] ) ^ half_polyn_tmp[5] ;      
      end
      2'b10:  begin
        low_codeword_tmp[0] <= ( state_x_i[3] & polynomial1_i[3] ) ^ half_polyn_tmp[0] ;
        low_codeword_tmp[1] <= ( state_x_i[3] & polynomial2_i[3] ) ^ half_polyn_tmp[1] ;
        low_codeword_tmp[2] <= ( state_x_i[3] & polynomial3_i[3] ) ^ half_polyn_tmp[2] ;
        low_codeword_tmp[3] <= ( state_x_i[3] & polynomial4_i[3] ) ^ half_polyn_tmp[3] ;
        low_codeword_tmp[4] <= ( state_x_i[3] & polynomial5_i[3] ) ^ half_polyn_tmp[4] ;
        low_codeword_tmp[5] <= ( state_x_i[3] & polynomial6_i[3] ) ^ half_polyn_tmp[5] ;        
      end
      default:  begin
        low_codeword_tmp[0] <=  half_polyn_tmp[0];
        low_codeword_tmp[1] <=  half_polyn_tmp[1];
        low_codeword_tmp[2] <=  half_polyn_tmp[2];
        low_codeword_tmp[3] <=  half_polyn_tmp[3];
        low_codeword_tmp[4] <=  half_polyn_tmp[4];
        low_codeword_tmp[5] <=  half_polyn_tmp[5];
      end                   
    endcase
  end
 end        
// gen the code word of the low path 
always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i) 
    low_codeword <= 6'h0;
  else if( rst_sync_i )
    low_codeword <= 6'h0;
  else if( calc_codeword_en ) begin
    case( valid_polynomials_i)
      3'b000 : low_codeword <= low_codeword_tmp;
      3'b001 : low_codeword <= {1'b0, low_codeword_tmp[4:0]};   
      3'b010 : low_codeword <= {2'b0, low_codeword_tmp[3:0]};
      3'b011 : low_codeword <= {3'b0, low_codeword_tmp[2:0]};
      default: low_codeword <= {4'b0, low_codeword_tmp[1:0]};           
    endcase
  end   
end

// gen the branch metric of the low path
assign soft_bit0 =  soft_data_i[3:0];
assign soft_bit1 =  soft_data_i[7:4];
assign soft_bit2 =  soft_data_i[11:8];
assign soft_bit3 =  soft_data_i[15:12];
assign soft_bit4 =  soft_data_i[19:16];
assign soft_bit5 =  soft_data_i[23:20];

assign x_soft_bit0 =  low_codeword[0]? soft_bit0 : {soft_bit0[3],soft_bit0[2:0]};
assign x_soft_bit1 =  low_codeword[1]? soft_bit1 : {soft_bit1[3],soft_bit1[2:0]};
assign x_soft_bit2 =  low_codeword[2]? soft_bit2 : {soft_bit2[3],soft_bit2[2:0]};
assign x_soft_bit3 =  low_codeword[3]? soft_bit3 : {soft_bit3[3],soft_bit3[2:0]};
assign x_soft_bit4 =  low_codeword[4]? soft_bit4 : {soft_bit4[3],soft_bit4[2:0]};
assign x_soft_bit5 =  low_codeword[5]? soft_bit5 : {soft_bit5[3],soft_bit5[2:0]};

always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i) begin
    bm_valid_r <= 1'b0;
    bm_r <= 0;
    end
  else if( rst_sync_i ) begin
    bm_valid_r <= 1'b0;
    bm_r <= 0;
    end
  else if( soft_data_valid_i ) begin
    bm_valid_r <= 1'b1;
    case( valid_polynomials_i)
      3'b000 : bm_r <=  x_soft_bit5 + x_soft_bit4 + x_soft_bit3 + x_soft_bit2 + x_soft_bit1 + x_soft_bit0;
      3'b001 : bm_r <=  x_soft_bit4 + x_soft_bit3 + x_soft_bit2 + x_soft_bit1 + x_soft_bit0; 
      3'b010 : bm_r <=  x_soft_bit3 + x_soft_bit2 + x_soft_bit1 + x_soft_bit0;
      3'b011 : bm_r <=  x_soft_bit2 + x_soft_bit1 + x_soft_bit0;
      default: bm_r <=  x_soft_bit1 + x_soft_bit0; 
    endcase    
  end 
  else begin
    bm_valid_r <= 1'b0;
    bm_r <= 0;
  end
end
endmodule
