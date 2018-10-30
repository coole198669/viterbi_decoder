



module traceback #(parameter W_TB_LEN=6,W_HALF=32,W_FULL=64)( 
    input                    clk_i,
    input                    rst_an_i,
    input                    rst_sync_i,
                             
    input [1:0]              register_num_i,
    input                    segment_start_i,
    output                   busy_o,
    
    //input parameter 
    input [5:0]              start_state_index_i,
    input [W_TB_LEN-1:0]     tb_start_addr_i,
    input [W_TB_LEN:0]     tb_len_i,
    input                    decodeing_end_i, 
    //out stream
    output [W_HALF-1:0] half_tb_bits_o,
    output [W_FULL-1:0]   full_tb_bits_o,  
    output                      tb_bits_valid_o,
    //    
    output                   tb_rd_o,
    output [W_TB_LEN-1:0]    tb_addr_o,
    input  [63:0]            tb_rdata_i

);


parameter UPDATE_STATE = W_FULL*2-2;

reg [W_TB_LEN-1:0]   tb_addr_r;
reg                   tb_rd_r;
reg                   rdata_valid_r;
reg                   tb_bits_valid_r;
reg [W_TB_LEN:0]     tb_len_r;
reg                    decodeing_end_r; 

reg [W_TB_LEN+1:0]     tb_counter_r;
reg                  busy_r;
reg [5:0]            left_shif_num_r;
reg                  get_bit_s;
reg [W_HALF-1:0] half_tb_bits_r;
reg [W_FULL-1:0]   full_tb_bits_r;  

reg [5:0]            state_index_r;


assign busy_o    = busy_r;
assign tb_rd_o   = tb_rd_r;
assign tb_addr_o = tb_addr_r;
assign half_tb_bits_o =half_tb_bits_r;
assign full_tb_bits_o = full_tb_bits_r;  
assign   tb_bits_valid_o = tb_bits_valid_r;


always@(posedge clk_i or negedge rst_an_i) begin
   if(!rst_an_i) begin 
     tb_len_r            <= 0;    
     decodeing_end_r     <= 0;        
    end
   else if(rst_sync_i ) begin 
     tb_len_r            <= 0;    
     decodeing_end_r     <= 0;     
    end
   else if(segment_start_i) begin    
     tb_len_r            <=  tb_len_i;                
     decodeing_end_r     <=  decodeing_end_i;         
   end
end

always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)  tb_counter_r <= 0;
  else if(rst_sync_i) tb_counter_r <= 0;
  else if(segment_start_i)  tb_counter_r <= tb_len_i<<1;
  else if(tb_counter_r!=0) tb_counter_r <= tb_counter_r -1;
end  

always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)  busy_r <= 0;
  else if(rst_sync_i) busy_r <= 0;
  else if(segment_start_i==1'b1 || tb_counter_r!=0 )  busy_r <= 1;
  else busy_r <= 0;
end 

always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)              tb_rd_r <= 0;    
  else if(rst_sync_i)        tb_rd_r <= 0;   
  else if(tb_counter_r!=0 && tb_counter_r[0]==1'b0)     tb_rd_r <= 1;  
  else tb_rd_r<= 0;  
end


always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)              rdata_valid_r <= 0;    
  else if(rst_sync_i)        rdata_valid_r <= 0;  
  else rdata_valid_r <= tb_rd_r;
end

always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)              tb_bits_valid_r <= 0;    
  else if(rst_sync_i)        tb_bits_valid_r <= 0;  
  else if(tb_counter_r==0 && rdata_valid_r==1'b1)
      tb_bits_valid_r <= 1'b1;
  else
      tb_bits_valid_r <= 1'b0;		
end

  
always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)              tb_addr_r <= 0;  
  else if(rst_sync_i)        tb_addr_r <= 0;  
  else if(segment_start_i)   tb_addr_r <= tb_start_addr_i;  
  else if(tb_counter_r!=0 && tb_counter_r[0]==1'b0)     tb_addr_r <= tb_addr_r-1;
end



always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)             left_shif_num_r <= 0;  
  else if(rst_sync_i)       left_shif_num_r <= 0;  
  else  if(segment_start_i) begin
    case(register_num_i)
      2'b00: left_shif_num_r <= 6'b100000;
      2'b01: left_shif_num_r <= 6'b010000;
      2'b10: left_shif_num_r <= 6'b001000;
      2'b11: left_shif_num_r <= 6'b000100;
      default:left_shif_num_r <= 6'b100000;
    endcase
  end
end
always@(tb_rdata_i or state_index_r) begin
  case(state_index_r)
   6'd0 :   get_bit_s = tb_rdata_i[0 ] ;
   6'd1 :   get_bit_s = tb_rdata_i[1 ] ;
   6'd2 :   get_bit_s = tb_rdata_i[2 ] ;
   6'd3 :   get_bit_s = tb_rdata_i[3 ] ;
   6'd4 :   get_bit_s = tb_rdata_i[4 ] ;
   6'd5 :   get_bit_s = tb_rdata_i[5 ] ;
   6'd6 :   get_bit_s = tb_rdata_i[6 ] ;
   6'd7 :   get_bit_s = tb_rdata_i[7 ] ;
   6'd8 :   get_bit_s = tb_rdata_i[8 ] ;
   6'd9 :   get_bit_s = tb_rdata_i[9 ] ;
   6'd10:   get_bit_s = tb_rdata_i[10] ;
   6'd11:   get_bit_s = tb_rdata_i[11] ;
   6'd12:   get_bit_s = tb_rdata_i[12] ;
   6'd13:   get_bit_s = tb_rdata_i[13] ;
   6'd14:   get_bit_s = tb_rdata_i[14] ;
   6'd15:   get_bit_s = tb_rdata_i[15] ;
   6'd16:   get_bit_s = tb_rdata_i[16] ;
   6'd17:   get_bit_s = tb_rdata_i[17] ;
   6'd18:   get_bit_s = tb_rdata_i[18] ;
   6'd19:   get_bit_s = tb_rdata_i[19] ;
   6'd20:   get_bit_s = tb_rdata_i[20] ;
   6'd21:   get_bit_s = tb_rdata_i[21] ;
   6'd22:   get_bit_s = tb_rdata_i[22] ;
   6'd23:   get_bit_s = tb_rdata_i[23] ;
   6'd24:   get_bit_s = tb_rdata_i[24] ;
   6'd25:   get_bit_s = tb_rdata_i[25] ;
   6'd26:   get_bit_s = tb_rdata_i[26] ;
   6'd27:   get_bit_s = tb_rdata_i[27] ;
   6'd28:   get_bit_s = tb_rdata_i[28] ;
   6'd29:   get_bit_s = tb_rdata_i[29] ;
   6'd30:   get_bit_s = tb_rdata_i[30] ;
   6'd31:   get_bit_s = tb_rdata_i[31] ;
   6'd32:   get_bit_s = tb_rdata_i[32] ;
   6'd33:   get_bit_s = tb_rdata_i[33] ;
   6'd34:   get_bit_s = tb_rdata_i[34] ;
   6'd35:   get_bit_s = tb_rdata_i[35] ;
   6'd36:   get_bit_s = tb_rdata_i[36] ;
   6'd37:   get_bit_s = tb_rdata_i[37] ;
   6'd38:   get_bit_s = tb_rdata_i[38] ;
   6'd39:   get_bit_s = tb_rdata_i[39] ;
   6'd40:   get_bit_s = tb_rdata_i[40] ;
   6'd41:   get_bit_s = tb_rdata_i[41] ;
   6'd42:   get_bit_s = tb_rdata_i[42] ;
   6'd43:   get_bit_s = tb_rdata_i[43] ;
   6'd44:   get_bit_s = tb_rdata_i[44] ;
   6'd45:   get_bit_s = tb_rdata_i[45] ;
   6'd46:   get_bit_s = tb_rdata_i[46] ;
   6'd47:   get_bit_s = tb_rdata_i[47] ;
   6'd48:   get_bit_s = tb_rdata_i[48] ;
   6'd49:   get_bit_s = tb_rdata_i[49] ;
   6'd50:   get_bit_s = tb_rdata_i[50] ;
   6'd51:   get_bit_s = tb_rdata_i[51] ;
   6'd52:   get_bit_s = tb_rdata_i[52] ;
   6'd53:   get_bit_s = tb_rdata_i[53] ;
   6'd54:   get_bit_s = tb_rdata_i[54] ;
   6'd55:   get_bit_s = tb_rdata_i[55] ;
   6'd56:   get_bit_s = tb_rdata_i[56] ;
   6'd57:   get_bit_s = tb_rdata_i[57] ;
   6'd58:   get_bit_s = tb_rdata_i[58] ;
   6'd59:   get_bit_s = tb_rdata_i[59] ;
   6'd60:   get_bit_s = tb_rdata_i[60] ;
   6'd61:   get_bit_s = tb_rdata_i[61] ;
   6'd62:   get_bit_s = tb_rdata_i[62] ;
   6'd63:   get_bit_s = tb_rdata_i[63] ;
   default: get_bit_s = 0 ;
  endcase
end  

always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)              state_index_r <= 0;  
  else if(rst_sync_i)        state_index_r <= 0;  
  else if(segment_start_i)   state_index_r <= start_state_index_i; 
  else if(tb_counter_r!=0 && tb_counter_r<UPDATE_STATE && tb_counter_r[0]==1'b1)  begin
    if(get_bit_s)
       state_index_r <=(state_index_r>>1) + left_shif_num_r;  
    else
       state_index_r <=(state_index_r>>1);  
  end  
end


always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)              half_tb_bits_r <= 0;  
  else if(rst_sync_i)        half_tb_bits_r <= 0;  
  else if(segment_start_i)   half_tb_bits_r <= 0; 
  else if(~decodeing_end_r && tb_counter_r<=tb_len_r && tb_counter_r[0]==1'b0 && rdata_valid_r==1'b1)   
     half_tb_bits_r <= {half_tb_bits_r[W_HALF-2:0], get_bit_s};
  else half_tb_bits_r <= half_tb_bits_r;
end

always@(posedge clk_i or negedge rst_an_i) begin
  if(!rst_an_i)              full_tb_bits_r <= 0;  
  else if(rst_sync_i)        full_tb_bits_r <= 0;  
  else if(segment_start_i)   full_tb_bits_r <= 0; 
  else if(decodeing_end_r && tb_counter_r[0]==1'b0 && rdata_valid_r==1'b1)   
     full_tb_bits_r <= {full_tb_bits_r[W_FULL-2:0], get_bit_s};
  else full_tb_bits_r <= full_tb_bits_r;
end


endmodule